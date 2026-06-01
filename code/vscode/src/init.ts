import { isInquiryInstalled, getInquiryBinaryPath, getPlatform, shellExec } from './guard';

export interface InitTerminal {
  show: () => void;
  sendText: (text: string) => void;
}

export interface InitTerminalOptions {
  name: string;
  cwd?: string;
}

export interface InitDeps {
  isInquiryInstalled: () => boolean;
  getInquiryBinaryPath: () => string;
  showErrorMessage: (msg: string) => Thenable<string | undefined>;
  showInformationMessage: (msg: string, ...items: string[]) => Thenable<string | undefined>;
  createTerminal: (options: string | InitTerminalOptions) => InitTerminal;
  executeCommand: (command: string, ...args: any[]) => Thenable<unknown>;
}

export async function inquiryInit(
  workspaceFolder: string | undefined,
  deps?: Partial<InitDeps>,
  onInstallNeeded?: () => Promise<void>,
): Promise<void> {
  const vscode = deps ? undefined : require('vscode');

  const showErrorMessage = deps?.showErrorMessage
    ?? vscode.window.showErrorMessage.bind(vscode.window);
  const showInformationMessage = deps?.showInformationMessage
    ?? vscode.window.showInformationMessage.bind(vscode.window);
  const installed = deps?.isInquiryInstalled ?? (() => isInquiryInstalled());
  const binaryPath = deps?.getInquiryBinaryPath ?? (() => getInquiryBinaryPath(getPlatform()));
  const createTerminal = deps?.createTerminal
    ?? ((options: string | InitTerminalOptions) => vscode.window.createTerminal(options as any));
  const executeCommand = deps?.executeCommand ?? vscode.commands.executeCommand.bind(vscode.commands);

  if (!workspaceFolder) {
    showErrorMessage('Inquiry: Open a workspace folder first.');
    return;
  }

  if (!installed()) {
    if (onInstallNeeded) {
      try {
        await onInstallNeeded();
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        showErrorMessage(`Inquiry CLI installation failed: ${message}`);
        return;
      }

      if (!installed()) {
        showErrorMessage('Inquiry CLI installation failed. Please install manually.');
        return;
      }
    } else {
      showInformationMessage('Inquiry CLI not found. Install it manually or wait for a future update.');
      return;
    }
  }

  const terminal = createTerminal({ name: 'Inquiry Init', cwd: workspaceFolder });
  terminal.show();
  terminal.sendText(shellExec(binaryPath(), ['init']));

  // Copilot reads agent/skill files on activation; prompt reload so it picks them up.
  const action = await showInformationMessage(
    'Inquiry initialized. Reload window so Copilot detects the @inquiry agent?',
    'Reload',
  );
  if (action === 'Reload') {
    await executeCommand('workbench.action.reloadWindow');
  }
}
