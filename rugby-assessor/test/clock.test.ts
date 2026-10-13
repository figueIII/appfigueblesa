import { test } from 'node:test';
import assert from 'node:assert/strict';
import { appendClockEvent, foldClock, formatClock, matchTimeAt, type ClockEvent, type ClockEventBody } from '../domain/clock.ts';
import type { CategoryConfig } from '../domain/model.ts';

const XV: CategoryConfig = {
  code: 'SENIOR', name: 'Sénior', format: 'XV', periodLengthMin: 40, halfTimeMin: 15,
  extraTime: null, sinBinMin: 10, lawVariations: [],
};
const XV_KO: CategoryConfig = { ...XV, code: 'SENIOR_KO', extraTime: { periodLengthMin: 10, suddenDeath: true } };
const MIN = 60_000;

function play(cat: CategoryConfig, steps: Array<[number, ClockEventBody]>): ClockEvent[] {
  return steps.reduce<ClockEvent[]>((log, [t, body]) => appendClockEvent(log, body, t, cat), []);
}

test('el tiempo parado no cuenta y el reloj de H2 empieza en 40:00', () => {
  const log = play(XV, [
    [0, { type: 'PERIOD_START', period: 'H1' }],
    [10 * MIN, { type: 'TIME_OFF' }],
    [12 * MIN, { type: 'TIME_ON' }],
  ]);
  const s = foldClock(log, XV);
  const mt = matchTimeAt(s, 20 * MIN, XV);
  assert.equal(mt.periodElapsedMs, 18 * MIN);
  assert.equal(mt.phaseLabel, 'IN_PLAY');

  const log2 = play(XV, [
    ...log.map((e) => [e.t, e] as [number, ClockEventBody]),
    [43 * MIN + 30_000, { type: 'PERIOD_END', next: 'INTERVAL' }],
    [58 * MIN, { type: 'PERIOD_START', period: 'H2' }],
  ]);
  const s2 = foldClock(log2, XV);
  assert.equal(s2.completedPeriods.join(), 'H1');
  assert.equal(formatClock(matchTimeAt(s2, 59 * MIN, XV).matchClockMs), '41:00');
});

test('tiempo cumplido: overtime > 0 hasta que el balón queda muerto', () => {
  const log = play(XV, [[0, { type: 'PERIOD_START', period: 'H1' }]]);
  const mt = matchTimeAt(foldClock(log, XV), 41 * MIN + 23_000, XV);
  assert.equal(mt.overtimeMs, 83_000);
  assert.equal(formatClock(mt.matchClockMs), '41:23');
});

test('ADJUST corrige solo hacia delante y limpia la integridad degradada', () => {
  const log = play(XV, [
    [0, { type: 'PERIOD_START', period: 'H1' }],
    [5 * MIN, { type: 'INTEGRITY_LOST', estimatedGapMs: 30_000 }],
    [6 * MIN, { type: 'ADJUST', deltaMs: 20_000 }],
  ]);
  assert.equal(matchTimeAt(foldClock(log, XV, 5 * MIN), 5 * MIN, XV).integrity, 'DEGRADED');
  assert.equal(matchTimeAt(foldClock(log, XV, 5 * MIN), 5 * MIN, XV).periodElapsedMs, 5 * MIN);
  const s = foldClock(log, XV);
  assert.equal(s.integrity, 'OK');
  assert.equal(matchTimeAt(s, 7 * MIN, XV).periodElapsedMs, 7 * MIN + 20_000);
});

test('transiciones ilegales se rechazan', () => {
  const ht = play(XV, [
    [0, { type: 'PERIOD_START', period: 'H1' }],
    [40 * MIN, { type: 'PERIOD_END', next: 'INTERVAL' }],
  ]);
  assert.throws(() => appendClockEvent(ht, { type: 'TIME_OFF' }, 41 * MIN, XV), /INVALID_TRANSITION/);
  assert.throws(() => appendClockEvent(ht, { type: 'PERIOD_START', period: 'ET1' }, 41 * MIN, XV), /WRONG_PERIOD_ORDER/);
  assert.throws(() => appendClockEvent(ht, { type: 'PERIOD_START', period: 'H2' }, 39 * MIN, XV), /NON_MONOTONIC_TIME/);
  const h2 = appendClockEvent(ht, { type: 'PERIOD_START', period: 'H2' }, 55 * MIN, XV);
  assert.throws(() => appendClockEvent(h2, { type: 'PERIOD_END', next: 'INTERVAL' }, 95 * MIN, XV), /NO_EXTRA_TIME_CONFIGURED/);
  assert.equal(foldClock(appendClockEvent(h2, { type: 'PERIOD_END', next: 'FULL_TIME' }, 95 * MIN, XV), XV).status, 'FULL_TIME');
});

test('prórroga y muerte súbita solo si la categoría la define', () => {
  const log = play(XV_KO, [
    [0, { type: 'PERIOD_START', period: 'H1' }],
    [40 * MIN, { type: 'PERIOD_END', next: 'INTERVAL' }],
    [55 * MIN, { type: 'PERIOD_START', period: 'H2' }],
    [95 * MIN, { type: 'PERIOD_END', next: 'INTERVAL' }],
    [100 * MIN, { type: 'PERIOD_START', period: 'ET1' }],
  ]);
  assert.equal(formatClock(matchTimeAt(foldClock(log, XV_KO), 101 * MIN, XV_KO).matchClockMs), '81:00');
});

test('VOID deshace solo el último evento efectivo', () => {
  const log = play(XV, [
    [0, { type: 'PERIOD_START', period: 'H1' }],
    [10 * MIN, { type: 'TIME_OFF' }],
  ]);
  assert.throws(() => appendClockEvent(log, { type: 'VOID', targetSeq: 1 }, 11 * MIN, XV), /NOTHING_TO_VOID/);
  const undone = appendClockEvent(log, { type: 'VOID', targetSeq: 2 }, 11 * MIN, XV);
  const s = foldClock(undone, XV);
  assert.equal(s.status, 'RUNNING');
  assert.equal(matchTimeAt(s, 12 * MIN, XV).periodElapsedMs, 12 * MIN);
  assert.equal(undone.length, 3, 'el log nunca se borra: el VOID es un evento más');
});
