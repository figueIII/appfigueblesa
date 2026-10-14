// Documento de exportación (formato 2.1, export/assessment-export.schema.json). PURO: recibe los
// datos del informe cerrado y devuelve el mapa JSON. El PDF se genera a partir de ESTE mismo
// documento, así que el PDF y el JSON nunca pueden contar cosas distintas.

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../data/codecs.dart';
import '../domain/clock.dart';
import '../domain/laws.dart';
import '../domain/match_facts.dart';
import '../domain/model.dart';
import '../domain/rubric.dart';

/// Lo que hace falta leer del almacenamiento para exportar un informe cerrado.
class ExportSource {
  const ExportSource({
    required this.assessmentId,
    required this.competition,
    required this.category,
    required this.kickoffLocal,
    required this.kickoffTz,
    required this.venue,
    required this.homeTeam,
    required this.awayTeam,
    required this.observationMode,
    required this.refereeId,
    required this.refereeName,
    required this.assessorId,
    required this.assessorName,
    required this.reportVersion,
    required this.reportStatus,
    required this.canonicalJson,
    required this.contentHash,
    required this.incidents,
    this.scores = const [],
    this.round,
    this.difficulty,
    this.finalScoreHome,
    this.finalScoreAway,
    this.ar1Name,
    this.ar2Name,
    this.refereeLicence,
    this.refereeGrade,
    this.assessorLicence,
  });

  final String assessmentId;
  final String competition;
  final String? round;
  final CategoryConfig category;
  final String kickoffLocal; // "2026-10-17T17:00"
  final String kickoffTz;
  final String venue;
  final String homeTeam;
  final String awayTeam;
  final int? finalScoreHome;
  final int? finalScoreAway;
  final String observationMode; // LIVE | VIDEO | LIVE_AND_VIDEO
  final String? difficulty; // LOW | MEDIUM | HIGH | VERY_HIGH (solo descriptiva)
  final String refereeId;
  final String refereeName;
  final String? refereeLicence;
  final String? refereeGrade;
  final String? ar1Name;
  final String? ar2Name;
  final String assessorId;
  final String assessorName;
  final String? assessorLicence;
  final int reportVersion;
  final String reportStatus; // FINALIZED | SUPERSEDED
  final String? canonicalJson; // el JSON firmado, tal y como se guardó al cerrar
  final String? contentHash;
  final List<Incident> incidents;

  /// Marcador del partido, con los tantos anulados (se filtran al exportar).
  final List<ScoreEvent> scores;

  /// Sanciones: las decisiones tomadas (golpes y tarjetas) de las incidencias.
  List<SanctionEvent> get sanctions => sanctionsOf(incidents);
}

enum ExportErrorCode { notFinalized, integrityMismatch, schemaInvalid }

class ExportException implements Exception {
  const ExportException(this.code, [this.details = const []]);
  final ExportErrorCode code;
  final List<String> details;
  @override
  String toString() => 'ExportException(${code.name}${details.isEmpty ? '' : ': ${details.join('; ')}'})';
}

/// Comprueba que el JSON guardado al cerrar no se ha alterado: SHA-256(canonical_json) == hash.
void verifyIntegrity(ExportSource s) {
  if (s.reportStatus != 'FINALIZED' && s.reportStatus != 'SUPERSEDED') {
    throw const ExportException(ExportErrorCode.notFinalized);
  }
  if (s.canonicalJson == null || s.contentHash == null) throw const ExportException(ExportErrorCode.notFinalized);
  final actual = sha256.convert(utf8.encode(s.canonicalJson!)).toString();
  if (actual != s.contentHash) {
    throw ExportException(ExportErrorCode.integrityMismatch, ['esperado ${s.contentHash}', 'calculado $actual']);
  }
}

String _two(int v) => v.toString().padLeft(2, '0');

