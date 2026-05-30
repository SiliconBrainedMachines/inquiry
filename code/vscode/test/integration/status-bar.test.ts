import { strict as assert } from 'node:assert';
import * as fs from 'node:fs';
import type * as vscode from 'vscode';
import { afterEach, beforeEach, describe, it } from 'mocha';

import { createStatusBar } from '../../src/status-bar';
import { createCycleWorkspace, delay, removeTempWorkspace, waitFor } from './helpers';

describe('StatusBar integration', function () {
  this.timeout(5000);

  let root = '';
  let statePath = '';

  beforeEach(() => {
    const temp = createCycleWorkspace('inquiry-vscode-status-bar-', '209-status-bar');
    root = temp.root;
    statePath = temp.statePath;
  });

  afterEach(() => {
    removeTempWorkspace(root);
  });

  it('createStatusBar crea un StatusBarItem visible', async () => {
    const context = { subscriptions: [] as vscode.Disposable[] } as unknown as vscode.ExtensionContext;
    const [item, watcher] = createStatusBar(context, root) as [vscode.StatusBarItem, vscode.FileSystemWatcher];

    await waitFor(() => item.text.includes('Inquiry: IDLE'));

    assert.match(item.text, /Inquiry: IDLE/);
    assert.strictEqual(String(item.tooltip), 'Inquiry: IDLE');
    assert.strictEqual(context.subscriptions.length, 2);

    watcher.dispose();
    item.dispose();
  });

  it('updateStatusBar con ApeState actualiza text y tooltip del item', async () => {
    fs.writeFileSync(statePath, 'state: PLAN\nissue: "042"\n', 'utf-8');
    const context = { subscriptions: [] as vscode.Disposable[] } as unknown as vscode.ExtensionContext;
    const [item, watcher] = createStatusBar(context, root) as [vscode.StatusBarItem, vscode.FileSystemWatcher];

    await waitFor(() => item.text.includes('PLAN #042'));

    assert.match(item.text, /Inquiry: PLAN #042/);
    assert.strictEqual(String(item.tooltip), 'Inquiry: PLAN — Task #042');

    watcher.dispose();
    item.dispose();
  });

  it('status completed deriva IDLE en la barra', async () => {
    fs.writeFileSync(statePath, 'state: EVOLUTION\nissue: "209"\nstatus: completed\n', 'utf-8');
    const context = { subscriptions: [] as vscode.Disposable[] } as unknown as vscode.ExtensionContext;
    const [item, watcher] = createStatusBar(context, root) as [vscode.StatusBarItem, vscode.FileSystemWatcher];

    await waitFor(() => item.text.includes('Inquiry: IDLE'));

    assert.match(item.text, /Inquiry: IDLE/);
    assert.strictEqual(String(item.tooltip), 'Inquiry: IDLE');

    watcher.dispose();
    item.dispose();
  });

  it('dispose limpia el item y el watcher', async () => {
    fs.writeFileSync(statePath, 'state: ANALYZE\nissue: "042"\n', 'utf-8');
    const context = { subscriptions: [] as vscode.Disposable[] } as unknown as vscode.ExtensionContext;
    const [item, watcher] = createStatusBar(context, root) as [vscode.StatusBarItem, vscode.FileSystemWatcher];

    await waitFor(() => item.text.includes('ANALYZE #042'));
    const beforeDispose = item.text;

    watcher.dispose();
    item.dispose();

    fs.writeFileSync(statePath, 'state: EXECUTE\nissue: "042"\n', 'utf-8');
    await delay(250);

    assert.strictEqual(item.text, beforeDispose);
  });
});
