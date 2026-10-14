// Base de datos local (Drift). El esquema vive en schema.drift, copia de persistence/schema.sql.

import 'package:drift/drift.dart';

import 'connection.dart';
import 'migrations.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {'schema.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Base de datos de la app: archivo SQLite en el dispositivo (isolate de fondo) o, en la versión
  /// HTML de pruebas, SQLite en WebAssembly (ver connection.dart).
  factory AppDatabase.onDevice() => AppDatabase(openAppConnection());

  @override
  int get schemaVersion => 5; // = PRAGMA user_version de persistence/schema.sql

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // Cada paso comprueba si ya está hecho: el número de versión no es de fiar si una
          // versión antigua de la app abrió la base de datos (lo rebaja sin tocar las tablas).
          //
          // v2 → v3: marcador e infracción de cada incidencia. Solo añade: los partidos ya
          // registrados en el móvil se conservan tal cual.
          if (from < 3) {
            for (final col in [incident.infractionCode, incident.infractionCustom, incident.infractionLawRef]) {
              if (!await sqliteColumnExists(this, 'incident', col.name)) await m.addColumn(incident, col);
            }
            await m.drop(incidentAudit);
            await m.createTrigger(incidentAudit);
            if (!await sqliteObjectExists(this, 'table', 'score_event')) await m.createTable(scoreEvent);
            for (final t in [scoreEventVoidOnly, scoreEventNoDelete, scoreEventLockedInsert, scoreEventLockedUpdate]) {
              if (!await sqliteObjectExists(this, 'trigger', t.entityName)) await m.createTrigger(t);
            }
          }
          // v3 → v4: cada sanción registrada pasa a ser una incidencia con su decisión tomada
          // (así se puede valorar) y la tabla sanction_event desaparece. Si no existe, no hace nada.
          if (from < 4) await migrateSanctionsToIncidents(this);
          // v4 → v5: rúbrica CARC (escala E/C/N/U), dificultad real y recomendación de nivel en
          // el informe, y preferencias de la app. Los informes cerrados no se tocan.
          if (from < 5) await migrateToCarcRubric(this, m);
        },
        beforeOpen: (details) async {
          // Integridad referencial y durabilidad (spec §3.1): con synchronous=FULL cada
          // transacción confirmada sobrevive a un apagado por batería, no solo a un cierre de la app.
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = FULL');
        },
      );
}
