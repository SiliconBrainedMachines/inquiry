import { strict as assert } from 'node:assert';
import { describe, it } from 'mocha';

// Smoke test: requires @vscode/test-electron runner.
// Marked as SKIP until Phase 5 sets up the full integration runner.

describe('extension module', function () {
  it.skip('exports activate and deactivate', () => {
    // Requires vscode module — only runnable inside VS Code host
    const extension = require('../../src/extension');
    assert.strictEqual(typeof extension.activate, 'function');
    assert.strictEqual(typeof extension.deactivate, 'function');
  });
});
