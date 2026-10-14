// Reloj de sesión tolerante a cierres de la app y a reinicios del dispositivo (spec §2.1.1).
//
//  · Fuente monotónica que SIGUE CONTANDO con el móvil en reposo:
//      Android/Linux → clock_gettime(CLOCK_BOOTTIME)  (= SystemClock.elapsedRealtime)
//      iOS/macOS     → clock_gettime(CLOCK_MONOTONIC) (en Darwin incluye el reposo)
//    Se lee por FFI de forma síncrona: now() se puede llamar en cada frame.
//  · Ancla por arranque (tabla session_time_anchor): t_sesión = sesión_ancla + (mono − mono_ancla).
//      - Cierre de la app / el sistema la mata → mismo arranque, misma ancla: el tiempo es EXACTO.
//      - Reinicio del móvil → la fuente vuelve a cero: ancla nueva cuyo origen se estima con la
//        hora de pared desde el último instante guardado. Queda marcada como estimada y, si el
//        reloj de partido estaba en marcha, se emite INTEGRITY_LOST hasta que el evaluador ajuste.

import '../core/platform_ports.dart';

// La fuente concreta depende de la plataforma: FFI en el móvil, hora de pared en el navegador
// (la versión web solo sirve para probar la app en un HTML, no para evaluar partidos).
export 'monotonic_native.dart' if (dart.library.js_interop) 'monotonic_web.dart';

// ───────────── Fuente monotónica ─────────────

abstract interface class MonotonicSource {
  /// Milisegundos desde el arranque del dispositivo, incluido el tiempo en reposo.
  int nowMs();

  /// Identificador del arranque actual (cambia en cada reinicio).
  String bootId();
}

/// Aproximación: instante de arranque en hora de pared, redondeado al minuto.
/// Se compara con tolerancia (ver [sameBoot]).
String approxBootId(int wallMs, int monoMs) => 'approx:${((wallMs - monoMs) / 60000).round() * 60000}';

/// Tolerancia para comparar aproximaciones: absorbe ajustes NTP y el redondeo.
const _approxToleranceMs = 120000;

bool sameBoot(String storedOrCurrent, String other) {
  // Las anclas pueden llevar sufijo "#n" para no repetir clave primaria: se compara la base.
  final a = storedOrCurrent.split('#').first, b = other.split('#').first;
  if (a == b) return true;
  if (a.startsWith('approx:') && b.startsWith('approx:')) {
    final x = int.tryParse(a.substring(7)), y = int.tryParse(b.substring(7));
    return x != null && y != null && (x - y).abs() <= _approxToleranceMs;
  }
  return false;
}

// ───────────── Anclas ─────────────

class SessionAnchor {
  const SessionAnchor({
    required this.bootId,
    required this.monoAtAnchor,
    required this.sessionAtAnchor,
    required this.wallUtcAtAnchor,
    required this.estimated,
  });
  final String bootId;
  final int monoAtAnchor;
  final int sessionAtAnchor;
  final DateTime wallUtcAtAnchor;
  final bool estimated;
}

/// Último instante guardado de la sesión (evento de reloj o marca), con su hora de pared.
class TimePoint {
  const TimePoint(this.sessionMs, this.wallUtc);
  final int sessionMs;
  final DateTime wallUtc;
}

class AnchorResolution {
  const AnchorResolution({required this.anchor, required this.isNew, this.estimatedGapMs});
  final SessionAnchor anchor;
  final bool isNew;

  /// Hueco estimado desde el último instante guardado (solo tras un reinicio).
  final int? estimatedGapMs;
  bool get estimated => isNew && anchor.estimated;
}

