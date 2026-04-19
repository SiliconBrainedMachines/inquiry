import * as assert from 'assert';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import { parseConfig, serializeConfig } from '../../src/parsers';

describe('toggleEvolution pure logic', () => {
  it('round-trip: false → flip → serialize → parse → true', () => {
    const config = parseConfig('');
    assert.strictEqual(config.evolutionEnabled, false);
    config.evolutionEnabled = !config.evolutionEnabled;
    const yaml = serializeConfig(config);
    const result = parseConfig(yaml);
    assert.strictEqual(result.evolutionEnabled, true);
  });

  it('round-trip: true → flip → serialize → parse → false', () => {
    const initial = serializeConfig({ evolutionEnabled: true });
    const config = parseConfig(initial);
    assert.strictEqual(config.evolutionEnabled, true);
    config.evolutionEnabled = !config.evolutionEnabled;
    const yaml = serializeConfig(config);
    const result = parseConfig(yaml);
    assert.strictEqual(result.evolutionEnabled, false);
  });

  it('double flip restores original value', () => {
    const original = serializeConfig({ evolutionEnabled: true });
    let config = parseConfig(original);
    config.evolutionEnabled = !config.evolutionEnabled;
    const mid = serializeConfig(config);
    config = parseConfig(mid);
    config.evolutionEnabled = !config.evolutionEnabled;
    const final = serializeConfig(config);
    const result = parseConfig(final);
    assert.strictEqual(result.evolutionEnabled, true);
  });
});

describe('toggleEvolution filesystem', () => {
  let tmpDir: string;

  beforeEach(() => {
    tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ape-toggle-'));
  });

  afterEach(() => {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  });

  it('lee config.yaml, invierte enabled, escribe el nuevo valor', () => {
    const configPath = path.join(tmpDir, 'config.yaml');
    fs.writeFileSync(configPath, serializeConfig({ evolutionEnabled: false }), 'utf-8');

    // Simulate toggleEvolution logic
    const content = fs.readFileSync(configPath, 'utf-8');
    const config = parseConfig(content);
    config.evolutionEnabled = !config.evolutionEnabled;
    fs.writeFileSync(configPath, serializeConfig(config), 'utf-8');

    const result = parseConfig(fs.readFileSync(configPath, 'utf-8'));
    assert.strictEqual(result.evolutionEnabled, true);
  });

  it('crea config.yaml con enabled=true si no existe', () => {
    const configPath = path.join(tmpDir, 'config.yaml');
    assert.strictEqual(fs.existsSync(configPath), false);

    // Simulate toggleEvolution logic with missing file
    let content = '';
    try {
      content = fs.readFileSync(configPath, 'utf-8');
    } catch {
      // file doesn't exist
    }
    const config = parseConfig(content);
    config.evolutionEnabled = !config.evolutionEnabled;
    fs.mkdirSync(path.dirname(configPath), { recursive: true });
    fs.writeFileSync(configPath, serializeConfig(config), 'utf-8');

    assert.strictEqual(fs.existsSync(configPath), true);
    const result = parseConfig(fs.readFileSync(configPath, 'utf-8'));
    assert.strictEqual(result.evolutionEnabled, true);
  });
});
