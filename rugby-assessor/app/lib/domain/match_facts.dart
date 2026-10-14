// Hechos del partido que registra el evaluador junto a sus marcas. PURO: sin Flutter ni almacenamiento.
//
//  · Marcador: registro propio de solo inserción. "Deshacer" no borra: anula (voided = true).
//  · Sanciones (golpes de castigo, golpes francos y tarjetas): NO son un registro aparte. Son la
//    "decisión tomada" de una marca (contra un equipo). Así una sanción se valora como cualquier
//    otra marca (Bien / Error) y, si en la revisión se corrige la decisión, los contadores y el
//    desglose se corrigen solos. Todo se deriva de las marcas activas.

import 'laws.dart';
import 'model.dart';

export 'laws.dart' show SanctionKind;

// ───────────── Marcador ─────────────

enum ScoreKind { tryScored, conversion, penaltyGoal, dropGoal }

int pointsFor(ScoreKind k) => switch (k) {
      ScoreKind.tryScored => 5,
      ScoreKind.conversion => 2,
      ScoreKind.penaltyGoal => 3,
      ScoreKind.dropGoal => 3,
    };

String scoreKindLabel(ScoreKind k) => switch (k) {
      ScoreKind.tryScored => 'Ensayo',
      ScoreKind.conversion => 'Transformación',
      ScoreKind.penaltyGoal => 'Golpe a palos',
      ScoreKind.dropGoal => 'Drop',
    };

/// Base común: cuándo se registró (eje de sesión, hora de pared y minuto de partido).
abstract class MatchFact {
  const MatchFact({
    required this.id,
    required this.assessmentId,
    required this.seq,
    required this.team,
    required this.sessionMs,
    required this.wallUtc,
    required this.period,
    required this.matchClockMs,
    this.voided = false,
  });
  final String id;
  final String assessmentId;
  final int seq;
  final TeamSide team;
  final int sessionMs;
  final DateTime wallUtc;
  final PeriodId? period;
  final int matchClockMs;
  final bool voided;
}

class ScoreEvent extends MatchFact {
  const ScoreEvent({
    required super.id,
    required super.assessmentId,
    required super.seq,
    required super.team,
    required this.kind,
    required super.sessionMs,
    required super.wallUtc,
    required super.period,
    required super.matchClockMs,
    super.voided,
  });
  final ScoreKind kind;
  int get points => pointsFor(kind);

  ScoreEvent asVoided() => ScoreEvent(
        id: id,
        assessmentId: assessmentId,
        seq: seq,
        team: team,
        kind: kind,
        sessionMs: sessionMs,
        wallUtc: wallUtc,
        period: period,
        matchClockMs: matchClockMs,
        voided: true,
      );
}

class Scoreline {
  const Scoreline(this.home, this.away);
  final int home;
  final int away;
  int of(TeamSide t) => t == TeamSide.home ? home : away;

  @override
  bool operator ==(Object other) => other is Scoreline && other.home == home && other.away == away;
  @override
  int get hashCode => Object.hash(home, away);
  @override
  String toString() => '$home–$away';
}

List<T> _activeInOrder<T extends MatchFact>(Iterable<T> facts) => [for (final f in facts) if (!f.voided) f]..sort((a, b) => a.seq.compareTo(b.seq));

Scoreline scorelineOf(Iterable<ScoreEvent> events) {
  var home = 0, away = 0;
  for (final e in events) {
    if (e.voided) continue;
    if (e.team == TeamSide.home) {
      home += e.points;
    } else {
      away += e.points;
    }
  }
  return Scoreline(home, away);
}

int countScores(Iterable<ScoreEvent> events, TeamSide team, ScoreKind kind) =>
    events.where((e) => !e.voided && e.team == team && e.kind == kind).length;

/// La transformación solo existe justo después de un ensayo del mismo equipo: el último tanto
/// activo del partido debe ser ese ensayo (aún sin transformar). Si la transformación se falla,
/// no se registra nada y el siguiente tanto cierra la opción.
bool conversionAvailable(Iterable<ScoreEvent> events, TeamSide team) {
  final active = _activeInOrder(events);
  if (active.isEmpty) return false;
  final last = active.last;
  return last.kind == ScoreKind.tryScored && last.team == team;
}

enum ScoreRuleError { conversionWithoutTry }

