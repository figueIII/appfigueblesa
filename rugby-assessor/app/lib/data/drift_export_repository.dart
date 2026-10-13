// Lectura de un informe cerrado para exportarlo y registro de cada exportación (tabla export_log).

import 'package:drift/drift.dart';

import '../export/export_document.dart';
import 'codecs.dart';
import 'db/app_database.dart';
import 'drift_live_session_repository.dart';

abstract interface class ExportRepository {
  Future<ExportSource> loadExportSource(String assessmentId);
  Future<void> logExport({
    required String id,
    required String assessmentId,
    required int version,
    required String format, // JSON | PDF
    required String relativePath,
    required String sha256,
  });
}

class DriftExportRepository implements ExportRepository {
  DriftExportRepository(this.db) : _live = DriftLiveSessionRepository(db);
  final AppDatabase db;
  final DriftLiveSessionRepository _live;

  @override
  Future<ExportSource> loadExportSource(String assessmentId) async {
    final a = await (db.select(db.assessment)..where((t) => t.id.equals(assessmentId))).getSingle();
    final referee = await (db.select(db.official)..where((t) => t.id.equals(a.refereeId))).getSingle();
    final assessor = await (db.select(db.assessorProfile)..where((t) => t.id.equals(a.assessorId))).getSingle();
    // Versión vigente: la de mayor número que no esté sustituida.
    final report = await (db.select(db.report)
          ..where((t) => t.assessmentId.equals(assessmentId) & t.status.isNotValue('SUPERSEDED'))
          ..orderBy([(t) => OrderingTerm.desc(t.version)])
          ..limit(1))
        .getSingle();
    final live = await _live.load(assessmentId);
    return ExportSource(
      assessmentId: a.id,
      competition: a.competition,
      round: a.round,
      category: decodeCategoryConfig(a.categoryJson),
      kickoffLocal: a.kickoffLocal,
      kickoffTz: a.kickoffTz,
      venue: a.venue,
      homeTeam: a.homeTeam,
      awayTeam: a.awayTeam,
      finalScoreHome: a.finalScoreHome,
      finalScoreAway: a.finalScoreAway,
      observationMode: a.observationMode,
      difficulty: a.difficulty,
      refereeId: referee.id,
      refereeName: referee.fullName,
      refereeLicence: referee.federationLicence,
      refereeGrade: referee.grade,
      ar1Name: a.ar1Name,
      ar2Name: a.ar2Name,
      assessorId: assessor.id,
      assessorName: assessor.fullName,
      assessorLicence: assessor.federationLicence,
      reportVersion: report.version,
      reportStatus: report.status,
      canonicalJson: report.canonicalJson,
      contentHash: report.contentHash,
      incidents: live.incidents,
      scores: live.scores,
      sanctions: live.sanctions,
    );
  }

  @override
  Future<void> logExport({
    required String id,
    required String assessmentId,
    required int version,
    required String format,
    required String relativePath,
    required String sha256,
  }) =>
      db.into(db.exportLog).insert(ExportLogCompanion.insert(
            id: id,
            assessmentId: assessmentId,
            version: version,
            format: format,
            relativePath: relativePath,
            sha256: sha256,
            createdAt: DateTime.now().toUtc().toIso8601String(),
          ));
}
