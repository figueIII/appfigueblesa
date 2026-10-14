#!/usr/bin/env python3
"""Empaqueta la compilación web de Flutter (build/web) en UN SOLO archivo HTML autónomo.

Uso: python3 scripts/pack_single_html.py build/web salida.html [titulo]

El HTML lleva dentro (comprimidos con gzip y en base64) el código de la app, el motor gráfico
CanvasKit, SQLite en WebAssembly, las fuentes y los recursos. Un cargador pequeño los
descomprime al abrir la página y los sirve desde memoria: interpreta las peticiones (fetch) y
las etiquetas <script> que hace Flutter. Así la página funciona abierta como archivo local
(file://), sin servidor y sin conexión.

Solo se incluye la variante "completa" de CanvasKit (válida en Chrome, Safari y Firefox) y se
omiten los símbolos de depuración y las variantes que no se usan.
"""

import base64
import gzip
import json
import mimetypes
import os
import re
import sys

SKIP_DIRS = {"canvaskit/chromium", "canvaskit/webparagraph", "icons"}
SKIP_SUFFIXES = (".symbols",)
SKIP_FILES = {
    "index.html",
    "flutter.js",
    "flutter_bootstrap.js",
    "flutter_service_worker.js",
    "manifest.json",
    "canvaskit/skwasm.js",
    "canvaskit/skwasm.wasm",
    "canvaskit/skwasm_heavy.js",
    "canvaskit/skwasm_heavy.wasm",
    "canvaskit/wimp.js",
    "canvaskit/wimp.wasm",
}
MIME = {".wasm": "application/wasm", ".js": "text/javascript", ".json": "application/json", ".otf": "font/otf", ".ttf": "font/ttf"}


def collect(root):
    files = {}
    for dirpath, _, names in os.walk(root):
        rel_dir = os.path.relpath(dirpath, root).replace(os.sep, "/")
        rel_dir = "" if rel_dir == "." else rel_dir
        if any(rel_dir == d or rel_dir.startswith(d + "/") for d in SKIP_DIRS):
            continue
        for n in names:
            rel = f"{rel_dir}/{n}" if rel_dir else n
            if rel in SKIP_FILES or rel.endswith(SKIP_SUFFIXES):
                continue
            with open(os.path.join(dirpath, n), "rb") as fh:
                data = fh.read()
            ext = os.path.splitext(n)[1]
            mime = MIME.get(ext) or mimetypes.guess_type(n)[0] or "application/octet-stream"
            files[rel] = {"t": mime, "z": base64.b64encode(gzip.compress(data, 9, mtime=0)).decode("ascii"), "n": len(data)}
    return files


LOADER = r"""
(function () {
  'use strict';
  var FILES = window.__REFASSESS_FILES__;
  var urls = {};
  var names = Object.keys(FILES);

  // "file:///…/assets/x.json", "./assets/x.json", "/assets/x.json" → "assets/x.json"
  function key(url) {
    if (url == null) return null;
    var u = String(url);
    if (u.startsWith('blob:') || u.startsWith('data:')) return null;
    u = u.split('#')[0].split('?')[0];
    for (var i = 0; i < names.length; i++) {
      var n = names[i];
      if (u === n || u.endsWith('/' + n)) return n;
    }
    // Nombre corto ("canvaskit.wasm") si solo hay un archivo con ese nombre.
    var base = u.substring(u.lastIndexOf('/') + 1);
    var same = names.filter(function (n) { return n === base || n.endsWith('/' + base); });
    return same.length === 1 ? same[0] : null;
  }

  async function unpack(name) {
    var f = FILES[name];
    var bin = Uint8Array.from(atob(f.z), function (c) { return c.charCodeAt(0); });
    var stream = new Blob([bin]).stream().pipeThrough(new DecompressionStream('gzip'));
    var buf = await new Response(stream).arrayBuffer();
    return URL.createObjectURL(new Blob([buf], { type: f.t }));
  }

  var realFetch = window.fetch.bind(window);
  window.fetch = function (input, init) {
    var k = key(typeof input === 'string' || input instanceof URL ? input : input && input.url);
    if (k && urls[k]) return realFetch(urls[k], init);
    return realFetch(input, init);
  };

  // Flutter añade <script src="main.dart.js"> y <script src="canvaskit/canvaskit.js">.
  var desc = Object.getOwnPropertyDescriptor(HTMLScriptElement.prototype, 'src');
  Object.defineProperty(HTMLScriptElement.prototype, 'src', {
    configurable: true,
    enumerable: desc.enumerable,
    get: function () { return desc.get.call(this); },
    set: function (v) {
      var k = key(v);
      desc.set.call(this, k && urls[k] ? urls[k] : v);
    },
  });

  window.__refassessReady = (async function () {
    var status = document.getElementById('boot-status');
    for (var i = 0; i < names.length; i++) {
      if (status) status.textContent = 'Preparando la app… ' + Math.round((i / names.length) * 100) + ' %';
      urls[names[i]] = await unpack(names[i]);
    }
    // CanvasKit se carga con import() dinámico (no pasa por <script>): se precarga aquí, desde
    // memoria, y Flutter lo reutiliza (window.flutterCanvasKit).
    if (status) status.textContent = 'Cargando el motor gráfico…';
    var mod = await import(urls['canvaskit/canvaskit.js']);
    window.flutterCanvasKit = await mod.default({
      locateFile: function (file) { return urls['canvaskit/' + file] || file; },
      instantiateWasm: function (imports, done) {
        WebAssembly.instantiateStreaming(realFetch(urls['canvaskit/canvaskit.wasm']), imports)
          .then(function (r) { done(r.instance, r.module); });
        return {};
      },
    });
    if (status) status.textContent = 'Arrancando…';
  })();
})();
"""

