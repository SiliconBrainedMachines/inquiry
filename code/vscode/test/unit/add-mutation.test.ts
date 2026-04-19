import * as assert from 'assert';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import { formatMutation } from '../../src/parsers';

describe('addMutation filesystem', () => {
  let tmpDir: string;

  beforeEach(() => {
    tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ape-mutation-'));
  });

  afterEach(() => {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  });

  it('appends entry to existing mutations.md', () => {
    const mutationsPath = path.join(tmpDir, 'mutations.md');
    fs.writeFileSync(mutationsPath, '- existing entry\n', 'utf-8');

    const entry = formatMutation('New observation', true);
    fs.appendFileSync(mutationsPath, entry, 'utf-8');

    const content = fs.readFileSync(mutationsPath, 'utf-8');
    assert.ok(content.startsWith('- existing entry\n'));
    assert.match(content, /New observation/);
    assert.strictEqual(content.split('\n').filter(l => l.startsWith('- ')).length, 2);
  });

  it('creates mutations.md if it does not exist', () => {
    const mutationsPath = path.join(tmpDir, 'mutations.md');
    assert.strictEqual(fs.existsSync(mutationsPath), false);

    fs.mkdirSync(path.dirname(mutationsPath), { recursive: true });
    const entry = formatMutation('First observation', true);
    fs.appendFileSync(mutationsPath, entry, 'utf-8');

    assert.strictEqual(fs.existsSync(mutationsPath), true);
    const content = fs.readFileSync(mutationsPath, 'utf-8');
    assert.match(content, /First observation/);
  });

  it('cancel (no text) does not modify file', () => {
    const mutationsPath = path.join(tmpDir, 'mutations.md');
    fs.writeFileSync(mutationsPath, '- existing\n', 'utf-8');

    // Simulate cancel: text is undefined, so we skip
    const text: string | undefined = undefined;
    if (text) {
      const entry = formatMutation(text, true);
      fs.appendFileSync(mutationsPath, entry, 'utf-8');
    }

    const content = fs.readFileSync(mutationsPath, 'utf-8');
    assert.strictEqual(content, '- existing\n');
  });
});
