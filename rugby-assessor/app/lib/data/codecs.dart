// Conversión dominio ⇄ valores almacenados. Los textos son los del esquema SQL y del formato de
// exportación (SCREAMING_SNAKE_CASE), no los nombres Dart.

import 'dart:convert';

import '../domain/clock.dart';
import '../domain/match_facts.dart';
import '../domain/model.dart';

String _snake(String camel) => camel.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}').toUpperCase();

T _byCode<T extends Enum>(List<T> values, String code, String Function(T) encode) =>
    values.firstWhere((v) => encode(v) == code, orElse: () => throw FormatException('Valor desconocido: $code'));

String encodeCategory(IncidentCategory c) => _snake(c.name);
IncidentCategory decodeCategory(String s) => _byCode(IncidentCategory.values, s, encodeCategory);

String encodePolarity(QuickPolarity p) => _snake(p.name);
QuickPolarity decodePolarity(String s) => _byCode(QuickPolarity.values, s, encodePolarity);

String encodeVerdict(Verdict v) => _snake(v.name);
Verdict decodeVerdict(String s) => _byCode(Verdict.values, s, encodeVerdict);

String encodeImpact(ImpactLevel i) => _snake(i.name);
ImpactLevel decodeImpact(String s) => _byCode(ImpactLevel.values, s, encodeImpact);

String encodeIncidentStatus(IncidentStatus s) => switch (s) {
      IncidentStatus.quick => 'QUICK',
      IncidentStatus.enriched => 'ENRICHED',
      IncidentStatus.voided => 'VOID',
    };
IncidentStatus decodeIncidentStatus(String s) => _byCode(IncidentStatus.values, s, encodeIncidentStatus);

String encodePeriod(PeriodId p) => p.name.toUpperCase();
PeriodId decodePeriod(String s) => _byCode(PeriodId.values, s, encodePeriod);

String encodePhase(MatchPhaseLabel p) => _snake(p.name);
MatchPhaseLabel decodePhase(String s) => _byCode(MatchPhaseLabel.values, s, encodePhase);

String encodeIntegrity(TimeIntegrity i) => i.name.toUpperCase();
TimeIntegrity decodeIntegrity(String s) => _byCode(TimeIntegrity.values, s, encodeIntegrity);

String encodeFormat(GameFormat f) => f.name.toUpperCase();
GameFormat decodeFormat(String s) => _byCode(GameFormat.values, s, encodeFormat);

// ───────────── Categoría (snapshot JSON, mismas claves que CategoryConfig de model.ts) ─────────────

String encodeCategoryConfig(CategoryConfig c) => jsonEncode({
      'code': c.code,
      'name': c.name,
      'format': encodeFormat(c.format),
      'periodLengthMin': c.periodLengthMin,
      'sinBinMin': c.sinBinMin,
      'extraTime': c.extraTime == null
          ? null
          : {'periodLengthMin': c.extraTime!.periodLengthMin, 'suddenDeath': c.extraTime!.suddenDeath},
      'lawVariations': const <String>[],
    });

CategoryConfig decodeCategoryConfig(String json) {
  final m = jsonDecode(json) as Map<String, dynamic>;
  final et = m['extraTime'] as Map<String, dynamic>?;
  return CategoryConfig(
    code: m['code'] as String,
    name: m['name'] as String,
    format: decodeFormat(m['format'] as String),
    periodLengthMin: m['periodLengthMin'] as int,
    sinBinMin: m['sinBinMin'] as int,
    extraTime: et == null
        ? null
        : ExtraTimeConfig(periodLengthMin: et['periodLengthMin'] as int, suddenDeath: et['suddenDeath'] as bool),
  );
}

// ───────────── Eventos de reloj: tipo + payload JSON (columna clock_event.payload_json) ─────────────

(String type, String payload) encodeClockBody(ClockEventBody b) => switch (b) {
      PeriodStart(:final period) => ('PERIOD_START', jsonEncode({'period': encodePeriod(period)})),
      TimeOff() => ('TIME_OFF', '{}'),
      TimeOn() => ('TIME_ON', '{}'),
      PeriodEnd(:final next) => ('PERIOD_END', jsonEncode({'next': next == PeriodEndNext.interval ? 'INTERVAL' : 'FULL_TIME'})),
      Adjust(:final deltaMs) => ('ADJUST', jsonEncode({'deltaMs': deltaMs})),
      IntegrityLost(:final estimatedGapMs) => ('INTEGRITY_LOST', jsonEncode({'estimatedGapMs': estimatedGapMs})),
      Abandon(:final reason) => ('ABANDON', jsonEncode({'reason': reason})),
      VoidEvent(:final targetSeq) => ('VOID', jsonEncode({'targetSeq': targetSeq})),
    };

