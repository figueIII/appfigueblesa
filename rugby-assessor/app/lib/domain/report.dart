// Informe del árbitro: borrador editable, reglas de cierre (port de validateForFinalization en
// domain/usecases.ts) y representación canónica para el hash de integridad (spec §3.3).

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'model.dart';
import 'review.dart';
import 'rubric.dart';
import 'scoring.dart';

// ───────────── Modelo del borrador ─────────────

class CriterionEvaluation {
  const CriterionEvaluation({required this.criterionCode, this.finalBand, this.notObserved = false, this.justification = ''});
  final String criterionCode;
  final BandCode? finalBand;
  final bool notObserved;
  final String justification;

  CriterionEvaluation copyWith({Object? finalBand = _keep, bool? notObserved, String? justification}) => CriterionEvaluation(
        criterionCode: criterionCode,
        finalBand: identical(finalBand, _keep) ? this.finalBand : finalBand as BandCode?,
        notObserved: notObserved ?? this.notObserved,
        justification: justification ?? this.justification,
      );
}

const Object _keep = Object();

enum FindingKind { strength, development }

class Finding {
  const Finding({required this.id, required this.kind, required this.criterionCode, required this.text, this.evidenceIncidentIds = const []});
  final String id;
  final FindingKind kind;
  final String criterionCode;
  final String text;
  final List<String> evidenceIncidentIds;

  Finding copyWith({String? criterionCode, String? text}) =>
      Finding(id: id, kind: kind, criterionCode: criterionCode ?? this.criterionCode, text: text ?? this.text, evidenceIncidentIds: evidenceIncidentIds);
}

/// Recomendación para el próximo informe (vive por árbitro, spec §1.4). Opcional.
class ActionPoint {
  const ActionPoint({required this.id, required this.criterionCode, required this.text, required this.successIndicator});
  final String id;
  final String criterionCode;
  final String text;
  final String successIndicator;

  ActionPoint copyWith({String? criterionCode, String? text, String? successIndicator}) => ActionPoint(
        id: id,
        criterionCode: criterionCode ?? this.criterionCode,
        text: text ?? this.text,
        successIndicator: successIndicator ?? this.successIndicator,
      );
}

enum ActionPointReviewStatus { achieved, partial, notAchieved, notObserved }

/// Recomendación abierta de un informe anterior del mismo árbitro.
class PreviousActionPoint {
  const PreviousActionPoint({required this.id, required this.criterionCode, required this.text, required this.successIndicator});
  final String id;
  final String criterionCode;
  final String text;
  final String successIndicator;
}

class ActionPointReview {
  const ActionPointReview({required this.actionPointId, required this.status, this.comment = ''});
  final String actionPointId;
  final ActionPointReviewStatus status;
  final String comment;
}

/// Recomendación del CARC sobre el nivel de los próximos partidos.
enum LevelRecommendation {
  /// ↑ Probar partidos de más exigencia.
  up,

  /// = Mantener en partidos similares.
  same,

  /// ↓ Reducir la exigencia de los partidos.
  down,
}

String encodeLevelRecommendation(LevelRecommendation r) => switch (r) {
      LevelRecommendation.up => 'UP',
      LevelRecommendation.same => 'SAME',
      LevelRecommendation.down => 'DOWN',
    };

LevelRecommendation? decodeLevelRecommendation(String? s) => switch (s) {
      'UP' => LevelRecommendation.up,
      'SAME' => LevelRecommendation.same,
      'DOWN' => LevelRecommendation.down,
      _ => null,
    };

/// Dificultad del partido (estimada al prepararlo, real al cerrar el informe).
const List<String> kDifficultyCodes = ['LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH'];

// ───────────── Avisos de cierre ─────────────
//
// Desde la rúbrica CARC (v3) NADA bloquea el cierre: ni las bandas, ni las justificaciones, ni el
// resumen, las fortalezas, las áreas de mejora o las recomendaciones. La app solo AVISA de lo que
// falta antes de cerrar (port de validateForFinalization en domain/usecases.ts, todo WARNING).

enum CloseIssueCode {
  /// Hay marcas sin veredicto: no cuentan en la sugerencia.
  incidentVerdictPending,

  /// Competencia sin valorar (ni banda ni "no observado"): no cuenta en la valoración.
  criterionBandMissing,

  /// Recomendación de un informe anterior sin revisar.
  previousActionPointNotReviewed,
}

class CloseIssue {
  const CloseIssue(this.code, {this.criterionCode, this.incidentId, this.itemId});
  final CloseIssueCode code;
  final String? criterionCode;
  final String? incidentId;
  final String? itemId;

  @override
  String toString() => 'CloseIssue(${code.name}${criterionCode != null ? ' $criterionCode' : ''})';
}

/// ¿Está valorada la competencia? (banda elegida o "no observado"). Solo informa del progreso.
bool isRated(CriterionEvaluation? e) => e != null && (e.notObserved || e.finalBand != null);

/// ¿Conviene justificar esta elección? (banda distinta de la sugerida o por encima del tope).
/// Es una recomendación: la justificación nunca es obligatoria.
bool needsLongJustification(CriterionEvaluation? e, SuggestedScore s) {
  final b = e?.finalBand;
  if (b == null) return false;
  return (s.suggestedBand != null && b != s.suggestedBand) || (s.capBand != null && bandRank(b) > bandRank(s.capBand!));
}

