// Port a Dart de domain/clock.ts. Máquina de estados del reloj por event sourcing:
// el estado es fold(eventos). Puro: el tiempo llega como `t` (ms del eje de sesión).
// Los tests de test/domain/clock_test.dart replican los de test/clock.test.ts.

import 'model.dart';

enum ClockStatus { preMatch, running, stopped, interval, fullTime, abandoned }

enum PeriodEndNext { interval, fullTime }

sealed class ClockEventBody {
  const ClockEventBody();
}

final class PeriodStart extends ClockEventBody {
  const PeriodStart(this.period);
  final PeriodId period;
}

final class TimeOff extends ClockEventBody {
  const TimeOff();
}

final class TimeOn extends ClockEventBody {
  const TimeOn();
}

final class PeriodEnd extends ClockEventBody {
  const PeriodEnd(this.next);
  final PeriodEndNext next;
}

final class Adjust extends ClockEventBody {
  const Adjust(this.deltaMs);
  final int deltaMs;
}

final class IntegrityLost extends ClockEventBody {
  const IntegrityLost(this.estimatedGapMs);
  final int estimatedGapMs;
}

final class Abandon extends ClockEventBody {
  const Abandon(this.reason);
  final String reason;
}

final class VoidEvent extends ClockEventBody {
  const VoidEvent(this.targetSeq);
  final int targetSeq;
}

class ClockEvent {
  const ClockEvent({required this.seq, required this.t, required this.body});
  final int seq;
  final int t;
  final ClockEventBody body;
}

enum ClockError {
  invalidTransition,
  wrongPeriodOrder,
  nonMonotonicTime,
  noExtraTimeConfigured,
  nothingToVoid,
  negativePeriodTime,
}

class ClockRuleException implements Exception {
  const ClockRuleException(this.code, [this.detail = '']);
  final ClockError code;
  final String detail;
  @override
  String toString() => 'ClockRuleException(${code.name}${detail.isEmpty ? '' : ': $detail'})';
}

class ClockState {
  const ClockState({
    required this.status,
    required this.period,
    required this.completedPeriods,
    required this.accumulatedMs,
    required this.runningSince,
    required this.timeOffCount,
    required this.integrity,
    required this.lastT,
  });

  static const initial = ClockState(
    status: ClockStatus.preMatch,
    period: null,
    completedPeriods: [],
    accumulatedMs: 0,
    runningSince: null,
    timeOffCount: 0,
    integrity: TimeIntegrity.ok,
    lastT: 0,
  );

  final ClockStatus status;
  final PeriodId? period;
  final List<PeriodId> completedPeriods;
  final int accumulatedMs;
  final int? runningSince;
  final int timeOffCount;
  final TimeIntegrity integrity;
  final int lastT;

  bool get isPlaying => status == ClockStatus.running || status == ClockStatus.stopped;

  ClockState copyWith({
    ClockStatus? status,
    PeriodId? period,
    List<PeriodId>? completedPeriods,
    int? accumulatedMs,
    int? Function()? runningSince,
    int? timeOffCount,
    TimeIntegrity? integrity,
    int? lastT,
  }) =>
      ClockState(
        status: status ?? this.status,
        period: period ?? this.period,
        completedPeriods: completedPeriods ?? this.completedPeriods,
        accumulatedMs: accumulatedMs ?? this.accumulatedMs,
        runningSince: runningSince != null ? runningSince() : this.runningSince,
        timeOffCount: timeOffCount ?? this.timeOffCount,
        integrity: integrity ?? this.integrity,
        lastT: lastT ?? this.lastT,
      );
}

/// Siguiente periodo legal según la categoría y los ya jugados.
PeriodId? expectedNextPeriod(List<PeriodId> done, CategoryConfig cat) {
  final order = <PeriodId>[PeriodId.h1, PeriodId.h2];
  final et = cat.extraTime;
  if (et != null) {
    order.addAll([PeriodId.et1, PeriodId.et2]);
    if (et.suddenDeath) order.add(PeriodId.sd);
  }
  return done.length < order.length ? order[done.length] : null;
}

int? periodLengthMs(PeriodId p, CategoryConfig cat) => switch (p) {
      PeriodId.h1 || PeriodId.h2 => cat.periodLengthMin * 60000,
      PeriodId.sd => null,
      PeriodId.et1 || PeriodId.et2 => cat.extraTime!.periodLengthMin * 60000,
    };

/// Desplazamiento del reloj "estilo marcador": H2 empieza en 40:00 (o 35:00, 30:00…).
int periodClockBaseMs(PeriodId p, CategoryConfig cat) {
  final reg = cat.periodLengthMin * 60000;
  final et = (cat.extraTime?.periodLengthMin ?? 0) * 60000;
  return switch (p) {
    PeriodId.h1 => 0,
    PeriodId.h2 => reg,
    PeriodId.et1 => 2 * reg,
    PeriodId.et2 => 2 * reg + et,
    PeriodId.sd => 2 * reg + 2 * et,
  };
}

