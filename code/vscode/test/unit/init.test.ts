import * as assert from 'assert';
import { inquiryInit, InitDeps } from '../../src/init';

describe('inquiryInit', () => {
  it('shows error when no workspace folder', async () => {
    let errorMsg = '';
    const deps: InitDeps = {
      isInquiryInstalled: () => true,
      getInquiryBinaryPath: () => '/usr/bin/inquiry',
      showErrorMessage: (msg) => { errorMsg = msg; return Promise.resolve(undefined); },
      showInformationMessage: () => Promise.resolve(undefined),
      createTerminal: () => ({ show: () => {}, sendText: () => {} }),
      executeCommand: () => Promise.resolve(undefined),
    };

    await inquiryInit(undefined, deps);
    assert.strictEqual(errorMsg, 'Inquiry: Open a workspace folder first.');
  });

  it('runs ONLY inquiry init in terminal — no target get', async () => {
    let terminalName = '';
    const sentTexts: string[] = [];
    let infoMsg = '';
    const deps: InitDeps = {
      isInquiryInstalled: () => true,
      getInquiryBinaryPath: () => '/home/user/.inquiry/bin/inquiry',
      showErrorMessage: () => Promise.resolve(undefined),
      showInformationMessage: (msg) => { infoMsg = msg; return Promise.resolve(undefined); },
      createTerminal: (name) => {
        terminalName = name;
        return {
          show: () => {},
          sendText: (text) => { sentTexts.push(text); },
        };
      },
      executeCommand: () => Promise.resolve(undefined),
    };

    await inquiryInit('/workspace', deps);
    assert.strictEqual(terminalName, 'Inquiry Init');
    const prefix = process.platform === 'win32' ? '& ' : '';
    const q = '"';
    // Only ONE sendText: iq init — no target get
    assert.strictEqual(sentTexts.length, 1);
    assert.strictEqual(sentTexts[0], `${prefix}${q}/home/user/.inquiry/bin/inquiry${q} init`);
    // No target get command sent
    const hasTargetGet = sentTexts.some(t => /target\s+get/.test(t));
    assert.strictEqual(hasTargetGet, false, 'target get must NOT be sent after iq init');
    assert.ok(infoMsg.includes('Reload'));
  });

  it('reloads window when user accepts reload prompt', async () => {
    let executedCommand = '';
    const deps: InitDeps = {
      isInquiryInstalled: () => true,
      getInquiryBinaryPath: () => '/home/user/.inquiry/bin/inquiry',
      showErrorMessage: () => Promise.resolve(undefined),
      showInformationMessage: () => Promise.resolve('Reload'),
      createTerminal: () => ({ show: () => {}, sendText: () => {} }),
      executeCommand: (cmd) => { executedCommand = cmd; return Promise.resolve(undefined); },
    };

    await inquiryInit('/workspace', deps);
    assert.strictEqual(executedCommand, 'workbench.action.reloadWindow');
  });

  it('delegates to install flow when CLI missing', async () => {
    let installCalled = false;
    const deps: InitDeps = {
      isInquiryInstalled: () => false,
      getInquiryBinaryPath: () => '/usr/bin/inquiry',
      showErrorMessage: () => Promise.resolve(undefined),
      showInformationMessage: () => Promise.resolve(undefined),
      createTerminal: () => ({ show: () => {}, sendText: () => {} }),
      executeCommand: () => Promise.resolve(undefined),
    };

    await inquiryInit('/workspace', deps, async () => { installCalled = true; });
    assert.strictEqual(installCalled, true);
  });

  it('shows info message when CLI missing and no install callback', async () => {
    let infoMsg = '';
    const deps: InitDeps = {
      isInquiryInstalled: () => false,
      getInquiryBinaryPath: () => '/usr/bin/inquiry',
      showErrorMessage: () => Promise.resolve(undefined),
      showInformationMessage: (msg) => { infoMsg = msg; return Promise.resolve(undefined); },
      createTerminal: () => ({ show: () => {}, sendText: () => {} }),
      executeCommand: () => Promise.resolve(undefined),
    };

    await inquiryInit('/workspace', deps);
    assert.strictEqual(infoMsg, 'Inquiry CLI not found. Install it manually or wait for a future update.');
  });
});
