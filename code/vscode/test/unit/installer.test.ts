import * as assert from 'assert';
import { getAssetName, getInstallDir, installInquiryCli, InstallerDeps, selectReleaseForAsset } from '../../src/installer';

describe('getAssetName', () => {
  it('returns zip on win32', () => {
    assert.strictEqual(getAssetName('win32'), 'inquiry-windows-x64.zip');
  });

  it('returns tar.gz on linux', () => {
    assert.strictEqual(getAssetName('linux'), 'inquiry-linux-x64.tar.gz');
  });

  it('throws on unsupported platform', () => {
    assert.throws(() => getAssetName('darwin'), /Unsupported platform: darwin/);
  });
});

describe('getInstallDir', () => {
  it('returns LOCALAPPDATA path on win32', () => {
    const dir = getInstallDir('win32');
    assert.ok(dir.includes('inquiry'));
  });

  it('returns home/.inquiry on linux', () => {
    const dir = getInstallDir('linux');
    assert.ok(dir.endsWith('.inquiry'));
  });

  it('throws on unsupported platform', () => {
    assert.throws(() => getInstallDir('darwin'), /Unsupported platform: darwin/);
  });
});

describe('selectReleaseForAsset', () => {
  it('returns the newest published release that includes the asset', () => {
    const release = selectReleaseForAsset([
      { tag_name: 'v1.1.0', assets: [] },
      { tag_name: 'v1.0.0', assets: [{ name: 'inquiry-windows-x64.zip', browser_download_url: 'https://github.com/dl/win.zip' }] },
    ], 'inquiry-windows-x64.zip');

    assert.strictEqual(release.tag_name, 'v1.0.0');
  });

  it('ignores draft and prerelease entries when selecting an asset', () => {
    const release = selectReleaseForAsset([
      { tag_name: 'v1.2.0', draft: true, assets: [{ name: 'inquiry-windows-x64.zip', browser_download_url: 'https://github.com/dl/draft.zip' }] },
      { tag_name: 'v1.1.0', prerelease: true, assets: [{ name: 'inquiry-windows-x64.zip', browser_download_url: 'https://github.com/dl/pre.zip' }] },
      { tag_name: 'v1.0.0', assets: [{ name: 'inquiry-windows-x64.zip', browser_download_url: 'https://github.com/dl/win.zip' }] },
    ], 'inquiry-windows-x64.zip');

    assert.strictEqual(release.tag_name, 'v1.0.0');
  });

  it('throws when no published release contains the asset', () => {
    assert.throws(
      () => selectReleaseForAsset([{ tag_name: 'v1.1.0', assets: [] }], 'inquiry-windows-x64.zip'),
      /No inquiry-windows-x64.zip asset found in published releases/,
    );
  });
});

