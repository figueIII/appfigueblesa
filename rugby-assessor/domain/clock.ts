// Máquina de estados del reloj de partido. Event sourcing: el estado es fold(eventos).
// Puro: no lee el reloj del sistema. El tiempo llega como `t` (SessionMs) en cada evento.
// Ver docs/ESPECIFICACION_EVALUADOR_ARBITRAL.md §2.1.

import type { CategoryConfig, MatchTimeStamp, PeriodId, SessionMs } from './model.ts';

export type ClockStatus = 'PRE_MATCH' | 'RUNNING' | 'STOPPED' | 'INTERVAL' | 'FULL_TIME' | 'ABANDONED';

export type ClockEventBody =
  | { type: 'PERIOD_START'; period: PeriodId }
  | { type: 'TIME_OFF' }                                   // el árbitro para el reloj
  | { type: 'TIME_ON' }
  | { type: 'PERIOD_END'; next: 'INTERVAL' | 'FULL_TIME' } // balón muerto con tiempo cumplido
  | { type: 'ADJUST'; deltaMs: number }                    // sincronizar con el reloj oficial
  | { type: 'INTEGRITY_LOST'; estimatedGapMs: number }     // reinicio del dispositivo (§2.1.1)
  | { type: 'ABANDON'; reason: string }
  | { type: 'VOID'; targetSeq: number };                   // deshacer el último evento efectivo

export type ClockEvent = ClockEventBody & { seq: number; t: SessionMs };

export interface ClockState {
  status: ClockStatus;
  period: PeriodId | null;
  completedPeriods: PeriodId[];
  accumulatedMs: number;          // tiempo de juego del periodo hasta runningSince
  runningSince: SessionMs | null; // no null solo en RUNNING
  timeOffCount: number;           // en el periodo actual
  integrity: 'OK' | 'DEGRADED';
  lastT: SessionMs;
}

export const INITIAL_CLOCK: ClockState = {
  status: 'PRE_MATCH', period: null, completedPeriods: [], accumulatedMs: 0,
  runningSince: null, timeOffCount: 0, integrity: 'OK', lastT: 0,
};

export type ClockError =
  | 'INVALID_TRANSITION' | 'WRONG_PERIOD_ORDER' | 'NON_MONOTONIC_TIME'
  | 'NO_EXTRA_TIME_CONFIGURED' | 'NOTHING_TO_VOID' | 'NEGATIVE_PERIOD_TIME';

export class ClockRuleError extends Error {
  readonly code: ClockError;
  constructor(code: ClockError, detail = '') { super(`${code}${detail ? `: ${detail}` : ''}`); this.code = code; }
}

/** Siguiente periodo legal según la categoría y los ya jugados. */
export function expectedNextPeriod(done: PeriodId[], cat: CategoryConfig): PeriodId | null {
  const order: PeriodId[] = ['H1', 'H2'];
  if (cat.extraTime) { order.push('ET1', 'ET2'); if (cat.extraTime.suddenDeath) order.push('SD'); }
  return order[done.length] ?? null;
}

export function periodLengthMs(p: PeriodId, cat: CategoryConfig): number | null {
  if (p === 'H1' || p === 'H2') return cat.periodLengthMin * 60_000;
  if (p === 'SD') return null; // muerte súbita: sin duración fija en el MVP
  return cat.extraTime!.periodLengthMin * 60_000;
}

/** Desplazamiento del reloj "estilo marcador": H2 empieza en 40:00, ET1 en 80:00… */
export function periodClockBaseMs(p: PeriodId, cat: CategoryConfig): number {
  const reg = cat.periodLengthMin * 60_000;
  const et = (cat.extraTime?.periodLengthMin ?? 0) * 60_000;
  return { H1: 0, H2: reg, ET1: 2 * reg, ET2: 2 * reg + et, SD: 2 * reg + 2 * et }[p];
}

const isPlaying = (s: ClockState) => s.status === 'RUNNING' || s.status === 'STOPPED';

