// Partido completo cerrado en una base de datos Drift real, para probar la exportación.
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:json_schema/json_schema.dart';
import 'package:ref_assess/core/platform_ports.dart';
import 'package:ref_assess/data/db/app_database.dart' hide Incident, Finding, ActionPoint, ActionPointReview;
import 'package:ref_assess/data/drift_evaluation_repository.dart';
import 'package:ref_assess/data/drift_export_repository.dart';
import 'package:ref_assess/data/drift_live_session_repository.dart';
import 'package:ref_assess/domain/category_presets.dart';
import 'package:ref_assess/domain/model.dart';
import 'package:ref_assess/domain/report.dart';
import 'package:ref_assess/domain/rubric.dart';
import 'package:ref_assess/domain/rubric_default.dart';
import 'package:ref_assess/export/report_exporter.dart';
import 'package:ref_assess/export/report_pdf.dart';
import 'package:ref_assess/features/evaluation/evaluation_controller.dart';

class SeqIds implements IdGenerator {
  SeqIds(this.p);
  final String p;
  int n = 0;
  @override
  String next() => '$p-${++n}';
}

Incident _inc(String a, int minute, IncidentCategory c, Verdict v, ImpactLevel impact, {String? notes, Decision? taken, Decision? expected}) => Incident(
      id: '$a-inc-$minute',
      assessmentId: a,
      seq: minute,
      sessionMs: minute * 60000,
      wallUtc: DateTime.utc(2026, 10, 17, 15, minute % 60),
      matchTime: MatchTimeStamp(
        period: minute < 40 ? PeriodId.h1 : PeriodId.h2,
        phase: MatchPhaseLabel.inPlay,
        periodElapsedMs: minute * 60000,
        matchClockMs: minute * 60000,
        overtimeMs: 0,
        integrity: TimeIntegrity.ok,
      ),
      category: c,
      criterionCode: kCategoryToCriterion[c]!,
      polarity: QuickPolarity.review,
      verdict: v,
      impact: impact,
      impactConfirmed: true,
      status: IncidentStatus.enriched,
      notes: notes,
      decisionTaken: taken,
      decisionExpected: expected,
    );

Future<PdfFonts> testFonts() async {
  ByteData f(String n) => ByteData.sublistView(File('assets/fonts/Roboto-$n.ttf').readAsBytesSync());
  return PdfFonts.fromBytes(regular: f('Regular'), medium: f('Medium'), bold: f('Bold'), italic: f('Italic'));
}

JsonSchema exportSchema() => JsonSchema.create(File('assets/export/assessment-export.schema.json').readAsStringSync());

class ExportFixture {
  ExportFixture._(this.db, this.dir, this.firstId, this.secondId);
  final AppDatabase db;
  final Directory dir;
  final String firstId;
  final String secondId; // segundo partido del mismo árbitro, con seguimiento de recomendaciones
  final _exportIds = SeqIds('exp'); // compartido: ids únicos aunque se creen varios exportadores

  ReportExporter exporter({DateTime? now}) => ReportExporter(
        repository: DriftExportRepository(db),
        rubric: kDefaultRubric,
        schema: exportSchema(),
        fonts: testFonts,
        exportsDirectory: () async => Directory('${dir.path}/exports'),
        ids: _exportIds,
        now: () => now ?? DateTime.utc(2026, 10, 18, 9, 30),
      );

  static Future<ExportFixture> create() async {
    final dir = Directory.systemTemp.createTempSync('refassess_export_');
    final db = AppDatabase(NativeDatabase(File('${dir.path}/refassess.sqlite')));
    final first = await _match(db, 'm1', finalize: true, reviewPrevious: false);
    final second = await _match(db, 'm2', finalize: true, reviewPrevious: true, sameRefereeAs: first);
    return ExportFixture._(db, dir, first, second);
  }