Map<String, Object?> _incidentJson(Incident i) => {
  'id': i.id,
  'seq': i.seq,
  'matchClock': formatClock(i.matchTime.matchClockMs),
  'period': i.matchTime.period == null ? null : encodePeriod(i.matchTime.period!),
  'overtime': i.matchTime.overtimeMs > 0,
  'timeIntegrity': encodeIntegrity(i.matchTime.integrity),
  'category': encodeCategory(i.category),
  'criterionCode': i.criterionCode,
  if (i.gamePhase != null) 'gamePhase': encodeGamePhase(i.gamePhase!),
  if (i.fieldZone != null) 'fieldZone': encodeZone(i.fieldZone!),
  if (i.decisionTaken != null) 'decisionTaken': jsonDecode(encodeDecision(i.decisionTaken)!),
  if (i.decisionExpected != null) 'decisionExpected': jsonDecode(encodeDecision(i.decisionExpected)!),
  'verdict': encodeVerdict(i.verdict),
  'impact': encodeImpact(i.impact),
  if (i.infraction != null) 'infraction': _infractionJson(i.infraction!),
  if ((i.notes ?? '').trim().isNotEmpty) 'notes': i.notes!.trim(),
  'attachments': const <Object>[],
};

Map<String, Object?> _infractionJson(InfractionRef r) => {
  'code': r.code,
  'label': r.label,
  if (r.lawRef != null) 'lawRef': r.lawRef,
};

String _sanctionCode(SanctionKind k) => encodeSanctionKind(k);

/// Marcador y sanciones (no forman parte del informe firmado: son datos del partido). Cada bloque
/// solo aparece si se registró algo (aunque se anulara después): un "0" sin registros afirmaría
/// algo que el evaluador no anotó. null = no se llevó ni marcador ni sanciones.
Map<String, Object?>? buildMatchStats(ExportSource s) {
  if (s.scores.isEmpty && s.sanctions.isEmpty) return null;
  final scores = [
    for (final e in s.scores)
      if (!e.voided) e,
  ]..sort((a, b) => a.seq.compareTo(b.seq));
  final sanctions = [
    for (final e in s.sanctions)
      if (!e.voided) e,
  ]..sort((a, b) => a.seq.compareTo(b.seq));
  final line = scorelineOf(scores);
  final tally = SanctionTally(sanctions);
  String side(TeamSide t) => t == TeamSide.home ? 'home' : 'away';
  return {
    if (s.scores.isNotEmpty)
      'score': {
        'home': line.home,
        'away': line.away,
        'events': [
          for (final e in scores)
            {
              'seq': e.seq,
              'team': encodeTeam(e.team),
              'kind': encodeScoreKind(e.kind),
              'points': e.points,
              'matchClock': formatClock(e.matchClockMs),
              'period': e.period == null ? null : encodePeriod(e.period!),
            },
        ],
      },
    if (s.sanctions.isNotEmpty)
      'sanctions': {
        'totals': {
          for (final t in TeamSide.values) side(t): {for (final k in SanctionKind.values) _sanctionCode(k): tally.count(t, k)},
        },
        'breakdown': {
          for (final t in TeamSide.values)
            side(t): [
              for (final r in breakdownOf(sanctions, t))
                {
                  'label': r.label,
                  if (r.infraction != null) 'code': r.infraction!.code,
                  if (r.infraction?.lawRef != null) 'lawRef': r.infraction!.lawRef,
                  'penalties': r.penalties,
                  'freeKicks': r.freeKicks,
                },
            ],
        },
        'events': [
          for (final e in sanctions)
            {
              'seq': e.seq,
              'team': encodeTeam(e.team),
              'kind': _sanctionCode(e.kind),
              'matchClock': formatClock(e.matchClockMs),
              'period': e.period == null ? null : encodePeriod(e.period!),
              if (e.infraction != null) 'infraction': _infractionJson(e.infraction!),
            },
        ],
      },
  };
}

