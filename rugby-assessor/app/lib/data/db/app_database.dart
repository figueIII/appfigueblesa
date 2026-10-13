// Base de datos local (Drift). El esquema vive en schema.drift, copia de persistence/schema.sql.

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {'schema.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Base de datos de la app en el almacenamiento privado del dispositivo, en un isolate de
  /// fondo: las escrituras nunca bloquean el frame de la UI.
  factory AppDatabase.onDevice() => AppDatabase(driftDatabase(name: 'refassess'));

  @override
  int get schemaVersion => 2; // = PRAGMA user_version de persistence/schema.sql

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // Integridad referencial y durabilidad (spec §3.1): con synchronous=FULL cada
          // transacción confirmada sobrevive a un apagado por batería, no solo a un cierre de la app.
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = FULL');
        },
      );
}
