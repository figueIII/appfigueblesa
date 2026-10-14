#!/usr/bin/env bash
# Regenera app/lib/domain/rubric_default.dart a partir de domain/rubric-default.ts.
# Uso: scripts/gen-rubric-dart.sh   (desde rugby-assessor/)
set -euo pipefail
node --experimental-strip-types -e "import('./domain/rubric-default.ts').then(m=>console.log(JSON.stringify(m.DEFAULT_RUBRIC)))" 2>/dev/null \
  | python3 scripts/gen_rubric_dart.py > app/lib/domain/rubric_default.dart