describe('installInquiryCli', () => {
  const tick = () => new Promise(r => setTimeout(r, 0));

  function baseDeps(platform: string): InstallerDeps {
    return {
      platform,
      tmpdir: () => (platform === 'win32' ? 'C:\\temp' : '/tmp'),
      fetchJson: async () => ([
        {
          tag_name: 'v1.0.0',
          assets: [
            { name: 'inquiry-windows-x64.zip', browser_download_url: 'https://github.com/dl/win.zip' },
            { name: 'inquiry-linux-x64.tar.gz', browser_download_url: 'https://github.com/dl/linux.tar.gz' },
          ],
        },
      ]),
      downloadFile: async () => {},
      extractZip: async () => {},
      extractTarGz: async () => {},
      execFile: async () => 'v1.0.0',
      mkdirp: async () => {},
      rmrf: async () => {},
      writeFile: async () => {},
      chmod: async () => {},
      symlink: async () => {},
      getEnvPath: () => '',
      setEnvPath: () => {},
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        const token = { onCancellationRequested: () => {} };
        await task(progress, token);
      },
    };
  }

  it('fetches release, downloads zip, and extracts on win32', async () => {
    let downloadedUrl = '';
    let extractedPath = '';
    let wroteIqCmd = false;
    const reports: string[] = [];

    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      downloadFile: async (url) => { downloadedUrl = url; },
      extractZip: async (p) => { extractedPath = p; },
      writeFile: async (f) => { if (f.endsWith('iq.cmd')) { wroteIqCmd = true; } },
      withProgress: async (_opts, task) => {
        const progress = { report: (v: { message?: string }) => { if (v.message) { reports.push(v.message); } } };
        const token = { onCancellationRequested: () => {} };
        await task(progress, token);
      },
    };

    await installInquiryCli(deps);
    assert.strictEqual(downloadedUrl, 'https://github.com/dl/win.zip');
    assert.ok(extractedPath.endsWith('.zip'));
    assert.ok(wroteIqCmd, 'should create iq.cmd');
    assert.ok(reports.includes('Fetching latest release...'));
    assert.ok(reports.some(r => r.startsWith('Downloading')));
    assert.ok(reports.includes('Extracting...'));
  });

  it('fetches release, downloads tar.gz, and extracts on linux', async () => {
    let downloadedUrl = '';
    let extractedTar = false;
    let chmodCalled = false;
    let symlinkTargets: string[] = [];

    const deps: InstallerDeps = {
      ...baseDeps('linux'),
      downloadFile: async (url) => { downloadedUrl = url; },
      extractTarGz: async () => { extractedTar = true; },
      chmod: async () => { chmodCalled = true; },
      symlink: async (_t, l) => { symlinkTargets.push(l); },
    };

    await installInquiryCli(deps);
    assert.strictEqual(downloadedUrl, 'https://github.com/dl/linux.tar.gz');
    assert.ok(extractedTar);
    assert.ok(chmodCalled);
    assert.ok(symlinkTargets.some(l => l.includes('inquiry')));
    assert.ok(symlinkTargets.some(l => l.includes('iq')));
  });

  it('falls back to the newest published release that has the platform asset', async () => {
    let downloadedUrl = '';
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      fetchJson: async () => ([
        { tag_name: 'v1.1.0', assets: [] },
        { tag_name: 'v1.0.0', assets: [{ name: 'inquiry-windows-x64.zip', browser_download_url: 'https://github.com/dl/fallback.zip' }] },
      ]),
      downloadFile: async (url) => { downloadedUrl = url; },
    };

    await installInquiryCli(deps);
    assert.strictEqual(downloadedUrl, 'https://github.com/dl/fallback.zip');
  });

  it('throws when no published release contains the asset', async () => {
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      fetchJson: async () => ([{ tag_name: 'v1.1.0', assets: [] }]),
    };

    await assert.rejects(() => installInquiryCli(deps), /No inquiry-windows-x64.zip asset found in published releases/);
  });

  it('rejects on download failure', async () => {
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      downloadFile: async () => { throw new Error('Network error'); },
    };

    await assert.rejects(() => installInquiryCli(deps), /Network error/);
  });

  it('rejects on cancellation', async () => {
    let cancelFn: (() => void) | undefined;
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      fetchJson: async () => {
        cancelFn!();
        return [{ tag_name: 'v1.0.0', assets: [{ name: 'inquiry-windows-x64.zip', browser_download_url: 'x' }] }];
      },
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        const token = { onCancellationRequested: (fn: () => void) => { cancelFn = fn; } };
        await task(progress, token);
      },
    };

    await assert.rejects(() => installInquiryCli(deps), /Installation cancelled/);
  });

  it('adds bin dir to process PATH', async () => {
    let newPath = '';
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      getEnvPath: () => 'C:\\existing',
      setEnvPath: (p) => { newPath = p; },
    };

    await installInquiryCli(deps);
    assert.ok(newPath.includes('inquiry'));
    assert.ok(newPath.includes('C:\\existing'));
  });

  it('runs host get and version after install', async () => {
    const commands: string[][] = [];
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      execFile: async (_cmd, args) => { commands.push(args); return 'v1.0.0'; },
    };

    await installInquiryCli(deps);
    assert.ok(commands.some(c => c.includes('host') && c.includes('get')));
    assert.ok(commands.some(c => c.includes('version')));
  });

  // `host get` changes things outside the CLI, so it refuses to act unless
  // told which of --plan and --apply was meant. The deploy is wrapped in a
  // catch, so getting this wrong is silent: the CLI installs, nothing is
  // deployed, and the user is told the install succeeded.
  it('deploys with --apply --autoapprove, not a bare `host get`', async () => {
    const commands: string[][] = [];
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      execFile: async (_cmd, args) => { commands.push(args); return 'v1.0.0'; },
    };

    await installInquiryCli(deps);

    const deploy = commands.find(c => c.includes('host') && c.includes('get'));
    assert.deepStrictEqual(deploy, ['host', 'get', '--apply', '--autoapprove']);
  });
});
