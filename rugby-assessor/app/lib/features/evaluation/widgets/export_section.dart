import 'package:flutter/material.dart';

import '../../../core/design_system/theme.dart';
import '../../../core/design_system/tokens.dart';
import '../../../export/report_exporter.dart';
import '../../review/widgets/choice_controls.dart';
import '../export_controller.dart';

/// "Exportar y enviar": solo existe con el informe cerrado. PDF para el comité, JSON para archivo
/// y verificación de la huella; ambos por la hoja de compartir del sistema (correo, mensajería…).
class ExportSection extends StatelessWidget {
  const ExportSection({super.key, required this.controller});
  final ExportController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.refColors;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final busy = controller.busy;
        Widget button({
          required Key key,
          required String label,
          required IconData icon,
          required List<ExportFormat> formats,
          required bool primary,
        }) {
          final running = busy != null && busy.length == formats.length && busy.every(formats.contains);
          final style = primary
              ? FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.onPrimary,
                  disabledBackgroundColor: c.surfacePressed,
                  disabledForegroundColor: c.onSurface,
                  textStyle: context.refText(RefType.control),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
                )
              : OutlinedButton.styleFrom(
                  foregroundColor: c.onSurface,
                  side: BorderSide(color: c.outline, width: 2),
                  textStyle: context.refText(RefType.control),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RefRadius.control)),
                );
          final iconWidget = running
              ? SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 3, color: primary ? c.onPrimary : c.onSurface),
                )
              : Icon(icon);
          final onPressed = busy == null ? () => controller.share(formats) : null;
          return SizedBox(
            height: RefTouch.control,
            child: primary
                ? FilledButton.icon(key: key, onPressed: onPressed, icon: iconWidget, label: Text(label), style: style)
                : OutlinedButton.icon(key: key, onPressed: onPressed, icon: iconWidget, label: Text(label), style: style),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: 'Exportar y enviar al comité',
              subtitle: 'El PDF es el informe formal; el JSON permite archivarlo y verificar su huella.',
            ),
            MergeSemantics(
              child: SwitchListTile(
                key: const ValueKey('export-annex'),
                contentPadding: EdgeInsets.zero,
                value: controller.includeIncidentAnnex,
                onChanged: busy == null ? controller.setIncludeAnnex : null,
                title: Text('Incluir anexo de incidencias clave', style: RefType.body.copyWith(color: c.onSurface)),
                subtitle: Text(
                  'Cronología de las marcas de impacto alto o decisivo.',
                  style: RefType.caption.copyWith(color: c.onSurfaceMuted),
                ),
              ),
            ),
            const SizedBox(height: RefSpace.s),
            button(
              key: const ValueKey('share-pdf'),
              label: 'Compartir PDF',
              icon: Icons.picture_as_pdf_rounded,
              formats: const [ExportFormat.pdf],
              primary: true,
            ),
            const SizedBox(height: RefTouch.gap),
            Row(
              children: [
                Expanded(
                  child: button(
                    key: const ValueKey('share-json'),
                    label: 'JSON',
                    icon: Icons.data_object_rounded,
                    formats: const [ExportFormat.json],
                    primary: false,
                  ),
                ),
                const SizedBox(width: RefTouch.gap),
                Expanded(
                  child: button(
                    key: const ValueKey('share-both'),
                    label: 'PDF + JSON',
                    icon: Icons.attach_file_rounded,
                    formats: const [ExportFormat.pdf, ExportFormat.json],
                    primary: false,
                  ),
                ),
              ],
            ),
            if (controller.error != null)
              Padding(
                padding: const EdgeInsets.only(top: RefSpace.s),
                child: Semantics(
                  liveRegion: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_rounded, color: c.negative, size: 20),
                      const SizedBox(width: RefSpace.xs),
                      Expanded(
                        child: Text(controller.error!, style: RefType.caption.copyWith(color: c.negative)),
                      ),
                    ],
                  ),
                ),
              ),
            if (controller.lastShared.isNotEmpty && controller.error == null)
              Padding(
                padding: const EdgeInsets.only(top: RefSpace.s),
                child: Semantics(
                  liveRegion: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, color: c.positive, size: 20),
                      const SizedBox(width: RefSpace.xs),
                      Expanded(
                        child: Text(
                          'Preparado: ${controller.lastShared.map((f) => f.file.uri.pathSegments.last).join(' · ')}',
                          style: RefType.caption.copyWith(color: c.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
