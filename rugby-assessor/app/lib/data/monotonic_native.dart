// Fuente monotónica del móvil: clock_gettime por FFI (ver session_time.dart).

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'session_time.dart';

final class _Timespec extends Struct {
  @Long()
  external int tvSec;
  @Long()
  external int tvNsec;
}

typedef _ClockGettimeNative = Int32 Function(Int32 clockId, Pointer<_Timespec> ts);
typedef _ClockGettime = int Function(int clockId, Pointer<_Timespec> ts);

class NativeMonotonicSource implements MonotonicSource {
  NativeMonotonicSource._(this._clockGettime, this._clockId);

  factory NativeMonotonicSource() {
    final fn = DynamicLibrary.process().lookupFunction<_ClockGettimeNative, _ClockGettime>('clock_gettime');
    // CLOCK_BOOTTIME = 7 (Linux/Android); CLOCK_MONOTONIC = 6 (Darwin, avanza en reposo).
    final id = (Platform.isIOS || Platform.isMacOS) ? 6 : 7;
    return NativeMonotonicSource._(fn, id);
  }

  final _ClockGettime _clockGettime;
  final int _clockId;
  final Pointer<_Timespec> _ts = calloc<_Timespec>(); // vive lo que la app: no se libera
  String? _bootId;

  @override
  int nowMs() {
    if (_clockGettime(_clockId, _ts) != 0) throw StateError('clock_gettime($_clockId) falló');
    return _ts.ref.tvSec * 1000 + _ts.ref.tvNsec ~/ 1000000;
  }

  @override
  String bootId() => _bootId ??= _readBootId();

  String _readBootId() {
    // Linux/Android: UUID del arranque, mantenido por el kernel.
    try {
      final id = File('/proc/sys/kernel/random/boot_id').readAsStringSync().trim();
      if (id.isNotEmpty) return id;
    } catch (_) {/* no legible (p. ej. iOS o política SELinux): se usa la aproximación */}
    return approxBootId(DateTime.now().toUtc().millisecondsSinceEpoch, nowMs());
  }
}