PAGE = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="RefAssess {version}: versión HTML de pruebas de la app de evaluación arbitral.">
<title>{title}</title>
<style>
  html, body {{ margin: 0; height: 100%; background: #ffffff; }}
  #boot {{ position: fixed; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center;
          font: 600 16px/1.4 system-ui, -apple-system, Roboto, sans-serif; color: #0f172a; gap: 8px; padding: 16px; text-align: center; }}
  #boot small {{ color: #334155; font-weight: 500; }}
  @media (prefers-color-scheme: dark) {{ html, body {{ background: #020617; }} #boot {{ color: #f8fafc; }} #boot small {{ color: #cbd5e1; }} }}
</style>
</head>
<body>
<div id="boot"><div>RefAssess {version} · versión de pruebas</div><div id="boot-status">Preparando la app…</div>
<small>Los datos se guardan solo en este navegador. No sirve para evaluar partidos reales.</small></div>
<script>window.__REFASSESS_FILES__ = {files};</script>
<script>{loader}</script>
<script>{flutter_js}</script>
<script>
{build_config}
window.__refassessReady.then(function () {{
  _flutter.loader.load({{
    config: {{ canvasKitVariant: 'full', canvasKitBaseUrl: 'canvaskit/' }},
    onEntrypointLoaded: async function (engineInitializer) {{
      var appRunner = await engineInitializer.initializeEngine();
      var boot = document.getElementById('boot');
      if (boot) boot.remove();
      await appRunner.runApp();
    }},
  }});
}}).catch(function (e) {{
  document.getElementById('boot-status').textContent = 'No se ha podido arrancar: ' + e;
}});
</script>
</body>
</html>
"""


def main():
    root, out = sys.argv[1], sys.argv[2]
    title = sys.argv[3] if len(sys.argv) > 3 else "RefAssess · pruebas"
    version = json.load(open(os.path.join(root, "version.json"))).get("version", "")
    files = collect(root)
    flutter_js = open(os.path.join(root, "flutter.js"), encoding="utf-8").read()
    bootstrap = open(os.path.join(root, "flutter_bootstrap.js"), encoding="utf-8").read()
    m = re.search(r"_flutter\.buildConfig\s*=\s*\{.*?\};", bootstrap, re.S)
    if not m:
        sys.exit("No se encuentra _flutter.buildConfig en flutter_bootstrap.js")
    html = PAGE.format(
        title=title,
        version=version,
        files=json.dumps(files, separators=(",", ":")),
        loader=LOADER,
        flutter_js=flutter_js.replace("</script", "<\\/script"),
        build_config=m.group(0),
    )
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    with open(out, "w", encoding="utf-8") as fh:
        fh.write(html)
    total = sum(f["n"] for f in files.values())
    print(f"{out}: {os.path.getsize(out) / 1e6:.1f} MB ({len(files)} archivos, {total / 1e6:.1f} MB sin comprimir)")


if __name__ == "__main__":
    main()
