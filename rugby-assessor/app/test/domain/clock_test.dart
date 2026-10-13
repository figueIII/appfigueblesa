// Mismos casos que test/clock.test.ts y test/presets.test.ts: el port Dart debe coincidir.
import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/clock.dart';
import 'package:ref_assess/domain/model.dart';

const min = 60000;
const xv = CategoryConfig(code: 'SENIOR', name: 'Sénior', format: GameFormat.xv, periodLengthMin: 40, sinBinMin: 10);
const xvKo = CategoryConfig(
  code: 'SENIOR_KO', name: 'Sénior KO', format: GameFormat.xv, periodLengthMin: 40, sinBinMin: 10,
  extraTime: ExtraTimeConfig(periodLengthMin: 10, suddenDeath: true),
);

List<ClockEvent> play(CategoryConfig cat, List<(int, ClockEventBody)> steps, [List<ClockEvent> log = const []]) =>
    steps.fold(log, (l, s) => appendClockEvent(l, s.$2, s.$1, cat));

Matcher throwsClock(ClockError code) =>
    throwsA(isA<ClockRuleException>().having((e) => e.code, 'code', code));

void main() {
  test('el tiempo parado no cuenta y el reloj de H2 empieza en 40:00', () {
    final log = play(xv, [(0, const PeriodStart(PeriodId.h1)), (10 * min, const TimeOff()), (12 * min, const TimeOn())]);
    final mt = matchTimeAt(foldClock(log, xv), 20 * min, xv);
    expect(mt.periodElapsedMs, 18 * min);
    expect(mt.phase, MatchPhaseLabel.inPlay);
    final log2 = play(xv, [(43 * min + 30000, const PeriodEnd(PeriodEndNext.interval)), (58 * min, const PeriodStart(PeriodId.h2))], log);
    final s2 = foldClock(log2, xv);
    expect(s2.completedPeriods, [PeriodId.h1]);
    expect(formatClock(matchTimeAt(s2, 59 * min, xv).matchClockMs), '41:00');
  });

  test('tiempo cumplido: overtime > 0 hasta que el balón queda muerto', () {
    final log = play(xv, [(0, const PeriodStart(PeriodId.h1))]);
    final mt = matchTimeAt(foldClock(log, xv), 41 * min + 23000, xv);
    expect(mt.overtimeMs, 83000);
    expect(formatClock(mt.matchClockMs), '41:23');
  });

  test('ADJUST corrige solo hacia delante y limpia la integridad degradada', () {
    final log = play(xv, [(0, const PeriodStart(PeriodId.h1)), (5 * min, const IntegrityLost(30000)), (6 * min, const Adjust(20000))]);
    final at5 = foldClock(log, xv, upTo: 5 * min);
    expect(matchTimeAt(at5, 5 * min, xv).integrity, TimeIntegrity.degraded);
    expect(matchTimeAt(at5, 5 * min, xv).periodElapsedMs, 5 * min);
    final s = foldClock(log, xv);
    expect(s.integrity, TimeIntegrity.ok);
    expect(matchTimeAt(s, 7 * min, xv).periodElapsedMs, 7 * min + 20000);
  });

  test('transiciones ilegales se rechazan', () {
    final ht = play(xv, [(0, const PeriodStart(PeriodId.h1)), (40 * min, const PeriodEnd(PeriodEndNext.interval))]);
    expect(() => appendClockEvent(ht, const TimeOff(), 41 * min, xv), throwsClock(ClockError.invalidTransition));
    expect(() => appendClockEvent(ht, const PeriodStart(PeriodId.et1), 41 * min, xv), throwsClock(ClockError.wrongPeriodOrder));
    expect(() => appendClockEvent(ht, const PeriodStart(PeriodId.h2), 39 * min, xv), throwsClock(ClockError.nonMonotonicTime));
    final h2 = appendClockEvent(ht, const PeriodStart(PeriodId.h2), 55 * min, xv);
    expect(() => appendClockEvent(h2, const PeriodEnd(PeriodEndNext.interval), 95 * min, xv), throwsClock(ClockError.noExtraTimeConfigured));
    expect(foldClock(appendClockEvent(h2, const PeriodEnd(PeriodEndNext.fullTime), 95 * min, xv), xv).status, ClockStatus.fullTime);
  });

  test('prórroga y muerte súbita solo si la categoría la define', () {
    final log = play(xvKo, [
      (0, const PeriodStart(PeriodId.h1)),
      (40 * min, const PeriodEnd(PeriodEndNext.interval)),
      (55 * min, const PeriodStart(PeriodId.h2)),
      (95 * min, const PeriodEnd(PeriodEndNext.interval)),
      (100 * min, const PeriodStart(PeriodId.et1)),
    ]);
    expect(formatClock(matchTimeAt(foldClock(log, xvKo), 101 * min, xvKo).matchClockMs), '81:00');
  });

  test('VOID deshace solo el último evento efectivo', () {
    final log = play(xv, [(0, const PeriodStart(PeriodId.h1)), (10 * min, const TimeOff())]);
    expect(() => appendClockEvent(log, const VoidEvent(1), 11 * min, xv), throwsClock(ClockError.nothingToVoid));
    final undone = appendClockEvent(log, const VoidEvent(2), 11 * min, xv);
    final s = foldClock(undone, xv);
    expect(s.status, ClockStatus.running);
    expect(matchTimeAt(s, 12 * min, xv).periodElapsedMs, 12 * min);
    expect(undone.length, 3);
  });

  test('presets R6: duraciones y sin-bin exactos', () {
    expect({for (final c in kCategoryPresets) c.code: (c.format, c.periodLengthMin, c.sinBinMin)}, {
      'SM_DHCAT_1_2_3': (GameFormat.xv, 40, 10),
      'SM_3AB_4': (GameFormat.xv, 35, 10),
      'SF_DHCAT_1': (GameFormat.xv, 40, 10),
      'SF_ABC_2': (GameFormat.xv, 35, 10),
      'M18': (GameFormat.xv, 35, 5),
      'M16': (GameFormat.xv, 35, 5),
      'M14': (GameFormat.xv, 30, 5),
      'SEVENS': (GameFormat.sevens, 7, 2),
    });
    expect(kCategoryPresets.every((c) => c.extraTime == null), isTrue);
    expect(() => categoryPreset('M12'), throwsArgumentError);
  });

  test('el reloj usa la duración del preset: M14 cumple a los 30:00 y 7s a los 07:00', () {
    final m14 = categoryPreset('M14');
    final log = play(m14, [(0, const PeriodStart(PeriodId.h1)), (31 * min, const PeriodEnd(PeriodEndNext.interval)), (40 * min, const PeriodStart(PeriodId.h2))]);
    final mt = matchTimeAt(foldClock(log, m14), 71 * min, m14);
    expect(formatClock(mt.matchClockMs), '61:00');
    expect(mt.overtimeMs, 1 * min);
    final s7 = categoryPreset('SEVENS');
    final l7 = play(s7, [(0, const PeriodStart(PeriodId.h1))]);
    expect(matchTimeAt(foldClock(l7, s7), 7 * min + 20000, s7).overtimeMs, 20000);
  });

  test('quickTagDefaults coincide con usecases.ts', () {
    final p = quickTagDefaults(QuickPolarity.positive);
    expect((p.verdict, p.impact, p.impactConfirmed), (Verdict.correct, ImpactLevel.low, false));
    final n = quickTagDefaults(QuickPolarity.negative);
    expect((n.verdict, n.impact, n.impactConfirmed), (Verdict.pending, ImpactLevel.medium, false));
    final r = quickTagDefaults(QuickPolarity.review, ImpactLevel.high);
    expect((r.verdict, r.impact, r.impactConfirmed), (Verdict.pending, ImpactLevel.high, true));
  });
}
