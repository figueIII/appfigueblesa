import 'package:flutter_test/flutter_test.dart';
import 'package:ref_assess/domain/laws.dart';
import 'package:ref_assess/domain/match_facts.dart';
import 'package:ref_assess/domain/model.dart';

const home = TeamSide.home;
const away = TeamSide.away;

int _seq = 0;
ScoreEvent score(TeamSide team, ScoreKind kind, {bool voided = false}) {
  _seq++;
  return ScoreEvent(
    id: 's$_seq',
    assessmentId: 'a',
    seq: _seq,
    team: team,
    kind: kind,
    sessionMs: _seq * 1000,
    wallUtc: DateTime.utc(2026, 10, 17),
    period: PeriodId.h1,
    matchClockMs: _seq * 60000,
    voided: voided,
  );
}

SanctionEvent sanction(TeamSide team, SanctionKind kind, [InfractionRef? why, bool voided = false]) {
  _seq++;
  return SanctionEvent(
    id: 'k$_seq',
    assessmentId: 'a',
    seq: _seq,
    team: team,
    kind: kind,
    sessionMs: _seq * 1000,
    wallUtc: DateTime.utc(2026, 10, 17),
    period: PeriodId.h1,
    matchClockMs: _seq * 60000,
    infraction: why,
    voided: voided,
  );
}

InfractionRef law(String code) => InfractionRef.catalog(code);