/// null = el tanto es válido ahora.
ScoreRuleError? validateScore(Iterable<ScoreEvent> events, TeamSide team, ScoreKind kind) =>
    kind == ScoreKind.conversion && !conversionAvailable(events, team) ? ScoreRuleError.conversionWithoutTry : null;

/// Último tanto activo (el que deshace "Deshacer último tanto").
ScoreEvent? lastActiveScore(Iterable<ScoreEvent> events) {
  final active = _activeInOrder(events);
  return active.isEmpty ? null : active.last;
}

// ───────────── Sanciones ─────────────

String sanctionKindLabel(SanctionKind k) => switch (k) {
      SanctionKind.penalty => 'Golpe de castigo',
      SanctionKind.freeKick => 'Golpe franco',
      SanctionKind.yellowCard => 'Tarjeta amarilla',
      SanctionKind.redCard => 'Tarjeta roja',
    };

/// Abreviatura de las columnas del contador (GC · GF · TA · TR).
String sanctionKindShort(SanctionKind k) => switch (k) {
      SanctionKind.penalty => 'GC',
      SanctionKind.freeKick => 'GF',
      SanctionKind.yellowCard => 'TA',
      SanctionKind.redCard => 'TR',
    };

/// Sanción pitada por el árbitro contra [team] (el equipo infractor). Vista derivada de la
/// decisión tomada de una marca ([sanctionsOf]); [incidentId] es esa marca.
class SanctionEvent extends MatchFact {
  const SanctionEvent({
    required super.id,
    required this.incidentId,
    required super.assessmentId,
    required super.seq,
    required super.team,
    required this.kind,
    required super.sessionMs,
    required super.wallUtc,
    required super.period,
    required super.matchClockMs,
    this.infraction,
    super.voided,
  });
  final String incidentId;
  final SanctionKind kind;

  /// Motivo (la ley de la marca). null = sin especificar (se puede completar después).
  final InfractionRef? infraction;

  bool get isCard => kind == SanctionKind.yellowCard || kind == SanctionKind.redCard;
}

/// Recuento por equipo y tipo (solo sanciones activas).
class SanctionTally {
  SanctionTally(Iterable<SanctionEvent> sanctions) {
    for (final s in sanctions) {
      if (s.voided) continue;
      _counts[(s.team, s.kind)] = (_counts[(s.team, s.kind)] ?? 0) + 1;
    }
  }
  final Map<(TeamSide, SanctionKind), int> _counts = {};

  int count(TeamSide team, SanctionKind kind) => _counts[(team, kind)] ?? 0;
  int total(TeamSide team) => SanctionKind.values.fold(0, (sum, k) => sum + count(team, k));
  bool get isEmpty => _counts.isEmpty;
}

/// Una línea del desglose: "3× Fuera de juego en ruck / maul" (y cuántos fueron GC y cuántos GF).
class InfractionCount {
  const InfractionCount({required this.label, required this.infraction, required this.penalties, required this.freeKicks});
  final String label;

  /// null = sin especificar.
  final InfractionRef? infraction;
  final int penalties;
  final int freeKicks;
  int get total => penalties + freeKicks;
}

const String kUnspecifiedInfractionLabel = 'Sin especificar';

/// Desglose de los golpes (GC + GF) de [team] por motivo: de más a menos frecuente; a igualdad,
/// el que apareció antes. "Sin especificar" va siempre al final. Las tarjetas van aparte
/// ([cardsOf]): suelen acompañar a un golpe por la misma acción y contarían dos veces.
List<InfractionCount> breakdownOf(Iterable<SanctionEvent> sanctions, TeamSide team) {
  final order = <String>[];
  final refs = <String, InfractionRef?>{};
  final pk = <String, int>{};
  final fk = <String, int>{};
  for (final s in _activeInOrder(sanctions)) {
    if (s.team != team || s.isCard) continue;
    final key = s.infraction?.groupKey ?? '';
    if (!refs.containsKey(key)) {
      order.add(key);
      refs[key] = s.infraction;
    }
    if (s.kind == SanctionKind.penalty) {
      pk[key] = (pk[key] ?? 0) + 1;
    } else {
      fk[key] = (fk[key] ?? 0) + 1;
    }
  }
  final rows = [
    for (final key in order)
      InfractionCount(
        label: refs[key]?.label ?? kUnspecifiedInfractionLabel,
        infraction: refs[key],
        penalties: pk[key] ?? 0,
        freeKicks: fk[key] ?? 0,
      ),
  ];
  final firstSeen = {for (var i = 0; i < order.length; i++) order[i]: i};
  rows.sort((a, b) {
    final ua = a.infraction == null ? 1 : 0, ub = b.infraction == null ? 1 : 0;
    if (ua != ub) return ua - ub;
    final byTotal = b.total.compareTo(a.total);
    if (byTotal != 0) return byTotal;
    return firstSeen[a.infraction?.groupKey ?? '']!.compareTo(firstSeen[b.infraction?.groupKey ?? '']!);
  });
  return rows;
}

