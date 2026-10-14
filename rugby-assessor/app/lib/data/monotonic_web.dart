// Fuente "monotónica" del navegador, solo para la versión HTML de pruebas.
//
// En el navegador no hay reloj de arranque del dispositivo. Se usa la hora de pared con un
// identificador de arranque fijo: al recargar la página el directo continúa con el tiempo real
// transcurrido, como tras cerrar y abrir la app. No es apto para evaluar partidos reales: un
// cambio de hora del sistema movería el reloj (en el móvil eso no ocurre).

import 'session_time.dart';

class NativeMonotonicSource implements MonotonicSource {
  NativeMonotonicSource();

  @override
  int nowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

  @override
  String bootId() => 'web-browser';
}
