"""Lee la rúbrica TS en JSON por stdin y escribe su equivalente Dart por stdout."""
import json
import sys

r = json.load(sys.stdin)
q = lambda s: "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"
band = {'E': 'BandCode.excellent', 'C': 'BandCode.competent', 'N': 'BandCode.notYet', 'U': 'BandCode.urgent'}
imp = {'LOW': 'ImpactLevel.low', 'MEDIUM': 'ImpactLevel.medium', 'HIGH': 'ImpactLevel.high', 'MATCH_DEFINING': 'ImpactLevel.matchDefining'}
ver = {'CORRECT': 'Verdict.correct', 'DEBATABLE': 'Verdict.debatable', 'INCORRECT': 'Verdict.incorrect', 'MISSED': 'Verdict.missed'}
o = []
o.append("// GENERADO desde domain/rubric-default.ts (rúbrica v%s) con scripts/gen-rubric-dart.sh.\n"
         "// No editar a mano: test/domain/scoring_test.dart comprueba pesos, bandas y topes.\n" % r['version'])
o.append("import 'model.dart';\nimport 'rubric.dart';\n")
opt = lambda k, d: f", {k}: {q(d[k])}" if d.get(k) else ''
o.append("final AssessmentRubric kDefaultRubric = AssessmentRubric(")
o.append(f"  id: {q(r['id'])},\n  code: {q(r['code'])},\n  version: {q(r['version'])},\n  name: {q(r['name'])},")
o.append(f"  scaleMin: {float(r['scale']['min'])},\n  scaleMax: {float(r['scale']['max'])},")
o.append("  bands: [")
for b in r['bands']:
    lower = 'double.negativeInfinity' if b['lower'] is None else str(float(b['lower']))  # JSON convierte -Infinity en null
    o.append(f"    PerformanceBand(code: {band[b['code']]}, label: {q(b['label'])}{opt('labelCa', b)}, description: {q(b['description'])}"
             f"{opt('descriptionCa', b)}, representative: {float(b['representative'])}, lower: {lower}, lowerInclusive: {str(b['lowerInclusive']).lower()}),")
o.append("  ],\n  areas: [")
for a in r['areas']:
    o.append(f"    RubricArea(code: {q(a['code'])}, name: {q(a['name'])}{opt('nameCa', a)}, weight: {float(a['weight'])}, criteria: [")
    for c in a['criteria']:
        level = f", level: {c['level']}" if c.get('level') else ''
        o.append(f"      Criterion(code: {q(c['code'])}{level}, name: {q(c['name'])}{opt('nameCa', c)}, weight: {float(c['weight'])}, description: {q(c['description'])}),")
    o.append("    ]),")
o.append("  ],")
s = r['scoring']
o.append("  scoring: ScoringParams(")
o.append("    impactWeights: {" + ", ".join(f"{imp[k]}: {float(v)}" for k, v in s['impactWeights'].items()) + "},")
o.append("    verdictCredit: {" + ", ".join(f"{ver[k]}: {float(v)}" for k, v in s['verdictCredit'].items()) + "},")
o.append(f"    accuracyAtZero: {float(s['accuracyToScore']['atZero'])},\n    accuracyAtOne: {float(s['accuracyToScore']['atOne'])},")
o.append(f"    baseline: {float(s['baseline'])},\n    priorStrength: {float(s['priorStrength'])},")
o.append("    capRules: [")
for c in s['capRules']:
    o.append(f"      CapRule(minImpact: {imp[c['minImpact']]}, minCount: {c['minCount']}, capBand: {band[c['capBand']]}),")
o.append("    ],")
o.append(f"    minJustificationChars: {s['minJustificationChars']},\n  ),\n);")
print("\n".join(o))