/// Tarjetas de [team] en orden cronológico.
List<SanctionEvent> cardsOf(Iterable<SanctionEvent> sanctions, TeamSide team) =>
    [for (final s in _activeInOrder(sanctions)) if (s.team == team && s.isCard) s];

/// Última sanción activa (la que deshace "Deshacer última sanción").
SanctionEvent? lastActiveSanction(Iterable<SanctionEvent> sanctions) {
  final active = _activeInOrder(sanctions);
  return active.isEmpty ? null : active.last;
}

// ───────────── Sanciones ⇄ decisión tomada de una marca ─────────────

SanctionKind? sanctionKindOf(DecisionOutcome o) => switch (o) {
      DecisionOutcome.penalty => SanctionKind.penalty,
      DecisionOutcome.freeKick => SanctionKind.freeKick,
      DecisionOutcome.yellowCard => SanctionKind.yellowCard,
      DecisionOutcome.redCard || DecisionOutcome.redCard20 => SanctionKind.redCard,
      _ => null,
    };

DecisionOutcome outcomeFor(SanctionKind k) => switch (k) {
      SanctionKind.penalty => DecisionOutcome.penalty,
      SanctionKind.freeKick => DecisionOutcome.freeKick,
      SanctionKind.yellowCard => DecisionOutcome.yellowCard,
      SanctionKind.redCard => DecisionOutcome.redCard,
    };

/// Sanciones pitadas: una por cada golpe o tarjeta de la decisión tomada de cada marca que tenga
/// equipo infractor (una marca con "golpe + amarilla" da dos). Las marcas anuladas salen anuladas.
List<SanctionEvent> sanctionsOf(Iterable<Incident> incidents) {
  final sorted = [...incidents]..sort((a, b) => a.seq.compareTo(b.seq));
  return [
    for (final i in sorted)
      if (i.decisionTaken?.againstTeam case final team?)
        for (final o in i.decisionTaken!.outcomes)
          if (sanctionKindOf(o) case final kind?)
            SanctionEvent(
              id: '${i.id}#${kind.name}',
              incidentId: i.id,
              assessmentId: i.assessmentId,
              seq: i.seq,
              team: team,
              kind: kind,
              sessionMs: i.sessionMs,
              wallUtc: i.wallUtc,
              period: i.matchTime.period,
              matchClockMs: i.matchTime.matchClockMs,
              infraction: i.infraction,
              voided: i.isVoid,
            ),
  ];
}

/// ¿La marca es una sanción (golpe o tarjeta contra un equipo)?
bool isSanction(Incident i) => i.decisionTaken?.againstTeam != null && i.decisionTaken!.outcomes.any((o) => sanctionKindOf(o) != null);

/// Categoría (y por tanto criterio de la rúbrica) de una marca creada desde el panel de sanciones.
/// Las tarjetas cuentan en la consistencia disciplinaria; los golpes, según la fase del motivo.
IncidentCategory categoryForSanction(SanctionKind kind, InfractionRef? why) {
  if (kind == SanctionKind.yellowCard || kind == SanctionKind.redCard) return IncidentCategory.card;
  final law = why?.catalog;
  if (law == null) return IncidentCategory.otherLaw;
  return switch (law.group) {
    LawGroup.ruck => IncidentCategory.ruck,
    LawGroup.tackle => IncidentCategory.tackle,
    LawGroup.offside => IncidentCategory.offside,
    LawGroup.scrum => IncidentCategory.scrum,
    LawGroup.lineoutMaul => law.code == 'LINEOUT_NOT_STRAIGHT' ? IncidentCategory.lineout : IncidentCategory.maul,
    LawGroup.discipline => switch (law.code) {
        'DISSENT' || 'FOUL_LANGUAGE' => IncidentCategory.captainMgmt,
        'DELAYING_RESTART' => IncidentCategory.otherLaw,
        _ => IncidentCategory.foulPlay,
      },
  };
}
