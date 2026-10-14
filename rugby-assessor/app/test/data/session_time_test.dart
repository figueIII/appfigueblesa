import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/data/session_time.dart';

final t0 = DateTime.utc(2026, 10, 17, 15);
const min = 60000;

SessionAnchor anchor(String boot, int mono, int session, DateTime wall, {bool estimated = false}) =>
    SessionAnchor(bootId: boot, monoAtAnchor: mono, sessionAtAnchor: session, wallUtcAtAnchor: wall, estimated: estimated);

class FakeMono implements MonotonicSource {
  FakeMono(this.ms, this.boot);
  int ms;
  String boot;
  @override
  int nowMs() => ms;
  @override
  String bootId() => boot;
}

void main() {
  group('resolveAnchor', () {
    test('primera apertura: origen 0, no estimado', () {
      final r = resolveAnchor(anchors: const [], lastPoint: null, monoNow: 123456, bootId: 'A', wallNow: t0);
      expect((r.isNew, r.estimated, r.anchor.sessionAtAnchor, r.anchor.monoAtAnchor), (true, false, 0, 123456));
    });

    test('la app se cerró en el mismo arranque: se reutiliza el ancla y el tiempo es exacto', () {
      final a = anchor('A', 1000, 0, t0);
      final r = resolveAnchor(anchors: [a], lastPoint: TimePoint(30 * min, t0), monoNow: 1000 + 45 * min, bootId: 'A', wallNow: t0);
      expect(r.isNew, isFalse);
      expect(identical(r.anchor, a), isTrue);
      final clock = AnchoredSessionClock(FakeMono(1000 + 45 * min, 'A'), r.anchor);
      expect(clock.now(), 45 * min, reason: 'session = 0 + (mono − mono_ancla)');
    });

    test('reinicio del móvil: ancla nueva estimada con la hora de pared desde el último instante', () {
      final a = anchor('A', 1000, 0, t0);
      final last = TimePoint(30 * min, t0.add(const Duration(minutes: 30)));
      final r = resolveAnchor(anchors: [a], lastPoint: last, monoNow: 8000, bootId: 'B', wallNow: t0.add(const Duration(minutes: 34)));
      expect((r.isNew, r.estimated, r.estimatedGapMs), (true, true, 4 * min));
      expect(r.anchor.sessionAtAnchor, 34 * min);
      expect(r.anchor.monoAtAnchor, 8000);
      expect(r.anchor.bootId, 'B');
    });

    test('hora de pared atrasada tras el reinicio: el eje de sesión nunca retrocede', () {
      final last = TimePoint(30 * min, t0);
      final r = resolveAnchor(anchors: [anchor('A', 0, 0, t0)], lastPoint: last, monoNow: 10, bootId: 'B', wallNow: t0.subtract(const Duration(hours: 2)));
      expect((r.estimatedGapMs, r.anchor.sessionAtAnchor), (0, 30 * min));
    });

    test('mismo boot_id pero la fuente retrocede: se trata como reinicio y la clave no se repite', () {
      final r = resolveAnchor(anchors: [anchor('A', 50000, 0, t0)], lastPoint: TimePoint(1000, t0), monoNow: 10, bootId: 'A', wallNow: t0.add(const Duration(seconds: 61)));
      expect((r.isNew, r.anchor.bootId), (true, 'A#2'));
      // Referencia = el instante guardado de mayor sesión (la marca en 1 s) + 61 s de pared.
      expect(r.anchor.sessionAtAnchor, 62000);
    });

    test('solo cuenta el ancla MÁS RECIENTE: volver a un arranque antiguo es imposible', () {
      final anchors = [anchor('A', 0, 0, t0), anchor('B', 0, 10 * min, t0.add(const Duration(minutes: 10)), estimated: true)];
      final r = resolveAnchor(anchors: anchors, lastPoint: null, monoNow: 99 * min, bootId: 'A', wallNow: t0.add(const Duration(minutes: 11)));
      expect((r.isNew, r.anchor.bootId), (true, 'A#2'));
    });

    test('ids aproximados (sin /proc): mismo arranque dentro de ±2 min, distinto fuera', () {
      expect(sameBoot('approx:1000000', 'approx:1060000'), isTrue);
      expect(sameBoot('approx:1000000', 'approx:1300000'), isFalse);
      expect(sameBoot('approx:1000000#2', 'approx:1000000'), isTrue);
      expect(sameBoot('abc', 'abd'), isFalse);
    });
  });

  group('NativeMonotonicSource (FFI, en el anfitrión Linux)', () {
    test('CLOCK_BOOTTIME avanza al ritmo real y el boot_id es el del kernel', () async {
      final src = NativeMonotonicSource();
      final sw = Stopwatch()..start();
      final a = src.nowMs();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final b = src.nowMs();
      sw.stop();
      expect(b - a, closeTo(sw.elapsedMilliseconds, 15));
      final procId = File('/proc/sys/kernel/random/boot_id').readAsStringSync().trim();
      expect(src.bootId(), procId);
      expect(a, greaterThan(0));
    }, skip: !Platform.isLinux);
  });

  test('openSessionClock guarda el ancla nueva antes de usarla y la reutiliza al reabrir', () async {
    final store = _MemStore();
    final mono = FakeMono(5000, 'A');
    final (c1, r1) = await openSessionClock(assessmentId: 'x', store: store, mono: mono, wallNow: () => t0);
    expect((r1.isNew, store.anchors.length, c1.now()), (true, 1, 0));
    mono.ms += 90000;
    final (c2, r2) = await openSessionClock(assessmentId: 'x', store: store, mono: mono, wallNow: () => t0);
    expect((r2.isNew, store.anchors.length, c2.now()), (false, 1, 90000));
  });
}

class _MemStore implements SessionTimeStore {
  final anchors = <SessionAnchor>[];
  @override
  Future<void> insertAnchor(String assessmentId, SessionAnchor anchor) async => anchors.add(anchor);
  @override
  Future<TimePoint?> lastTimePoint(String assessmentId) async => null;
  @override
  Future<List<SessionAnchor>> loadAnchors(String assessmentId) async => [...anchors];
}
