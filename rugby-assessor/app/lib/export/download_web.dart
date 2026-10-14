import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'report_exporter.dart';

/// En el navegador, "compartir" es descargar cada archivo.
BytesSharer? platformBytesSharer() => const _BrowserDownload();

class _BrowserDownload implements BytesSharer {
  const _BrowserDownload();

  @override
  Future<void> shareBytes(List<RenderedExport> files) async {
    for (final f in files) {
      final blob = web.Blob([f.bytes.toJS].toJS, web.BlobPropertyBag(type: f.mimeType));
      final url = web.URL.createObjectURL(blob);
      final a = web.HTMLAnchorElement()
        ..href = url
        ..download = f.fileName;
      web.document.body!.append(a);
      a.click();
      a.remove();
      // Se libera después: el navegador necesita la URL mientras inicia la descarga.
      Future<void>.delayed(const Duration(seconds: 30), () => web.URL.revokeObjectURL(url));
    }
  }
}
