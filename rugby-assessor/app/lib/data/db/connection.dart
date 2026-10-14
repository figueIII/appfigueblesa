// Conexión a la base de datos según la plataforma: archivo SQLite nativo en el móvil y SQLite en
// WebAssembly (persistido en IndexedDB) en la versión HTML de pruebas.
export 'connection_native.dart' if (dart.library.js_interop) 'connection_web.dart';
