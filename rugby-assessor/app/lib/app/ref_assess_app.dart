import 'dart:async';

import 'package:flutter/material.dart';

import '../core/design_system/theme.dart';
import '../data/match_repository.dart';
import '../data/session_time.dart';
import '../features/evaluation/evaluation_controller.dart';
import '../features/evaluation/evaluation_screen.dart';
import '../features/evaluation/export_controller.dart';
import '../features/home/home_screen.dart';
import '../features/live/live_controller.dart';
import '../features/live/live_screen.dart';
import '../features/review/incident_editor_screen.dart';
import '../features/review/review_controller.dart';
import '../features/review/review_screen.dart';
import '../features/setup/match_setup_screen.dart';
import 'app_services.dart';

/// Raíz de la app: inicio → preparación → directo → revisión → evaluación (y exportación).
class RefAssessApp extends StatelessWidget {
  const RefAssessApp({super.key, required this.services, this.now});
  final AppServices services;

  /// Hora para la preparación (solo en tests).
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    final nav = AppNavigator(services, now: now);
    return MaterialApp(
      title: 'RefAssess',
      debugShowCheckedModeBanner: false,
      theme: buildRefTheme(Brightness.light),
      darkTheme: buildRefTheme(Brightness.dark),
      home: Builder(
        builder: (context) => HomeScreen(
          repository: services.matches,
          rubric: services.rubric,
          onNewMatch: () => nav.newMatch(context),
          onOpenMatch: (m) => nav.openMatch(context, m),
        ),
      ),
    );
  }
}

/// Las rutas de la app. Cada método termina cuando el usuario vuelve a la pantalla que lo llamó,
/// para que el inicio recargue la lista.
class AppNavigator {
  AppNavigator(this.s, {this.now});
  final AppServices s;
  final DateTime Function()? now;

  /// Preparación → "Comenzar partido" → el directo SUSTITUYE a la preparación (atrás vuelve al inicio).
  Future<void> newMatch(BuildContext context) async {
    Future<void>? live;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (setupContext) => MatchSetupScreen(
          repository: s.matches,
          now: now,
          onStart: (id) => live = openLive(setupContext, id, replace: true),
        ),
      ),
    );
    // Si se creó el partido, se espera también a que se cierre el directo.
    await live;
  }

  Future<void> openMatch(BuildContext context, MatchSummary m) => switch (m.stage) {
        MatchStage.inProgress => openLive(context, m.id),
        MatchStage.pendingReview => openReview(context, m.id),
        MatchStage.finalized => openEvaluation(context, m.id),
      };

  /// Directo (Pantalla 1). El reloj se abre (o recupera) antes de mostrarlo: un partido nuevo
  /// llega en "ANTES DEL INICIO" con 00:00.
  Future<void> openLive(BuildContext context, String id, {bool replace = false}) async {
    final (clock, recovery) = await openSessionClock(assessmentId: id, store: s.live, mono: s.mono, wallNow: s.wallNow);
    final controller = LiveController(
      assessmentId: id,
      repository: s.live,
      clock: clock,
      ids: s.ids,
      haptics: s.haptics,
      clockRecovery: recovery,
    );
    if (!context.mounted) {
      controller.dispose();
      return;
    }
    final route = MaterialPageRoute<void>(
      builder: (liveContext) => LiveScreen(
        controller: controller,
        screenAwake: s.screenAwake,
        // Durante el partido: lista de marcas y editor completo, sin parar el reloj.
        onOpenMarks: () async {
          await controller.flush();
          if (!liveContext.mounted) return;
          await Navigator.of(liveContext).push(
            MaterialPageRoute<void>(
              builder: (_) => ReviewScreen(
                controller: ReviewController(assessmentId: id, repository: s.live),
                duringMatch: true,
                onContinueToRubric: () {},
              ),
            ),
          );
          await controller.reloadMarks();
        },
        onEditIncident: (incidentId) async {
          await controller.flush();
          final review = ReviewController(assessmentId: id, repository: s.live);
          await review.load();
          if (!liveContext.mounted) return;
          await Navigator.of(liveContext).push(
            MaterialPageRoute<void>(
              builder: (_) => IncidentEditorScreen(controller: review, incidentId: incidentId, chainPending: false),
            ),
          );
          review.dispose();
          await controller.reloadMarks();
        },
        onGoToReview: () async {
          // Lo que quede en la cola del directo se escribe antes de leer para la revisión.
          await controller.flush();
          if (!liveContext.mounted) return;
          await openReview(liveContext, id);
          // Al volver, el directo recarga: la revisión puede haber anulado o editado marcas.
          await controller.load();
        },
      ),
    );
    final nav = Navigator.of(context);
    await (replace ? nav.pushReplacement<void, void>(route) : nav.push<void>(route));
    await controller.flush();
    controller.dispose();
  }

  /// Revisión post-partido (Pantalla 2) → evaluación (Pantalla 3).
  Future<void> openReview(BuildContext context, String id) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (reviewContext) => ReviewScreen(
            controller: ReviewController(assessmentId: id, repository: s.live),
            onContinueToRubric: () => Navigator.of(reviewContext).push(
              MaterialPageRoute<void>(
                // Desde la evaluación, "ir a la revisión" vuelve a la pantalla anterior.
                builder: (evalContext) => _evaluation(id, onOpenReview: () => Navigator.of(evalContext).pop()),
              ),
            ),
          ),
        ),
      );

  /// Informe cerrado: evaluación en solo lectura con la sección de exportación.
  Future<void> openEvaluation(BuildContext context, String id) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (evalContext) => _evaluation(
            id,
            onOpenReview: () => Navigator.of(evalContext).push(
              MaterialPageRoute<void>(
                builder: (reviewContext) => ReviewScreen(
                  controller: ReviewController(assessmentId: id, repository: s.live),
                  onContinueToRubric: () => Navigator.of(reviewContext).pop(),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _evaluation(String id, {required VoidCallback onOpenReview}) => EvaluationScreen(
        controller: EvaluationController(assessmentId: id, repository: s.evaluation, rubric: s.rubric, ids: s.ids),
        onOpenReview: onOpenReview,
        createExport: (home, away) => ExportController(
          assessmentId: id,
          exporter: s.exporter,
          sharer: s.sharer,
          bytesSharer: s.bytesSharer,
          homeTeam: home,
          awayTeam: away,
        ),
      );
}