/// Avisos antes de cerrar. Nunca impiden cerrar: la app los enseña y el evaluador decide.
List<CloseIssue> closeWarnings({
  required AssessmentRubric rubric,
  required Iterable<Incident> incidents,
  required Map<String, CriterionEvaluation> evaluations,
  required List<PreviousActionPoint> openPrevious,
  required Map<String, ActionPointReview> previousReviews,
}) {
  final issues = <CloseIssue>[];
  for (final i in incidents) {
    if (reviewIssues(i).contains(ReviewIssue.verdictPending)) {
      issues.add(CloseIssue(CloseIssueCode.incidentVerdictPending, incidentId: i.id));
    }
  }
  for (final c in rubric.criteria) {
    if (!isRated(evaluations[c.code])) issues.add(CloseIssue(CloseIssueCode.criterionBandMissing, criterionCode: c.code));
  }
  for (final p in openPrevious) {
    if (!previousReviews.containsKey(p.id)) issues.add(CloseIssue(CloseIssueCode.previousActionPointNotReviewed, itemId: p.id));
  }
  return issues;
}

// ───────────── Forma canónica e integridad ─────────────

String encodeBand(BandCode? b) => b == null ? 'null' : bandWireCode(b);

Object? _band(BandCode? b) => b == null ? null : encodeBand(b);

String encodeReviewStatus(ActionPointReviewStatus s) => switch (s) {
      ActionPointReviewStatus.achieved => 'ACHIEVED',
      ActionPointReviewStatus.partial => 'PARTIAL',
      ActionPointReviewStatus.notAchieved => 'NOT_ACHIEVED',
      ActionPointReviewStatus.notObserved => 'NOT_OBSERVED',
    };

/// Objeto `report` del formato de exportación 2.2 (export/assessment-export.schema.json), SIN
/// `status`: es exactamente lo que cubre el hash. Las fortalezas, áreas de mejora y
/// recomendaciones sin texto no se incluyen (son opcionales: un hueco vacío no es contenido).
Map<String, Object?> buildSignedReport({
  required int version,
  required DateTime finalizedAt,
  required AssessmentRubric rubric,
  required Map<String, SuggestedScore> suggestions,
  required Map<String, CriterionEvaluation> evaluations,
  required AggregateResult aggregate,
  required KeyDecisionAccuracy keyDecisions,
  required String summary,
  required List<Finding> findings,
  required List<ActionPoint> actionPoints,
  required List<PreviousActionPoint> openPrevious,
  required Map<String, ActionPointReview> previousReviews,
  String? actualDifficulty,
  LevelRecommendation? levelRecommendation,
}) {
  final written = [for (final f in findings) if (f.text.trim().isNotEmpty) f];
  Map<String, Object?> finding(Finding f) => {'criterionCode': f.criterionCode, 'text': f.text.trim(), 'evidenceIncidentIds': f.evidenceIncidentIds};
  return {
    'version': version,
    'finalizedAt': finalizedAt.toUtc().toIso8601String(),
    'criterionScores': [
      for (final c in rubric.criteria)
        {
          'criterionCode': c.code,
          'suggestedBand': _band(suggestions[c.code]!.suggestedBand),
          'suggested': suggestions[c.code]!.suggested,
          'finalBand': _band(evaluations[c.code]?.notObserved == true ? null : evaluations[c.code]?.finalBand),
          'notObserved': evaluations[c.code]?.notObserved ?? false,
          'justification': (evaluations[c.code]?.justification ?? '').trim(),
          'capBand': _band(suggestions[c.code]!.capBand),
          'evidenceIncidentIds': suggestions[c.code]!.evidenceIncidentIds,
        },
    ],
    'areaScores': [
      for (final a in aggregate.areas) {'areaCode': a.areaCode, 'band': _band(a.band), 'score': a.score},
    ],
    'band': _band(aggregate.band),
    'overallScore': aggregate.overallScore,
    'keyDecisionAccuracy': {'correct': keyDecisions.correct, 'total': keyDecisions.total, 'ratio': keyDecisions.ratio},
    'summary': summary.trim(),
    'actualDifficulty': actualDifficulty,
    'levelRecommendation': levelRecommendation == null ? null : encodeLevelRecommendation(levelRecommendation),
    'strengths': [for (final f in written.where((f) => f.kind == FindingKind.strength)) finding(f)],
    'developmentAreas': [for (final f in written.where((f) => f.kind == FindingKind.development)) finding(f)],
    'actionPoints': [
      for (final a in actionPoints)
        if (a.text.trim().isNotEmpty) {'id': a.id, 'criterionCode': a.criterionCode, 'text': a.text.trim(), 'successIndicator': a.successIndicator.trim()},
    ],
    'previousActionPointReviews': [
      for (final p in openPrevious)
        if (previousReviews[p.id] != null)
          {
            'actionPointId': p.id,
            'text': p.text,
            'status': encodeReviewStatus(previousReviews[p.id]!.status),
            'comment': previousReviews[p.id]!.comment.trim(),
          },
    ],
  };
}

/// JSON canónico, idéntico a canonicalJson de domain/usecases.ts: claves ordenadas, sin
/// espacios, sin claves nulas-ausentes, y números como los imprime JavaScript (7, no 7.0).
String canonicalJson(Object? value) {
  if (value == null || value is bool || value is String) return jsonEncode(value);
  if (value is num) {
    if (value is double && value.isFinite && value == value.truncateToDouble() && value.abs() < 1e21) {
      return value.toInt().toString();
    }
    return jsonEncode(value);
  }
  if (value is List) return '[${value.map(canonicalJson).join(',')}]';
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return '{${keys.map((k) => '${jsonEncode(k)}:${canonicalJson(value[k])}').join(',')}}';
  }
  throw ArgumentError('Valor no serializable: ${value.runtimeType}');
}

String contentHash(Map<String, Object?> signedReport) => sha256.convert(utf8.encode(canonicalJson(signedReport))).toString();
