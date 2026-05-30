import * as assert from 'assert';
import { execSync } from 'child_process';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import { resolveBranch, resolveMutationsDir } from '../../src/cycle';

function git(cwd: string, args: string): void {
  execSync(`git ${args}`, { cwd, stdio: 'ignore' });
}

function initRepo(dir: string, branch: string): void {
  git(dir, 'init');
  git(dir, 'config user.email test@example.com');
  git(dir, 'config user.name test');
  git(dir, 'commit --allow-empty -m bootstrap');
  git(dir, `checkout -b ${branch}`);
}

describe('cycle resolution', () => {
  let tmpDir: string;

  beforeEach(() => {
    tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'iq-cycle-'));
  });

  afterEach(() => {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  });

  it('resolveBranch returns the current branch in a git repo', () => {
    initRepo(tmpDir, '209-test-branch');
    assert.strictEqual(resolveBranch(tmpDir), '209-test-branch');
  });

  it('resolveBranch returns null outside a git repo', () => {
    assert.strictEqual(resolveBranch(tmpDir), null);
  });

  it('resolveBranch returns null for slashed branch names', () => {
    initRepo(tmpDir, 'feature/nested');
    assert.strictEqual(resolveBranch(tmpDir), null);
  });

  it('resolveMutationsDir points at cleanrooms/<branch> on a valid branch', () => {
    initRepo(tmpDir, '209-test-branch');
    assert.strictEqual(
      resolveMutationsDir(tmpDir),
      path.join(tmpDir, 'cleanrooms', '209-test-branch'),
    );
  });

  it('resolveMutationsDir falls back to .inquiry outside a git repo', () => {
    assert.strictEqual(
      resolveMutationsDir(tmpDir),
      path.join(tmpDir, '.inquiry'),
    );
  });
});
