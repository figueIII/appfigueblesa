// Partidos: alta desde el formulario de preparación y listado para la pantalla de inicio.

import 'package:drift/drift.dart';

import '../domain/model.dart';
import '../domain/rubric.dart';
import 'codecs.dart';
import 'db/app_database.dart';
import 'drift_live_session_repository.dart';

/// En qué punto del flujo está un partido (y adónde lleva al abrirlo).
enum MatchStage {
  /// Preparado o en juego → pantalla de directo.
  inProgress,

  /// Terminado, pendiente de revisión y evaluación → revisión post-partido.
  pendingReview,

  /// Informe cerrado → evaluación en solo lectura, con exportación.
  finalized,
}

MatchStage stageFor(String status) => switch (status) {
      'READY' || 'LIVE' => MatchStage.inProgress,
      'POST_MATCH' => MatchStage.pendingReview,
      _ => MatchStage.finalized, // FINALIZED · ARCHIVED
    };

class MatchSummary {
  const MatchSummary({
    required this.id,
    required this.status,
    required this.homeTeam,
    required this.awayTeam,
    required this.competition,
    required this.categoryName,
    required this.kickoffLocal,
    required this.venue,
    required this.refereeName,
    required this.markCount,
    this.band,
  });
  final String id;
  final String status; // READY · LIVE · POST_MATCH · FINALIZED · ARCHIVED
  final String homeTeam;
  final String awayTeam;
  final String competition;
  final String categoryName;
  final String kickoffLocal;
  final String venue;
  final String refereeName;
  final int markCount;
  final BandCode? band; // solo con el informe cerrado

  MatchStage get stage => stageFor(status);
}

/// Datos del formulario de preparación (ya validados).
class MatchSetupInput {
  const MatchSetupInput({
    required this.category,
    required this.homeTeam,
    required this.awayTeam,
    required this.refereeName,
    required this.assessorName,
    required this.kickoffLocal,
    required this.venue,
    this.competition = '',
    this.ar1Name,
    this.ar2Name,
    this.difficulty,
  });
  final CategoryConfig category;
  final String homeTeam;
  final String awayTeam;
  final String refereeName;
  final String assessorName;
  final DateTime kickoffLocal;
  final String venue;
  final String competition;
  final String? ar1Name;
  final String? ar2Name;
  final String? difficulty; // LOW · MEDIUM · HIGH · VERY_HIGH
}

abstract interface class MatchRepository {
  Future<List<MatchSummary>> listMatches();
  Future<String> createMatch(MatchSetupInput input);

  /// Nombres ya usados (autocompletado: el mismo árbitro debe escribirse igual entre partidos).
  Future<List<String>> knownRefereeNames();
  Future<List<String>> knownAssessorNames();

  /// Evaluador del último partido creado (para rellenar el formulario).
  Future<String?> lastAssessorName();
}

class DriftMatchRepository implements MatchRepository {
  DriftMatchRepository(this.db, this._setup);
  final AppDatabase db;
  final AssessmentSetup _setup;

  @override
  Future<String> createMatch(MatchSetupInput i) => _setup.createLiveAssessment(
        category: i.category,
        // La competición es opcional en el formulario; el formato exige texto: se usa la categoría.
        competition: i.competition.trim().isEmpty ? i.category.name : i.competition,
        venue: i.venue,
        homeTeam: i.homeTeam,
        awayTeam: i.awayTeam,
        refereeName: i.refereeName,
        assessorName: i.assessorName,
        kickoffLocal: i.kickoffLocal,
        ar1Name: i.ar1Name,
        ar2Name: i.ar2Name,
        difficulty: i.difficulty,
      );

  @override
  Future<List<MatchSummary>> listMatches() async {
    final rows = await db.customSelect(
      'SELECT a.id, a.status, a.home_team, a.away_team, a.competition, a.category_json, a.kickoff_local, a.venue, '
      '       o.full_name AS referee, '
      "       (SELECT COUNT(*) FROM incident i WHERE i.assessment_id = a.id AND i.status <> 'VOID') AS marks, "
      "       (SELECT r.band FROM report r WHERE r.assessment_id = a.id AND r.status = 'FINALIZED' "
      '        ORDER BY r.version DESC LIMIT 1) AS band '
      'FROM assessment a JOIN official o ON o.id = a.referee_id '
      'ORDER BY a.kickoff_local DESC, a.created_at DESC',
      readsFrom: {db.assessment, db.official, db.incident, db.report},
    ).get();
    return [
      for (final r in rows)
        MatchSummary(
          id: r.read<String>('id'),
          status: r.read<String>('status'),
          homeTeam: r.read<String>('home_team'),
          awayTeam: r.read<String>('away_team'),
          competition: r.read<String>('competition'),
          categoryName: decodeCategoryConfig(r.read<String>('category_json')).name,
          kickoffLocal: r.read<String>('kickoff_local'),
          venue: r.read<String>('venue'),
          refereeName: r.read<String>('referee'),
          markCount: r.read<int>('marks'),
          band: switch (r.readNullable<String>('band')) {
            'BELOW' => BandCode.below,
            'AT' => BandCode.at,
            'ABOVE' => BandCode.above,
            _ => null,
          },
        ),
    ];
  }

  @override
  Future<List<String>> knownRefereeNames() async =>
      [for (final o in await (db.select(db.official)..orderBy([(t) => OrderingTerm.asc(t.fullName)])).get()) o.fullName];

  @override
  Future<List<String>> knownAssessorNames() async =>
      [for (final a in await (db.select(db.assessorProfile)..orderBy([(t) => OrderingTerm.asc(t.fullName)])).get()) a.fullName];

  @override
  Future<String?> lastAssessorName() async {
    final row = await db.customSelect(
      'SELECT p.full_name AS name FROM assessment a JOIN assessor_profile p ON p.id = a.assessor_id '
      'ORDER BY a.created_at DESC LIMIT 1',
      readsFrom: {db.assessment, db.assessorProfile},
    ).getSingleOrNull();
    return row?.read<String>('name');
  }
}
