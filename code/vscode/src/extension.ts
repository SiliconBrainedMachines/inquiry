import * as vscode from 'vscode';
import * as path from 'path';
import { createStatusBar } from './status-bar';
import { toggleEvolution, addMutation } from './commands';

export function activate(context: vscode.ExtensionContext): void {
  const workspaceFolder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
  if (!workspaceFolder) { return; }

  const apeFolderPath = path.join(workspaceFolder, '.ape');

  createStatusBar(context, workspaceFolder);

  context.subscriptions.push(
    vscode.commands.registerCommand('ape.toggleEvolution', () =>
      toggleEvolution(apeFolderPath),
    ),
    vscode.commands.registerCommand('ape.addMutation', () =>
      addMutation(apeFolderPath),
    ),
  );
}

export function deactivate(): void {
}
