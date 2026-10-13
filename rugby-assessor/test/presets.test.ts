import { test } from 'node:test';
import assert from 'node:assert/strict';
import { CATEGORY_PRESETS, categoryPreset } from '../domain/category-presets.ts';
import { appendClockEvent, foldClock, formatClock, matchTimeAt, type ClockEvent } from '../domain/clock.ts';

test('presets R6: duraciones y sin-bin exactos', () => {
  const table = Object.fromEntries(CATEGORY_PRESETS.map((c) => [c.code, [c.format, c.periodLengthMin, c.sinBinMin]]));
  assert.deepEqual(table, {
    SM_DHCAT_1_2_3: ['XV', 40, 10],
    SM_3AB_4: ['XV', 35, 10],
    SF_DHCAT_1: ['XV', 40, 10],
    SF_ABC_2: ['XV', 35, 10],
    M18: ['XV', 35, 5],
    M16: ['XV', 35, 5],
    M14: ['XV', 30, 5],
    SEVENS: ['SEVENS', 7, 2],
  });
  for (const c of CATEGORY_PRESETS) assert.equal(c.extraTime, null, `${c.code} sin prórroga`);
});

test('el snapshot de categoría no comparte referencias con el catálogo', () => {
  const snap = categoryPreset('M16');
  snap.competitions.push('x');
  assert.deepEqual(categoryPreset('M16').competitions, ['M16']);
  assert.throws(() => categoryPreset('M12'), /UNKNOWN_CATEGORY_PRESET/);
});

test('el reloj usa la duración del preset: M14 cumple a los 30:00 y 7s a los 07:00', () => {
  const MIN = 60_000;
  const m14 = categoryPreset('M14');
  let log: ClockEvent[] = appendClockEvent([], { type: 'PERIOD_START', period: 'H1' }, 0, m14);
  log = appendClockEvent(log, { type: 'PERIOD_END', next: 'INTERVAL' }, 31 * MIN, m14);
  log = appendClockEvent(log, { type: 'PERIOD_START', period: 'H2' }, 40 * MIN, m14);
  const mt = matchTimeAt(foldClock(log, m14), 71 * MIN, m14);
  assert.equal(formatClock(mt.matchClockMs), '61:00');   // H2 arranca en 30:00
  assert.equal(mt.overtimeMs, 1 * MIN);

  const s7 = categoryPreset('SEVENS');
  const l7 = appendClockEvent([], { type: 'PERIOD_START', period: 'H1' }, 0, s7);
  assert.equal(matchTimeAt(foldClock(l7, s7), 7 * MIN + 20_000, s7).overtimeMs, 20_000);
});