ClockState applyClockEvent(ClockState s, ClockEvent e, CategoryConfig cat) {
  if (e.t < s.lastT) {
    throw ClockRuleException(ClockError.nonMonotonicTime, '${e.t} < ${s.lastT}');
  }
  final base = s.copyWith(lastT: e.t);
  final elapsedNow = s.accumulatedMs + (s.runningSince == null ? 0 : e.t - s.runningSince!);
  ClockRuleException illegal(String what) =>
      ClockRuleException(ClockError.invalidTransition, '${s.status.name} → $what');

  switch (e.body) {
    case PeriodStart(:final period):
      if (s.status != ClockStatus.preMatch && s.status != ClockStatus.interval) {
        throw illegal('PERIOD_START');
      }
      final expected = expectedNextPeriod(s.completedPeriods, cat);
      if (expected != period) {
        throw ClockRuleException(
          expected == null ? ClockError.noExtraTimeConfigured : ClockError.wrongPeriodOrder,
          'esperado ${expected?.name}, recibido ${period.name}',
        );
      }
      return base.copyWith(
        status: ClockStatus.running,
        period: period,
        accumulatedMs: 0,
        runningSince: () => e.t,
        timeOffCount: 0,
      );
    case TimeOff():
      if (s.status != ClockStatus.running) throw illegal('TIME_OFF');
      return base.copyWith(
        status: ClockStatus.stopped,
        accumulatedMs: elapsedNow,
        runningSince: () => null,
        timeOffCount: s.timeOffCount + 1,
      );
    case TimeOn():
      if (s.status != ClockStatus.stopped) throw illegal('TIME_ON');
      return base.copyWith(status: ClockStatus.running, runningSince: () => e.t);
    case PeriodEnd(:final next):
      if (!s.isPlaying) throw illegal('PERIOD_END');
      final done = [...s.completedPeriods, s.period!];
      final more = expectedNextPeriod(done, cat) != null;
      if (next == PeriodEndNext.interval && !more) {
        throw const ClockRuleException(ClockError.noExtraTimeConfigured);
      }
      if (next == PeriodEndNext.fullTime && s.period == PeriodId.h1) {
        throw illegal('FULL_TIME desde H1 (usar ABANDON)');
      }
      return base.copyWith(
        status: next == PeriodEndNext.interval ? ClockStatus.interval : ClockStatus.fullTime,
        completedPeriods: done,
        accumulatedMs: elapsedNow,
        runningSince: () => null,
      );
    case Adjust(:final deltaMs):
      if (!s.isPlaying) throw illegal('ADJUST');
      if (elapsedNow + deltaMs < 0) throw const ClockRuleException(ClockError.negativePeriodTime);
      return base.copyWith(
        accumulatedMs: elapsedNow + deltaMs,
        runningSince: () => s.status == ClockStatus.running ? e.t : null,
        integrity: TimeIntegrity.ok,
      );
    case IntegrityLost():
      return base.copyWith(integrity: TimeIntegrity.degraded);
    case Abandon():
      if (s.status == ClockStatus.fullTime || s.status == ClockStatus.abandoned) {
        throw illegal('ABANDON');
      }
      return base.copyWith(
        status: ClockStatus.abandoned,
        accumulatedMs: elapsedNow,
        runningSince: () => null,
      );
    case VoidEvent():
      throw illegal('VOID (se resuelve en foldClock)');
  }
}

List<ClockEvent> effectiveEvents(List<ClockEvent> log) {
  final voided = {
    for (final e in log)
      if (e.body case VoidEvent(:final targetSeq)) targetSeq,
  };
  return [
    for (final e in log)
      if (e.body is! VoidEvent && !voided.contains(e.seq)) e,
  ];
}

ClockState foldClock(List<ClockEvent> log, CategoryConfig cat, {int? upTo}) {
  var s = ClockState.initial;
  for (final e in effectiveEvents(log)) {
    if (upTo != null && e.t > upTo) break;
    s = applyClockEvent(s, e, cat);
  }
  return s;
}

/// Valida y añade un evento. Devuelve un log nuevo (append-only); lanza si no es legal.
List<ClockEvent> appendClockEvent(List<ClockEvent> log, ClockEventBody body, int t, CategoryConfig cat) {
  final seq = (log.isEmpty ? 0 : log.last.seq) + 1;
  final event = ClockEvent(seq: seq, t: t, body: body);
  if (body is VoidEvent) {
    final eff = effectiveEvents(log);
    if (eff.isEmpty || eff.last.seq != body.targetSeq) {
      throw const ClockRuleException(ClockError.nothingToVoid, 'solo se puede deshacer el último evento efectivo');
    }
    foldClock([...log, event], cat);
    return [...log, event];
  }
  applyClockEvent(foldClock(log, cat), event, cat);
  return [...log, event];
}

MatchTimeStamp matchTimeAt(ClockState s, int t, CategoryConfig cat) {
  final period = s.period;
  if (period == null || s.status == ClockStatus.preMatch) {
    return MatchTimeStamp(
      period: null,
      phase: MatchPhaseLabel.preMatch,
      periodElapsedMs: 0,
      matchClockMs: 0,
      overtimeMs: 0,
      integrity: s.integrity,
    );
  }
  final elapsed = s.accumulatedMs + (s.runningSince == null ? 0 : t - s.runningSince!);
  final len = periodLengthMs(period, cat);
  return MatchTimeStamp(
    period: s.isPlaying ? period : null,
    phase: switch (s.status) {
      ClockStatus.running => MatchPhaseLabel.inPlay,
      ClockStatus.stopped => MatchPhaseLabel.timeOff,
      ClockStatus.interval => MatchPhaseLabel.interval,
      ClockStatus.fullTime || ClockStatus.abandoned => MatchPhaseLabel.fullTime,
      ClockStatus.preMatch => MatchPhaseLabel.preMatch,
    },
    periodElapsedMs: elapsed,
    matchClockMs: periodClockBaseMs(period, cat) + elapsed,
    overtimeMs: len == null ? 0 : (elapsed - len).clamp(0, 1 << 52),
    integrity: s.integrity,
  );
}

/// "41:23": minutos totales y segundos.
String formatClock(int ms) {
  final total = ms ~/ 1000;
  final m = (total ~/ 60).toString().padLeft(2, '0');
  final sec = (total % 60).toString().padLeft(2, '0');
  return '$m:$sec';
}