/// Decide el ancla para este arranque. Pura: toda la entrada llega como parámetro.
AnchorResolution resolveAnchor({
  required List<SessionAnchor> anchors,
  required TimePoint? lastPoint,
  required int monoNow,
  required String bootId,
  required DateTime wallNow,
}) {
  final sorted = [...anchors]..sort((a, b) => a.sessionAtAnchor.compareTo(b.sessionAtAnchor));
  final latest = sorted.isEmpty ? null : sorted.last;

  // Mismo arranque que el ancla más reciente (y la fuente no ha retrocedido): exacto.
  if (latest != null && sameBoot(latest.bootId, bootId) && monoNow >= latest.monoAtAnchor) {
    return AnchorResolution(anchor: latest, isNew: false);
  }

  // Primera apertura de la sesión: origen 0, nada que estimar.
  if (latest == null && lastPoint == null) {
    return AnchorResolution(
      anchor: SessionAnchor(bootId: bootId, monoAtAnchor: monoNow, sessionAtAnchor: 0, wallUtcAtAnchor: wallNow, estimated: false),
      isNew: true,
    );
  }

  // Reinicio: se extrapola con la hora de pared desde el instante guardado más reciente.
  final candidates = [
    ?lastPoint,
    if (latest != null) TimePoint(latest.sessionAtAnchor, latest.wallUtcAtAnchor),
  ]..sort((a, b) => a.sessionMs.compareTo(b.sessionMs));
  final ref = candidates.last;
  final gap = wallNow.difference(ref.wallUtc).inMilliseconds;
  final safeGap = gap < 0 ? 0 : gap; // reloj de pared atrasado: nunca retroceder
  final usedIds = {for (final a in anchors) a.bootId};
  var key = bootId;
  for (var n = 2; usedIds.contains(key); n++) {
    key = '$bootId#$n'; // la clave primaria es (assessment_id, boot_id)
  }
  return AnchorResolution(
    anchor: SessionAnchor(
      bootId: key,
      monoAtAnchor: monoNow,
      sessionAtAnchor: ref.sessionMs + safeGap,
      wallUtcAtAnchor: wallNow,
      estimated: true,
    ),
    isNew: true,
    estimatedGapMs: safeGap,
  );
}

// ───────────── Persistencia de anclas y reloj de producción ─────────────

abstract interface class SessionTimeStore {
  Future<List<SessionAnchor>> loadAnchors(String assessmentId);
  Future<TimePoint?> lastTimePoint(String assessmentId);
  Future<void> insertAnchor(String assessmentId, SessionAnchor anchor);
}

class AnchoredSessionClock implements SessionClock {
  AnchoredSessionClock(this._mono, this.anchor, {DateTime Function()? wallNow}) : _wall = wallNow ?? _systemWall;
  final MonotonicSource _mono;
  final SessionAnchor anchor;
  final DateTime Function() _wall;

  static DateTime _systemWall() => DateTime.now().toUtc();

  @override
  int now() => anchor.sessionAtAnchor + (_mono.nowMs() - anchor.monoAtAnchor);

  @override
  DateTime wallUtc() => _wall();

  @override
  TimeSample sample() {
    final mono = _mono.nowMs();
    return TimeSample(
      sessionMs: anchor.sessionAtAnchor + (mono - anchor.monoAtAnchor),
      monoMs: mono,
      bootId: anchor.bootId,
      wallUtc: wallUtc(),
    );
  }
}

/// Abre (o recupera) el reloj de una evaluación. El ancla nueva se guarda ANTES de usarse.
Future<(AnchoredSessionClock, AnchorResolution)> openSessionClock({
  required String assessmentId,
  required SessionTimeStore store,
  required MonotonicSource mono,
  DateTime Function()? wallNow,
}) async {
  final wall = wallNow ?? AnchoredSessionClock._systemWall;
  final resolution = resolveAnchor(
    anchors: await store.loadAnchors(assessmentId),
    lastPoint: await store.lastTimePoint(assessmentId),
    monoNow: mono.nowMs(),
    bootId: mono.bootId(),
    wallNow: wall(),
  );
  if (resolution.isNew) await store.insertAnchor(assessmentId, resolution.anchor);
  return (AnchoredSessionClock(mono, resolution.anchor, wallNow: wall), resolution);
}
