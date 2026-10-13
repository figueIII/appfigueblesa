// Puertos de plataforma. La UI y el controlador dependen de estas interfaces; las
// implementaciones reales usan servicios del sistema y los tests inyectan dobles.

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Eje de tiempo monotónico de la sesión (spec §2.1.1). Nunca la hora de pared.
abstract interface class SessionClock {
  int now();
  DateTime wallUtc();
}

/// Implementación del MVP: Stopwatch es monotónico (no salta si cambia la hora del sistema).
/// La versión con SystemClock.elapsedRealtime + anclas por arranque llega con la capa Drift.
class StopwatchSessionClock implements SessionClock {
  StopwatchSessionClock({int originMs = 0}) : _origin = originMs {
    _sw.start();
  }
  final int _origin;
  final Stopwatch _sw = Stopwatch();
  @override
  int now() => _origin + _sw.elapsedMilliseconds;
  @override
  DateTime wallUtc() => DateTime.now().toUtc();
}

abstract interface class IdGenerator {
  String next();
}

class UuidV7Generator implements IdGenerator {
  static const _uuid = Uuid();
  @override
  String next() => _uuid.v7();
}

/// Patrones hápticos con significado propio, para distinguirlos sin mirar la pantalla.
abstract interface class Haptics {
  void incidentLogged();   // marca registrada
  void refined();          // valoración ✓/✗ aplicada
  void undone();           // marca anulada
  void clockChanged();     // cambio de estado del reloj
  void warning();          // error de guardado o acción no permitida
}

class SystemHaptics implements Haptics {
  const SystemHaptics();
  @override
  void incidentLogged() => HapticFeedback.mediumImpact();
  @override
  void refined() => HapticFeedback.selectionClick();
  @override
  void undone() => HapticFeedback.lightImpact();
  @override
  void clockChanged() => HapticFeedback.heavyImpact();
  @override
  void warning() => HapticFeedback.vibrate();
}

/// Mantener la pantalla encendida durante el directo.
abstract interface class ScreenAwake {
  Future<void> enable();
  Future<void> disable();
}

class WakelockScreenAwake implements ScreenAwake {
  const WakelockScreenAwake();
  @override
  Future<void> enable() => WakelockPlus.enable();
  @override
  Future<void> disable() => WakelockPlus.disable();
}