void main() {
  setUp(() => _seq = 0);

  group('marcador', () {
    test('puntos: ensayo 5, transformación 2, golpe a palos 3, drop 3', () {
      expect(pointsFor(ScoreKind.tryScored), 5);
      expect(pointsFor(ScoreKind.conversion), 2);
      expect(pointsFor(ScoreKind.penaltyGoal), 3);
      expect(pointsFor(ScoreKind.dropGoal), 3);
    });

    test('el resultado suma los tantos activos de cada equipo; los anulados no cuentan', () {
      final events = [
        score(home, ScoreKind.tryScored),
        score(home, ScoreKind.conversion),
        score(away, ScoreKind.penaltyGoal),
        score(away, ScoreKind.dropGoal, voided: true),
        score(home, ScoreKind.penaltyGoal),
      ];
      expect(scorelineOf(events), const Scoreline(10, 3));
      expect(scorelineOf(const []), const Scoreline(0, 0));
      expect(countScores(events, home, ScoreKind.tryScored), 1);
      expect(countScores(events, away, ScoreKind.dropGoal), 0, reason: 'anulado');
    });

    test('transformación: solo justo después de un ensayo del mismo equipo', () {
      expect(conversionAvailable(const [], home), isFalse);
      final t = [score(home, ScoreKind.tryScored)];
      expect(conversionAvailable(t, home), isTrue);
      expect(conversionAvailable(t, away), isFalse, reason: 'el ensayo es del local');
      expect(conversionAvailable([...t, score(home, ScoreKind.conversion)], home), isFalse, reason: 'ya transformado');
      expect(conversionAvailable([...t, score(away, ScoreKind.penaltyGoal)], home), isFalse, reason: 'transformación fallada: el juego siguió');
    });

    test('al anular la transformación, vuelve a estar disponible; al anular el ensayo, no', () {
      final t = score(home, ScoreKind.tryScored);
      final c = score(home, ScoreKind.conversion, voided: true);
      expect(conversionAvailable([t, c], home), isTrue);
      expect(conversionAvailable([t.asVoided()], home), isFalse);
    });

    test('validateScore rechaza la transformación sin ensayo y acepta lo demás', () {
      expect(validateScore(const [], home, ScoreKind.conversion), ScoreRuleError.conversionWithoutTry);
      for (final k in [ScoreKind.tryScored, ScoreKind.penaltyGoal, ScoreKind.dropGoal]) {
        expect(validateScore(const [], away, k), isNull, reason: k.name);
      }
    });

    test('último tanto activo (para deshacer), en orden de registro', () {
      final a = score(home, ScoreKind.tryScored);
      final b = score(away, ScoreKind.dropGoal, voided: true);
      expect(lastActiveScore([b, a])?.id, a.id);
      expect(lastActiveScore([b]), isNull);
    });
  });

  group('sanciones', () {
    test('recuento por equipo y tipo, sin las anuladas', () {
      final tally = SanctionTally([
        sanction(home, SanctionKind.penalty),
        sanction(home, SanctionKind.penalty),
        sanction(home, SanctionKind.freeKick),
        sanction(away, SanctionKind.yellowCard),
        sanction(away, SanctionKind.penalty, null, true),
        sanction(away, SanctionKind.redCard),
      ]);
      expect(tally.count(home, SanctionKind.penalty), 2);
      expect(tally.count(home, SanctionKind.freeKick), 1);
      expect(tally.count(away, SanctionKind.penalty), 0);
      expect(tally.count(away, SanctionKind.yellowCard), 1);
      expect(tally.count(away, SanctionKind.redCard), 1);
      expect(tally.total(home), 3);
      expect(SanctionTally(const []).isEmpty, isTrue);
    });

    test('desglose: de más a menos frecuente, empate por orden de aparición, "Sin especificar" al final', () {
      final events = [
        sanction(home, SanctionKind.penalty), // sin especificar
        sanction(home, SanctionKind.penalty, law('SIDE_ENTRY')),
        sanction(home, SanctionKind.penalty, law('OFFSIDE_RUCK_MAUL')),
        sanction(home, SanctionKind.freeKick, law('OFFSIDE_RUCK_MAUL')),
        sanction(home, SanctionKind.penalty, law('OFFSIDE_RUCK_MAUL')),
        sanction(home, SanctionKind.penalty, law('NOT_RELEASING')),
        sanction(home, SanctionKind.penalty, law('SIDE_ENTRY')),
        sanction(away, SanctionKind.penalty, law('HANDS_IN_RUCK')), // otro equipo
        sanction(home, SanctionKind.penalty, law('NOT_RELEASING'), true), // anulada
      ];
      final rows = breakdownOf(events, home);
      expect([for (final r in rows) '${r.total}× ${r.label}'], [
        '3× Fuera de juego en ruck / maul',
        '2× Entrada lateral',
        '1× No soltar el balón',
        '1× Sin especificar',
      ]);
      expect(rows.first.penalties, 2);
      expect(rows.first.freeKicks, 1);
    });

    test('las tarjetas no entran en el desglose de golpes: van aparte, en orden', () {
      final events = [
        sanction(away, SanctionKind.penalty, law('HIGH_TACKLE')),
        sanction(away, SanctionKind.yellowCard, law('HIGH_TACKLE')),
        sanction(away, SanctionKind.redCard, law('TIP_TACKLE')),
      ];
      expect(breakdownOf(events, away).single.total, 1);
      expect([for (final c in cardsOf(events, away)) c.kind], [SanctionKind.yellowCard, SanctionKind.redCard]);
      expect(cardsOf(events, home), isEmpty);
    });

    test('las infracciones personalizadas se agrupan por texto (sin distinguir mayúsculas ni espacios)', () {
      final events = [
        sanction(home, SanctionKind.penalty, InfractionRef.custom('Avance intencionado', lawRef: 'Ley 11')),
        sanction(home, SanctionKind.penalty, InfractionRef.custom('  avance   INTENCIONADO')),
      ];
      final rows = breakdownOf(events, home);
      expect(rows.single.total, 2);
      expect(rows.single.label, 'Avance intencionado');
    });

    test('última sanción activa', () {
      final a = sanction(home, SanctionKind.penalty);
      final b = sanction(away, SanctionKind.freeKick, null, true);
      expect(lastActiveSanction([a, b])?.id, a.id);
    });
  });

  group('catálogo de leyes', () {
    test('códigos únicos, con ley y en el grupo pedido', () {
      expect(kInfractions.map((i) => i.code).toSet().length, kInfractions.length);
      for (final i in kInfractions) {
        expect(i.lawRef, startsWith('Ley'), reason: i.code);
        expect(i.label, isNotEmpty);
      }
      Set<String> labels(LawGroup g) => {for (final i in infractionsIn(g)) i.english};
      expect(labels(LawGroup.ruck), containsAll(['Not rolling away', 'Not releasing', 'Side entry', 'Off feet / sealing off', 'Hands in the ruck']));
      expect(labels(LawGroup.tackle), containsAll(['Head contact process', 'Tip tackle', 'Tackling without the ball', 'Early / late tackle']));
      expect(labels(LawGroup.offside), containsAll(['Offside at ruck / maul', 'Offside in open play']));
      expect(labels(LawGroup.scrum), containsAll(['Early engagement', 'Collapsing', 'Not pushing straight', 'Early push']));
      expect(labels(LawGroup.lineoutMaul), containsAll(['Not straight', 'Collapsing a maul', 'Illegal maul entry', 'Obstruction / truck and trailer']));
      expect(labels(LawGroup.discipline), containsAll(['Dissent', 'Foul language', 'Intentional obstruction', 'Time wasting']));
    });

    test('grupos sugeridos según la categoría de la marca: el probable primero y todos presentes', () {
      expect(lawGroupsFor(IncidentCategory.scrum).first, LawGroup.scrum);
      expect(lawGroupsFor(IncidentCategory.ruck).take(2), [LawGroup.ruck, LawGroup.offside]);
      expect(lawGroupsFor(null), LawGroup.values);
      for (final c in IncidentCategory.values) {
        expect(lawGroupsFor(c).toSet(), LawGroup.values.toSet(), reason: c.name);
      }
    });

    test('InfractionRef: catálogo, personalizada y lectura del almacenamiento', () {
      final r = law('SCRUM_COLLAPSING');
      expect(r.label, 'Derrumbar la melé');
      expect(r.lawRef, 'Ley 19');
      expect(r.isCustom, isFalse);
      final c = InfractionRef.custom('  Avance intencionado ', lawRef: ' ');
      expect(c.label, 'Avance intencionado');
      expect(c.lawRef, isNull);
      expect(() => InfractionRef.custom('   '), throwsArgumentError);
      expect(() => InfractionRef.catalog('NO_EXISTE'), throwsArgumentError);
      expect(InfractionRef.decode('SIDE_ENTRY', null, null), law('SIDE_ENTRY'));
      expect(InfractionRef.decode('CUSTOM', 'Avance', 'Ley 11')?.lawRef, 'Ley 11');
      expect(InfractionRef.decode(null, null, null), isNull);
      expect(InfractionRef.decode('RETIRADO', null, null), isNull, reason: 'código que ya no existe');
    });
  });
}