ClockEventBody decodeClockBody(String type, String payload) {
  final p = jsonDecode(payload) as Map<String, dynamic>;
  return switch (type) {
    'PERIOD_START' => PeriodStart(decodePeriod(p['period'] as String)),
    'TIME_OFF' => const TimeOff(),
    'TIME_ON' => const TimeOn(),
    'PERIOD_END' => PeriodEnd(p['next'] == 'INTERVAL' ? PeriodEndNext.interval : PeriodEndNext.fullTime),
    'ADJUST' => Adjust(p['deltaMs'] as int),
    'INTEGRITY_LOST' => IntegrityLost(p['estimatedGapMs'] as int),
    'ABANDON' => Abandon(p['reason'] as String),
    'VOID' => VoidEvent(p['targetSeq'] as int),
    _ => throw FormatException('Tipo de evento de reloj desconocido: $type'),
  };
}

// ───────────── Enriquecimiento (pantalla 2) ─────────────

const Map<DecisionOutcome, String> _outcomeCodes = {
  DecisionOutcome.playOn: 'PLAY_ON',
  DecisionOutcome.advantage: 'ADVANTAGE',
  DecisionOutcome.penalty: 'PENALTY',
  DecisionOutcome.freeKick: 'FREE_KICK',
  DecisionOutcome.scrum: 'SCRUM',
  DecisionOutcome.lineout: 'LINEOUT',
  DecisionOutcome.tryAwarded: 'TRY',
  DecisionOutcome.noTry: 'NO_TRY',
  DecisionOutcome.penaltyTry: 'PENALTY_TRY',
  DecisionOutcome.yellowCard: 'YELLOW_CARD',
  DecisionOutcome.redCard20: 'RED_CARD_20',
  DecisionOutcome.redCard: 'RED_CARD',
  DecisionOutcome.warning: 'WARNING',
  DecisionOutcome.tmoReferral: 'TMO_REFERRAL',
  DecisionOutcome.noDecision: 'NO_DECISION',
};

const Map<FieldZone, String> _zoneCodes = {
  FieldZone.own22: 'OWN_22',
  FieldZone.own22ToHalf: 'OWN_22_TO_HALF',
  FieldZone.halfToOpp22: 'HALF_TO_OPP_22',
  FieldZone.opp22: 'OPP_22',
  FieldZone.inGoal: 'IN_GOAL',
};

String encodeOutcome(DecisionOutcome o) => _outcomeCodes[o]!;
DecisionOutcome decodeOutcome(String s) => _byCode(DecisionOutcome.values, s, encodeOutcome);

String encodeZone(FieldZone z) => _zoneCodes[z]!;
FieldZone decodeZone(String s) => _byCode(FieldZone.values, s, encodeZone);

String encodeGamePhase(GamePhase p) => _snake(p.name);
GamePhase decodeGamePhase(String s) => _byCode(GamePhase.values, s, encodeGamePhase);

String encodeTeam(TeamSide t) => t.name.toUpperCase();
TeamSide decodeTeam(String s) => _byCode(TeamSide.values, s, encodeTeam);

/// Mismo formato que `Decision` en domain/model.ts y en el JSON de exportación.
String? encodeDecision(Decision? d) => d == null
    ? null
    : jsonEncode({
        'outcomes': [for (final o in d.outcomes) encodeOutcome(o)],
        if (d.againstTeam != null) 'againstTeam': encodeTeam(d.againstTeam!),
        if (d.lawRef != null && d.lawRef!.isNotEmpty) 'lawRef': d.lawRef,
        if (d.description != null && d.description!.isNotEmpty) 'description': d.description,
      });

Decision? decodeDecision(String? json) {
  if (json == null) return null;
  final m = jsonDecode(json) as Map<String, dynamic>;
  return Decision(
    outcomes: [for (final o in m['outcomes'] as List) decodeOutcome(o as String)],
    againstTeam: m['againstTeam'] == null ? null : decodeTeam(m['againstTeam'] as String),
    lawRef: m['lawRef'] as String?,
    description: m['description'] as String?,
  );
}

// ───────────── Hechos del partido (schema v3) ─────────────

const _scoreKindCodes = {
  ScoreKind.tryScored: 'TRY',
  ScoreKind.conversion: 'CONVERSION',
  ScoreKind.penaltyGoal: 'PENALTY_GOAL',
  ScoreKind.dropGoal: 'DROP_GOAL',
};
String encodeScoreKind(ScoreKind k) => _scoreKindCodes[k]!;
ScoreKind decodeScoreKind(String s) => _byCode(ScoreKind.values, s, encodeScoreKind);

const _sanctionKindCodes = {
  SanctionKind.penalty: 'PENALTY',
  SanctionKind.freeKick: 'FREE_KICK',
  SanctionKind.yellowCard: 'YELLOW_CARD',
  SanctionKind.redCard: 'RED_CARD',
};
String encodeSanctionKind(SanctionKind k) => _sanctionKindCodes[k]!;
SanctionKind decodeSanctionKind(String s) => _byCode(SanctionKind.values, s, encodeSanctionKind);
