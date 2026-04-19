import { strict as assert } from 'node:assert';
import { describe, it } from 'mocha';

// These integration tests require @vscode/test-electron runner.
// Marked as SKIP until Phase 5 smoke test sets up the full runner.

describe('StatusBar integration', function () {
  it.skip('createStatusBar crea un StatusBarItem visible', () => {
    // Requires vscode API: window.createStatusBarItem
    assert.ok(true);
  });

  it.skip('updateStatusBar con ApeState actualiza text y tooltip del item', () => {
    // Requires vscode API: StatusBarItem.text, StatusBarItem.tooltip
    assert.ok(true);
  });

  it.skip('dispose limpia el item y el watcher', () => {
    // Requires vscode API: Disposable.dispose, FileSystemWatcher
    assert.ok(true);
  });
});