/// Construye el documento de exportación. Verifica antes la integridad del informe.
Map<String, Object?> buildExportDocument(
  ExportSource s,
  AssessmentRubric rubric, {
  required DateTime exportedAt,
  required String appVersion,
}) {
  verifyIntegrity(s);
  final signed = jsonDecode(s.canonicalJson!) as Map<String, dynamic>;
  final active = [
    for (final i in s.incidents)
      if (!i.isVoid) i,
  ]..sort((a, b) => a.sessionMs.compareTo(b.sessionMs));
  return {
    'format': 'rugby-referee-assessment',
    'formatVersion': '2.1',
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'generator': {'app': 'RefAssess', 'appVersion': appVersion, 'rubricEngineVersion': rubric.version},
    'match': {
      'assessmentId': s.assessmentId,
      'competition': s.competition,
      if (s.round != null && s.round!.isNotEmpty) 'round': s.round,
      'category': {
        'code': s.category.code,
        'name': s.category.name,
        'format': encodeFormat(s.category.format),
        'periodLengthMin': s.category.periodLengthMin,
        'sinBinMin': s.category.sinBinMin,
        'lawVariations': const <String>[],
      },
      'kickoff': {'local': s.kickoffLocal, 'tz': s.kickoffTz},
      'venue': s.venue,
      'home': {'name': s.homeTeam},
      'away': {'name': s.awayTeam},
      if (s.finalScoreHome != null && s.finalScoreAway != null)
        'finalScore': {'home': s.finalScoreHome, 'away': s.finalScoreAway},
      'observationMode': s.observationMode,
      if (s.difficulty != null) 'difficulty': s.difficulty,
      'refereeName': s.refereeName,
      if (s.ar1Name != null || s.ar2Name != null)
        'assistants': {if (s.ar1Name != null) 'ar1': s.ar1Name, if (s.ar2Name != null) 'ar2': s.ar2Name},
    },
    'referee': {
      'id': s.refereeId,
      'fullName': s.refereeName,
      if (s.refereeLicence != null) 'federationLicence': s.refereeLicence,
      if (s.refereeGrade != null) 'grade': s.refereeGrade,
    },
    'assessor': {
      'id': s.assessorId,
      'fullName': s.assessorName,
      if (s.assessorLicence != null) 'federationLicence': s.assessorLicence,
    },
    'rubric': {
      'id': rubric.id,
      'code': rubric.code,
      'version': rubric.version,
      'bands': [
        for (final b in rubric.bands) {'code': b.code.name.toUpperCase(), 'label': b.label},
      ],
      'areas': [
        for (final a in rubric.areas)
          {
            'code': a.code,
            'name': a.name,
            'weight': a.weight,
            'criteria': [
              for (final c in a.criteria) {'code': c.code, 'name': c.name, 'weight': c.weight},
            ],
          },
      ],
    },
    // El informe firmado + su estado (el estado no entra en el hash: spec §3.3).
    'report': {...signed, 'status': s.reportStatus},
    'incidents': [for (final i in active) _incidentJson(i)],
    'matchStats': ?buildMatchStats(s),
    'integrity': {
      'algorithm': 'SHA-256',
      'canonicalization': 'sorted-keys-no-whitespace-v1',
      'hashedPointer': '/report',
      'contentHash': s.contentHash,
    },
  };
}

/// Nombre de archivo legible y seguro: "informe_2026-10-17_local-visitante_v1.pdf".
String exportFileName(ExportSource s, String extension) {
  String slug(String v) => v
      .toLowerCase()
      .replaceAll(RegExp('[áàä]'), 'a')
      .replaceAll(RegExp('[éèë]'), 'e')
      .replaceAll(RegExp('[íìï]'), 'i')
      .replaceAll(RegExp('[óòö]'), 'o')
      .replaceAll(RegExp('[úùü]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final date = s.kickoffLocal.length >= 10 ? s.kickoffLocal.substring(0, 10) : s.kickoffLocal;
  return 'informe_${date}_${slug(s.homeTeam)}-${slug(s.awayTeam)}_v${s.reportVersion}.$extension';
}

/// "2026-10-17T17:00" → "17/10/2026 · 17:00".
String formatKickoff(String local) {
  final d = DateTime.tryParse(local);
  if (d == null) return local;
  return '${_two(d.day)}/${_two(d.month)}/${d.year} · ${_two(d.hour)}:${_two(d.minute)}';
}
