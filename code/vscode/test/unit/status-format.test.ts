import { strict as assert } from 'node:assert';
import { describe, it } from 'mocha';
import { formatStatus } from '../../src/status-bar';

describe('formatStatus', () => {
  it('IDLE with no task', () => {
    const result = formatStatus('IDLE', '');
    assert.deepStrictEqual(result, {
      text: '$(circle-outline) APE: IDLE',
      tooltip: 'APE: IDLE',
    });
  });

  it('ANALYZE with task', () => {
    const result = formatStatus('ANALYZE', '042');
    assert.deepStrictEqual(result, {
      text: '$(search) APE: ANALYZE #042',
      tooltip: 'APE: ANALYZE — Task #042',
    });
  });

  it('PLAN with task', () => {
    const result = formatStatus('PLAN', '042');
    assert.deepStrictEqual(result, {
      text: '$(list-ordered) APE: PLAN #042',
      tooltip: 'APE: PLAN — Task #042',
    });
  });

  it('EXECUTE with task', () => {
    const result = formatStatus('EXECUTE', '042');
    assert.deepStrictEqual(result, {
      text: '$(rocket) APE: EXECUTE #042',
      tooltip: 'APE: EXECUTE — Task #042',
    });
  });

  it('EVOLUTION with no task', () => {
    const result = formatStatus('EVOLUTION', '');
    assert.deepStrictEqual(result, {
      text: '$(sparkle) APE: EVOLUTION',
      tooltip: 'APE: EVOLUTION',
    });
  });

  it('unknown phase uses default icon', () => {
    const result = formatStatus('UNKNOWN_PHASE', '');
    assert.deepStrictEqual(result, {
      text: '$(question) APE: UNKNOWN_PHASE',
      tooltip: 'APE: UNKNOWN_PHASE',
    });
  });

  it('END phase with task', () => {
    const result = formatStatus('END', '099');
    assert.deepStrictEqual(result, {
      text: '$(git-pull-request) APE: END #099',
      tooltip: 'APE: END — Task #099',
    });
  });
});
