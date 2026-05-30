import * as path from 'path';
import { execSync } from 'child_process';

const BRANCH_DENYLIST = new Set(['', 'HEAD']);

/**
 * Resolve the current git branch for the given workspace folder.
 * Returns null when not in a git repo, on an unborn/detached HEAD,
 * or when the branch name contains a path separator (not a valid cycle slug).
 */
export function resolveBranch(workspaceFolder: string): string | null {
  let branch: string;
  try {
    branch = execSync('git rev-parse --abbrev-ref HEAD', {
      cwd: workspaceFolder,
      encoding: 'utf-8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
  } catch {
    return null;
  }
  if (BRANCH_DENYLIST.has(branch) || branch.includes('/')) {
    return null;
  }
  return branch;
}

/**
 * Resolve the directory that holds the cycle-local mutations.md.
 * On a valid branch, returns `<workspaceFolder>/cleanrooms/<branch>`.
 * Otherwise falls back to the project-scoped `<workspaceFolder>/.inquiry`.
 */
export function resolveMutationsDir(workspaceFolder: string): string {
  const branch = resolveBranch(workspaceFolder);
  if (branch === null) {
    return path.join(workspaceFolder, '.inquiry');
  }
  return path.join(workspaceFolder, 'cleanrooms', branch);
}

/**
 * Resolve the cycle-local FSM state file for the given workspace folder.
 * Returns `<workspaceFolder>/cleanrooms/<branch>/.iq.state.yaml` on a valid
 * branch, or null when no cycle resolves (no git repo / unborn / detached /
 * slashed branch) — the caller derives IDLE in that case.
 */
export function resolveStatePath(workspaceFolder: string): string | null {
  const branch = resolveBranch(workspaceFolder);
  if (branch === null) {
    return null;
  }
  return path.join(workspaceFolder, 'cleanrooms', branch, '.iq.state.yaml');
}