  bool _disposed = false;

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await db.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }

  static Future<String> _match(AppDatabase db, String p, {required bool finalize, required bool reviewPrevious, String? sameRefereeAs}) async {
    final id = await AssessmentSetup(db, SeqIds(p)).createLiveAssessment(
      category: categoryPreset('SM_DHCAT_1_2_3'),
      competition: 'Liga DHCAT',
      venue: 'Campo Municipal de La Foixarda',
      homeTeam: 'Club Local RC',
      awayTeam: 'Visitante RT',
      refereeName: 'Árbitro Ejemplo',
      assessorName: 'Evaluadora Ejemplo',
      kickoffLocal: DateTime(2026, 10, 17, 17),
    );
    await db.customStatement(
      "UPDATE assessment SET status = 'POST_MATCH', difficulty = 'HIGH', ar1_name = 'Asistente Uno', ar2_name = 'Asistente Dos', "
      "round = 'J5', final_score_home = 24, final_score_away = 19 WHERE id = '$id'",
    );
    if (sameRefereeAs != null) {
      await db.customStatement("UPDATE assessment SET referee_id = (SELECT referee_id FROM assessment WHERE id = '$sameRefereeAs') WHERE id = '$id'");
    }
    final live = DriftLiveSessionRepository(db);
    const penaltyAway = Decision(outcomes: [DecisionOutcome.penalty, DecisionOutcome.yellowCard], againstTeam: TeamSide.away, lawRef: '19.10');
    await live.insertIncident(_inc(id, 30, IncidentCategory.scrum, Verdict.missed, ImpactLevel.matchDefining,
        notes: 'Colapso intencionado del pilar visitante a 5 m de su línea; no sancionado.', taken: const Decision(outcomes: [DecisionOutcome.playOn]), expected: penaltyAway));
    await live.insertIncident(_inc(id, 12, IncidentCategory.tackle, Verdict.correct, ImpactLevel.medium));
    await live.insertIncident(_inc(id, 52, IncidentCategory.tryGrounding, Verdict.correct, ImpactLevel.high,
        notes: 'Ensayo bien concedido: buena posición en la zona de ensayo.', taken: const Decision(outcomes: [DecisionOutcome.tryAwarded])));
    await live.insertIncident(_inc(id, 65, IncidentCategory.advantage, Verdict.correct, ImpactLevel.low));

    final c = EvaluationController(
      assessmentId: id,
      repository: DriftEvaluationRepository(db),
      rubric: kDefaultRubric,
      ids: SeqIds('$p-e'),
      now: () => DateTime.utc(2026, 10, 18, 9, 12),
      textDebounce: Duration.zero,
    );
    await c.load();
    for (final crit in kDefaultRubric.criteria) {
      if (crit.code == 'A2_LINEOUT_MAUL') {
        c.setNotObserved(crit.code, true);
        c.setJustification(crit.code, 'Sin touchs disputadas en zona de influencia.');
        continue;
      }
      c.setBand(crit.code, crit.code == 'B4_ADVANTAGE' ? BandCode.above : c.suggestions[crit.code]!.suggestedBand ?? BandCode.at);
      c.setJustification(
        crit.code,
        crit.code == 'B4_ADVANTAGE' ? 'Ventajas largas, bien leídas y cerradas con claridad en todo el partido.' : 'Acorde al nivel del partido.',
      );
    }
    c.setSummary('Partido de alta exigencia bien gestionado en lo físico y en la ventaja; la prioridad es el scrum en zona de marca.');
    c.updateFinding(c.addFinding(FindingKind.strength)!.id, text: 'Ventaja territorial bien leída.');
    c.updateFinding(c.addFinding(FindingKind.development)!.id, text: 'Colapsos de scrum cerca de la línea de marca.');
    final ap = c.addActionPoint()!;
    c.updateActionPoint(ap.id, text: 'Situarse en el lado del pilar dominante en scrums dentro de 22.', successIndicator: 'Ningún colapso sin sancionar en 22 en el próximo partido.');
    if (reviewPrevious) {
      for (final prev in c.openPrevious) {
        c.setPreviousReview(prev.id, status: ActionPointReviewStatus.partial);
        c.setPreviousReview(prev.id, comment: 'Mejor posición, un colapso sin ver al final.');
      }
    }
    if (finalize) {
      final issues = await c.finalize();
      if (issues.isNotEmpty) throw StateError('Fixture no cerrable: $issues');
    }
    return id;
  }
}
