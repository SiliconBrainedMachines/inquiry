import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import { execSync } from 'node:child_process';
import * as vscode from 'vscode';

export function createTempWorkspace(prefix: string): {
  root: string;
  inquiryPath: string;
} {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), prefix));
  const inquiryPath = path.join(root, '.inquiry');
  fs.mkdirSync(inquiryPath, { recursive: true });
  return { root, inquiryPath };
}

/**
 * Create a temp workspace that is a real git repo checked out on `branch`,
 * with the cycle-local directory `cleanrooms/<branch>` already present.
 * Returns the resolved path of the cycle FSM state file (`.iq.state.yaml`).
 */
export function createCycleWorkspace(
  prefix: string,
  branch: string,
): {
  root: string;
  cyclePath: string;
  statePath: string;
} {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), prefix));
  const git = (args: string): void =>
    void execSync(`git ${args}`, { cwd: root, stdio: 'ignore' });
  git('init');
  git('config user.email test@example.com');
  git('config user.name test');
  git('commit --allow-empty -m bootstrap');
  git(`checkout -b ${branch}`);
  const cyclePath = path.join(root, 'cleanrooms', branch);
  fs.mkdirSync(cyclePath, { recursive: true });
  const statePath = path.join(cyclePath, '.iq.state.yaml');
  return { root, cyclePath, statePath };
}

export function removeTempWorkspace(root: string): void {
  fs.rmSync(root, { recursive: true, force: true });
}

export function stubWindowMethod(
  name: 'showInputBox' | 'showInformationMessage',
  impl: unknown,
): () => void {
  const windowAny = vscode.window as unknown as Record<string, unknown>;
  const original = windowAny[name];
  const hadOwn = Object.prototype.hasOwnProperty.call(windowAny, name);

  Object.defineProperty(windowAny, name, {
    value: impl,
    configurable: true,
    writable: true,
  });

  return () => {
    if (hadOwn) {
      Object.defineProperty(windowAny, name, {
        value: original,
        configurable: true,
        writable: true,
      });
      return;
    }

    delete windowAny[name];
  };
}

export function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

export async function waitFor(
  predicate: () => boolean,
  timeoutMs = 3000,
  intervalMs = 25,
): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (predicate()) {
      return;
    }
    await delay(intervalMs);
  }
  throw new Error('Timed out waiting for condition');
}
