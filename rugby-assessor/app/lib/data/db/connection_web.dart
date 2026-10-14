import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

/// Versión HTML de pruebas: el mismo esquema SQLite, compilado a WebAssembly (sqlite3.wasm junto
/// a la página). Los datos se guardan en IndexedDB del navegador, así que sobreviven a una recarga;
/// si el navegador no lo permite, la base de datos vive solo en memoria.
QueryExecutor openAppConnection() => LazyDatabase(() async {
      final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
      VirtualFileSystem fs;
      try {
        fs = await IndexedDbFileSystem.open(dbName: 'refassess');
      } catch (_) {
        fs = InMemoryFileSystem();
      }
      sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
      return WasmDatabase(sqlite3: sqlite3, path: '/refassess.sqlite');
    });