/** Aplica un evento. Lanza ClockRuleError si la transición no es legal. */
export function applyClockEvent(s: ClockState, e: ClockEvent, cat: CategoryConfig): ClockState {
  if (e.t < s.lastT) throw new ClockRuleError('NON_MONOTONIC_TIME', `${e.t} < ${s.lastT}`);
  const base = { ...s, lastT: e.t };
  const elapsedNow = s.accumulatedMs + (s.runningSince === null ? 0 : e.t - s.runningSince);

  switch (e.type) {
    case 'PERIOD_START': {
      if (s.status !== 'PRE_MATCH' && s.status !== 'INTERVAL') throw new ClockRuleError('INVALID_TRANSITION', `${s.status} → PERIOD_START`);
      const expected = expectedNextPeriod(s.completedPeriods, cat);
      if (expected !== e.period) throw new ClockRuleError(expected === null ? 'NO_EXTRA_TIME_CONFIGURED' : 'WRONG_PERIOD_ORDER', `esperado ${expected}, recibido ${e.period}`);
      return { ...base, status: 'RUNNING', period: e.period, accumulatedMs: 0, runningSince: e.t, timeOffCount: 0 };
    }
    case 'TIME_OFF':
      if (s.status !== 'RUNNING') throw new ClockRuleError('INVALID_TRANSITION', `${s.status} → TIME_OFF`);
      return { ...base, status: 'STOPPED', accumulatedMs: elapsedNow, runningSince: null, timeOffCount: s.timeOffCount + 1 };
    case 'TIME_ON':
      if (s.status !== 'STOPPED') throw new ClockRuleError('INVALID_TRANSITION', `${s.status} → TIME_ON`);
      return { ...base, status: 'RUNNING', runningSince: e.t };
    case 'PERIOD_END': {
      if (!isPlaying(s)) throw new ClockRuleError('INVALID_TRANSITION', `${s.status} → PERIOD_END`);
      const done = [...s.completedPeriods, s.period!];
      const more = expectedNextPeriod(done, cat) !== null;
      if (e.next === 'INTERVAL' && !more) throw new ClockRuleError('NO_EXTRA_TIME_CONFIGURED');
      if (e.next === 'FULL_TIME' && s.period === 'H1') throw new ClockRuleError('INVALID_TRANSITION', 'H1 no puede cerrar el partido (usar ABANDON)');
      return { ...base, status: e.next, completedPeriods: done, accumulatedMs: elapsedNow, runningSince: null };
    }
    case 'ADJUST': {
      if (!isPlaying(s)) throw new ClockRuleError('INVALID_TRANSITION', `${s.status} → ADJUST`);
      if (elapsedNow + e.deltaMs < 0) throw new ClockRuleError('NEGATIVE_PERIOD_TIME');
      // Se consolida el tramo en curso y se reabre en t: el ajuste solo afecta hacia delante.
      return { ...base, accumulatedMs: elapsedNow + e.deltaMs, runningSince: s.status === 'RUNNING' ? e.t : null, integrity: 'OK' };
    }
    case 'INTEGRITY_LOST':
      // La plataforma ya traduce el hueco a `t`; aquí solo se marca la sospecha hasta un ADJUST.
      return { ...base, integrity: 'DEGRADED' };
    case 'ABANDON':
      if (s.status === 'FULL_TIME' || s.status === 'ABANDONED') throw new ClockRuleError('INVALID_TRANSITION');
      return { ...base, status: 'ABANDONED', accumulatedMs: elapsedNow, runningSince: null };
    case 'VOID':
      throw new ClockRuleError('INVALID_TRANSITION', 'VOID se resuelve en foldClock, no aquí');
  }
}

/** Eventos efectivos: los VOID anulan su objetivo y no cuentan. */
export function effectiveEvents(log: readonly ClockEvent[]): ClockEvent[] {
  const voided = new Set(log.filter((e) => e.type === 'VOID').map((e) => (e as { targetSeq: number }).targetSeq));
  return log.filter((e) => e.type !== 'VOID' && !voided.has(e.seq));
}

/** Estado tras aplicar el log (opcionalmente solo hasta el instante `upTo`, inclusive). */
export function foldClock(log: readonly ClockEvent[], cat: CategoryConfig, upTo = Infinity): ClockState {
  return effectiveEvents(log)
    .filter((e) => e.t <= upTo)
    .reduce((s, e) => applyClockEvent(s, e, cat), INITIAL_CLOCK);
}

/** Valida y añade un evento. Devuelve el nuevo log; el log original no se toca (append-only). */
export function appendClockEvent(log: readonly ClockEvent[], body: ClockEventBody, t: SessionMs, cat: CategoryConfig): ClockEvent[] {
  const seq = (log.at(-1)?.seq ?? 0) + 1;
  const event = { ...body, seq, t } as ClockEvent;
  if (body.type === 'VOID') {
    const last = effectiveEvents(log).at(-1);
    if (!last || last.seq !== body.targetSeq) throw new ClockRuleError('NOTHING_TO_VOID', 'solo se puede deshacer el último evento efectivo');
    foldClock([...log, event], cat); // el log resultante debe seguir siendo válido
    return [...log, event];
  }
  applyClockEvent(foldClock(log, cat), event, cat); // lanza si no es legal
  return [...log, event];
}

/** Tiempo de partido en el instante `t`, a partir del estado plegado hasta `t`. */
export function matchTimeAt(s: ClockState, t: SessionMs, cat: CategoryConfig): MatchTimeStamp {
  if (s.period === null || s.status === 'PRE_MATCH') {
    return { period: null, phaseLabel: 'PRE_MATCH', periodElapsedMs: 0, matchClockMs: 0, overtimeMs: 0, integrity: s.integrity };
  }
  const elapsed = s.accumulatedMs + (s.runningSince === null ? 0 : t - s.runningSince);
  const len = periodLengthMs(s.period, cat);
  const label = ({ RUNNING: 'IN_PLAY', STOPPED: 'TIME_OFF', INTERVAL: 'INTERVAL', FULL_TIME: 'FULL_TIME', ABANDONED: 'FULL_TIME' } as const)[s.status];
  return {
    period: isPlaying(s) ? s.period : null,
    phaseLabel: label,
    periodElapsedMs: elapsed,
    matchClockMs: periodClockBaseMs(s.period, cat) + elapsed,
    overtimeMs: len === null ? 0 : Math.max(0, elapsed - len),
    integrity: s.integrity,
  };
}

/** "41:23" (minutos totales, sin horas: un partido nunca llega a 100 min de reloj). */
export function formatClock(ms: number): string {
  const total = Math.floor(ms / 1000);
  return `${String(Math.floor(total / 60)).padStart(2, '0')}:${String(total % 60).padStart(2, '0')}`;
}
