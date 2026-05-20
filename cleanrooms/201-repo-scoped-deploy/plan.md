---
id: plan
title: "Plan de desarrollo TDD — feat(target): repo-scoped deploy + target exclusivo (issue #201)"
date: 2026-05-20
status: active
tags: [plan, tdd, repo-scoped, deploy, 0.5.0, target-flag, risk-mitigations]
author: inquiry
---

# Plan de Desarrollo: Repo-Scoped Deploy + Target Exclusivo (v0.5.0)

## Hipótesis Central

> Si `iq init` despliega `inquiry.agent.md` exclusivamente en `.github/agents/`,
> `iq target get` despliega solo skills al target especificado (excluyendo los demás),
> y `iq doctor` verifica el contrato repo-scoped,
> entonces Inquiry dejará de contaminar el espacio de nombres global de VS Code Agents
> y el usuario podrá cambiar de target sin residuos cruzados.

**Base empírica:** Diagnóstico en `analyze/diagnosis.md` (D1–D4, F1–F8, R1–R6).
**Riesgos mitigados:** Ver `analyze/risk-analysis.md` (R1–R7).

---

## Restricciones del Experimento

- Solo se modifica lo que el diagnóstico confirma con evidencia de código exacta.
- Cada etapa comienza con tests en ROJO. No se escribe implementación antes de fallar.
- Cada etapa termina con `dart test` verde y un commit atómico.
- Los tests existentes que contradigan la nueva conducta se actualizan — no se borran sin justificación.
- **Serie 0.x.x — sin retrocompatibilidad.** El upgrade path es: `iq uninstall` → instalar `0.5.0`.
- Versión objetivo: `0.5.0`.

---

## Mapa de Etapas

| Etapa | Alcance | Contrato que cambia |
|-------|---------|---------------------|
| E1 | `iq init` despliega agente → `.github/agents/` | `InitCommand` + assets threading |
| E2 | `iq target get --target` con deploy exclusivo de skills | `TargetDeployer` + `TargetGetInput` + `TargetGetCommand` |
| E3 | `iq doctor` verifica nuevo contrato | `DoctorCommand` + `TargetCheck` + 5 tests afectados |
| E4 | Extension: elimina `target get` del init flow | `code/vscode/src/init.ts` |
| E5 | Uninstall + target clean: limpia agente repo-scoped | `UninstallCommand` + `TargetCleanCommand` |
| E6 | Bump de versión y changelog | `pubspec.yaml`, `CHANGELOG.md` |

---

## E1 — `iq init` despliega el agente a `.github/agents/`

### Hipótesis E1

`InitCommand` puede leer `assets/agents/inquiry.agent.md` y escribirlo en
`<workingDirectory>/.github/agents/inquiry.agent.md` como un séptimo paso idempotente,
sin necesitar un `TargetDeployer` completo.

### Evidencia de referencia

- `init.dart:89` — "Deploy is handled by `inquiry target get` — not duplicated here." → punto exacto de inserción.
- `init_command_test.dart` — patrón `InitInput(workingDirectory: tempDir.path)`.
- `assets.dart:loadString()` — interfaz lista para leer `agents/inquiry.agent.md`.
- `global_builder.dart:23-26` — `InitCommand(InitInput.fromCliRequest(req))` — sin assets.
- `inquiry_cli.dart:45-47` — `buildGlobalModule(m, cleaner: cleaner, assets: assets)` — assets disponible aquí.

### ⚠️ Mitigación R1: Assets threading

**Problema:** El plan original ponía `Assets assets` como requerido en `InitInput`.
`InitInput.fromCliRequest()` no tiene acceso a `assetsRoot` → no puede construir `Assets`.
Además rompe todos los tests existentes de init.

**Decisión:** `Assets` es parámetro opcional **de `InitCommand`** (no de `InitInput`).
El paso 7 se omite silenciosamente si `assets == null` (testable: tests sin assets no rompen).

```dart
// global_builder.dart — threading correcto:
(req) => InitCommand(InitInput.fromCliRequest(req), assets: assets)
// donde `assets` viene del parámetro de buildGlobalModule — ya existe: Assets? assets
```

### Tests (escribir primero — deben FALLAR)

```dart
// test/init_command_test.dart — grupo: 'agent deploy to .github/agents/'

test('iq init escribe inquiry.agent.md en .github/agents/', () async {
  final agentsAssetDir = Directory('${tempDir.path}/assets/agents');
  agentsAssetDir.createSync(recursive: true);
  File('${agentsAssetDir.path}/inquiry.agent.md')
      .writeAsStringSync('# APE Agent');

  final command = InitCommand(
    InitInput(workingDirectory: tempDir.path),
    assets: Assets(root: tempDir.path),  // assets como 2do param del comando
  );

  await command.execute();

  expect(
    File('${tempDir.path}/.github/agents/inquiry.agent.md').existsSync(),
    isTrue,
  );
  expect(
    File('${tempDir.path}/.github/agents/inquiry.agent.md')
        .readAsStringSync(),
    contains('APE Agent'),
  );
});

test('iq init es idempotente — segunda ejecución sobreescribe el agente', () async {
  final agentsAssetDir = Directory('${tempDir.path}/assets/agents');
  agentsAssetDir.createSync(recursive: true);
  File('${agentsAssetDir.path}/inquiry.agent.md')
      .writeAsStringSync('# APE Agent v1');

  final command = InitCommand(
    InitInput(workingDirectory: tempDir.path),
    assets: Assets(root: tempDir.path),
  );

  await command.execute();
  File('${agentsAssetDir.path}/inquiry.agent.md')
      .writeAsStringSync('# APE Agent v2');
  await command.execute();

  expect(
    File('${tempDir.path}/.github/agents/inquiry.agent.md')
        .readAsStringSync(),
    contains('APE Agent v2'),
  );
});

test('iq init sin assets omite el paso 7 silenciosamente', () async {
  // Assets null — tests existentes siguen pasando
  final command = InitCommand(InitInput(workingDirectory: tempDir.path));

  await command.execute();

  expect(
    File('${tempDir.path}/.github/agents/inquiry.agent.md').existsSync(),
    isFalse,
    reason: 'Sin assets no debe escribir el archivo de agente',
  );
});
```

### Implementación E1

1. **`InitCommand`**: añadir `Assets? assets` como segundo parámetro del constructor.
2. **`InitCommand.execute()`**: añadir Paso 7 — llama `_deployAgent()` si `assets != null`.
3. **`_deployAgent()`**:
   ```dart
   void _deployAgent(String root, Assets assets, List<String> steps) {
     final content = assets.loadString('agents/inquiry.agent.md');
     final target = File('$root/.github/agents/inquiry.agent.md');
     target.parent.createSync(recursive: true);
     target.writeAsStringSync(content);
     steps.add('Deployed inquiry.agent.md to .github/agents/');
   }
   ```
4. **`global_builder.dart`**: pasar `assets` al constructor de `InitCommand`.

### Verificar E1

```
dart test test/init_command_test.dart
```

### Commit E1

```
feat(init): deploy inquiry.agent.md to .github/agents/ (E1)

- InitCommand acepta Assets? como segundo param (no en InitInput)
- Paso 7: escribe inquiry.agent.md en <repo>/.github/agents/
- Idempotente: sobreescribe en re-init
- Sin assets → paso se omite silenciosamente (tests existentes no rompen)
- global_builder.dart: thread assets desde buildGlobalModule

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

## E2 — `iq target get --target` con deploy exclusivo de skills

### Hipótesis E2

`iq target get` puede aceptar un flag `--target` (default: `copilot`) y desplegar
skills exclusivamente al target especificado, limpiando los demás antes de desplegar.
El agente **ya no se despliega** desde `target get` (E1 lo resuelve).
Solo un target activo a la vez previene que GitHub Copilot lea directorios de otros
tools (e.g., `.claude/`).

### Evidencia de referencia

- `deployer.dart:23-30` — `deploy()` llama `_deploySkills()` y `_deployAgents()`.
- `all_adapters.dart` — 5 adapters: copilot, claude, codex, opencode, gemini.
- `get.dart:TargetGetInput.fromCliRequest` — actualmente sin opciones.
- `target_builder.dart:14` — description desactualizada (R7).
- `target_builder.dart` — `TargetGetCommand` recibe `deployer` (deployAdapters = [CopilotAdapter]).
  → Cambiar a `cleaner` (allAdapters) para poder limpiar todos antes de desplegar al seleccionado.

### ⚠️ Mitigaciones R2, R5, R7

**R2 — Ghost file en `iq uninstall` (path antiguo `~/.copilot/agents/`):**
`clean()` NO cambia: sigue limpiando `agentDirectory` de todos los adapters.
Esto asegura que `iq uninstall` y `iq target clean` eliminen el agente global de versiones anteriores.

**R5 — `iq target clean` deja el agente repo-scoped sin limpiar:**
El agente repo-scoped (`.github/agents/inquiry.agent.md`) no está en ningún `adapter.agentDirectory()`.
Se limpia explícitamente en E5 (`TargetCleanCommand` y `UninstallCommand`).

**R7 — Descripción de `target_builder.dart:14` desactualizada:**
Actualizar: `'Deploy Inquiry agents and skills to Copilot'` → `'Deploy Inquiry skills to the specified target'`.

### Arquitectura del deploy exclusivo

```
iq target get [--target=copilot|claude|codex|opencode|gemini]
  │
  ├── cleaner.clean()          // 1. Limpia skills + agents (old path) de TODOS los adapters
  └── cleaner._deploySkills(   // 2. Despliega skills solo al adapter seleccionado
        adapterNamed(target)   //    NO _deployAgents() — agente es repo-scoped via iq init
      )
```

`_deployAgents()` se elimina de `TargetDeployer` (dead code tras E1+E2).
`deploy()` se **elimina completamente** — no queda como alias. Callers a actualizar: `TargetGetCommand.execute()` (único caller en producción tras E2).

### Tests (escribir primero — deben FALLAR)

```dart
// test/deployer_test.dart

// ─── deployExclusive() ───────────────────────────────────────────────────

test('deployExclusive despliega skills solo al adapter seleccionado', () {
  deployer.deployExclusive('copilot');

  expect(
    File(p.join(homeDir.path, '.copilot', 'skills', 'doc-read', 'SKILL.md'))
        .existsSync(),
    isTrue,
    reason: 'Copilot skills deben existir',
  );
  expect(
    File(p.join(homeDir.path, '.claude', 'skills', 'doc-read', 'SKILL.md'))
        .existsSync(),
    isFalse,
    reason: 'Claude skills NO deben existir cuando target=copilot',
  );
});

test('deployExclusive elimina skills previas del target no seleccionado', () {
  // Pre-popular claude skills
  final claudeSkill = File(p.join(homeDir.path, '.claude', 'skills', 'old-skill', 'SKILL.md'));
  claudeSkill.parent.createSync(recursive: true);
  claudeSkill.writeAsStringSync('old');

  deployer.deployExclusive('copilot');

  expect(claudeSkill.existsSync(), isFalse,
      reason: 'Skills de otros targets se limpian en deploy exclusivo');
});

test('deployExclusive NO escribe inquiry.agent.md en agentDirectory del adapter', () {
  deployer.deployExclusive('copilot');

  expect(
    File(p.join(homeDir.path, '.copilot', 'agents', 'inquiry.agent.md'))
        .existsSync(),
    isFalse,
    reason: 'El agente es repo-scoped — target get no lo despliega',
  );
});

test('deployExclusive lanza ArgumentError para target desconocido', () {
  expect(
    () => deployer.deployExclusive('unknown'),
    throwsA(isA<ArgumentError>()),
  );
});

test('clean() sigue limpiando agentDirectory de todos los adapters', () {
  // Pre-popular agent en copilot (residuo de versión anterior)
  final oldAgent = File(p.join(homeDir.path, '.copilot', 'agents', 'inquiry.agent.md'));
  oldAgent.parent.createSync(recursive: true);
  oldAgent.writeAsStringSync('old agent');

  deployer.clean();

  expect(oldAgent.existsSync(), isFalse,
      reason: 'clean() sigue limpiando agentDirectory para compatibilidad upgrade');
});

// ─── TargetGetInput ───────────────────────────────────────────────────────

// test/target_commands_test.dart

test('TargetGetInput.fromCliRequest usa target=copilot por defecto', () {
  final input = TargetGetInput.fromCliRequest(emptyCliRequest());
  expect(input.target, 'copilot');
});

test('TargetGetInput.fromCliRequest lee --target del CLI', () {
  final input = TargetGetInput.fromCliRequest(cliRequestWith({'target': 'claude'}));
  expect(input.target, 'claude');
});

// ─── TargetGetCommand ────────────────────────────────────────────────────

test('iq target get despliega skills exclusivamente a copilot (default)', () async {
  final cmd = TargetGetCommand(TargetGetInput(), deployer: allAdaptersDeployer);
  final output = await cmd.execute();

  expect(output.exitCode, ExitCode.ok);
  expect(
    File(p.join(homeDir.path, '.copilot', 'skills', 'doc-read', 'SKILL.md'))
        .existsSync(),
    isTrue,
  );
  expect(
    File(p.join(homeDir.path, '.claude', 'skills', 'doc-read', 'SKILL.md'))
        .existsSync(),
    isFalse,
  );
});

test('iq target get --target=claude despliega a claude y limpia copilot', () async {
  // Pre-popular copilot skills
  final copilotSkill = File(p.join(homeDir.path, '.copilot', 'skills', 'doc-read', 'SKILL.md'));
  copilotSkill.parent.createSync(recursive: true);
  copilotSkill.writeAsStringSync('old');

  final cmd = TargetGetCommand(TargetGetInput(target: 'claude'), deployer: allAdaptersDeployer);
  await cmd.execute();

  expect(copilotSkill.existsSync(), isFalse,
      reason: 'Copilot skills limpiadas al cambiar a claude');
  expect(
    File(p.join(homeDir.path, '.claude', 'skills', 'doc-read', 'SKILL.md'))
        .existsSync(),
    isTrue,
  );
});

test('iq target get validate() rechaza target desconocido', () {
  final cmd = TargetGetCommand(TargetGetInput(target: 'vscode'), deployer: allAdaptersDeployer);
  expect(cmd.validate(), isNotNull);
  expect(cmd.validate(), contains('vscode'));
});

// ─── Test de regresión D18 (idempotencia de skills) ─────────────────────

test('deployExclusive es idempotente: re-deploy reemplaza skills existentes', () {
  deployer.deployExclusive('copilot');
  deployer.deployExclusive('copilot'); // segunda vez
  // No error, skills existen y tienen contenido actualizado
  expect(
    File(p.join(homeDir.path, '.copilot', 'skills', 'doc-read', 'SKILL.md'))
        .existsSync(),
    isTrue,
  );
});
```

### Implementación E2

1. **`TargetDeployer`**:
   - Eliminar `_deployAgents()` (dead code).
   - **Eliminar `deploy()` completamente** (único caller era `TargetGetCommand`, que pasa a `deployExclusive()`).
   - Añadir `deployExclusive(String targetName)`:
     ```dart
     void deployExclusive(String targetName) {
       final validNames = adapters.map((a) => a.name).toSet();
       if (!validNames.contains(targetName)) {
         throw ArgumentError(
           'Unknown target: $targetName. Valid: ${validNames.join(", ")}'
         );
       }
       clean(); // limpia todos los adapters (skills + agents old paths)
       final selected = adapters.firstWhere((a) => a.name == targetName);
       _deploySkills(selected);
     }
     ```
     > **Nota A1:** Valida contra `adapters.map((a) => a.name)` — no una lista hardcoded.
     > Si `TargetDeployer` se construye con `allAdapters`, los 5 nombres son válidos.
     > Si se construye con `deployAdapters` (solo copilot), solo `'copilot'` es válido.
     > Esto elimina la fuente de verdad duplicada.

2. **`TargetGetInput`**:
   ```dart
   class TargetGetInput extends Input {
     final String target;
     TargetGetInput({this.target = 'copilot'});
     factory TargetGetInput.fromCliRequest(CliRequest req) =>
         TargetGetInput(target: req.option('target') ?? 'copilot');
     @override
     Map<String, dynamic> toJson() => {'target': target};
   }
   ```

3. **`TargetGetCommand`**:
   - `validate()`: verificar que `input.target` es uno de los 5 adapters válidos.
   - `execute()`: llamar `deployer.deployExclusive(input.target)` en lugar de `deployer.deploy()`.
   - Mensaje de output: `'Inquiry skills deployed to ${input.target}'`.

4. **`target_builder.dart`**:
   - Pasar `cleaner` (allAdapters) a `TargetGetCommand` en lugar de `deployer`.
   - Actualizar `description`: `'Deploy Inquiry skills to the specified target (default: copilot)'`.
   - Registrar la opción `--target` en el builder.

5. **Renombrar adapter `crush` → `opencode`**:
   - Eliminar `code/cli/lib/targets/crush_adapter.dart`.
   - Crear `code/cli/lib/targets/opencode_adapter.dart`:
     ```dart
     import 'package:path/path.dart' as p;
     import 'target_adapter.dart';

     class OpenCodeAdapter extends TargetAdapter {
       @override
       String get name => 'opencode';

       @override
       String baseDirectory(String homeDir) =>
           p.join(homeDir, '.config', 'opencode');

       @override
       String skillsDirectory(String homeDir) =>
           p.join(homeDir, '.config', 'opencode', 'skills');

       @override
       String agentDirectory(String homeDir) =>
           p.join(homeDir, '.config', 'opencode', 'agents');
     }
     ```
   - Actualizar `all_adapters.dart`: reemplazar `CrushAdapter()` con `OpenCodeAdapter()`.
   - Actualizar imports en todos los archivos que importan `crush_adapter.dart`.

### Verificar E2

```
dart test test/deployer_test.dart test/target_commands_test.dart
```

### Commit E2

```
feat(target): exclusive skills deploy with --target flag (E2)

- iq target get --target=[copilot|claude|codex|opencode|gemini]
- deployExclusive(): cleans all adapters, deploys skills to one target only
- Validates target against adapters list (not hardcoded) — single source of truth
- No agent deploy from target get — agent is repo-scoped via iq init
- clean() unchanged: still removes agentDirectory (upgrade compatibility)
- deploy() and _deployAgents() removed (dead code)
- validate() rejects unknown targets with actionable message

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

## E3 — `iq doctor` verifica nuevo contrato de readiness

### Hipótesis E3

`DoctorCommand` puede reemplazar su verificación de agente de
`~/.copilot/agents/inquiry.agent.md` por `.github/agents/inquiry.agent.md`,
usando `workingDirectory` como raíz, sin romper las verificaciones de skills.

### Evidencia de referencia

- `doctor.dart:219` — `_activeAdapters` default `[CopilotAdapter()]`.
- `doctor_test.dart:85` — `allPassFs` fija `p.join(home, '.copilot', 'agents', 'inquiry.agent.md')` → **CAMBIARÁ**.
- `doctor.dart:54-78` — `TargetCheck` tiene `agentExists` field.
- `doctor.dart:344` — `adapter.agentDirectory(homeDir)` para verificación de agente → **CAMBIARÁ**.
- `doctor.dart:157` — `"Run 'inquiry target get' to deploy"` → **CAMBIARÁ** a `'inquiry init'`.
- F5 (confirmed.md) — doctor verifica path global del agente.

### ⚠️ Mitigación R3: Los 5 tests de doctor afectados

El plan anterior solo mencionaba actualizar `allPassFs`. Los tests concretos que rompen:

| Línea | Test | Por qué rompe |
|-------|------|---------------|
| 82–93 | `allPassFs` helper | Fija agente en `~/.copilot/agents/` (path antiguo) |
| 169 | `all checks pass → exit 0` | Usa `allPassFs` → `agentExists: false` con nuevo path |
| 307 | Scenario A: all targets deployed | `agentExists: isTrue` falla con path antiguo |
| 324–343 | Scenario B: nothing deployed | String `"Run 'inquiry target get'"` hardcodeado → falla |
| ~345 | Scenario C: no `.inquiry/` directory | String `"Run 'inquiry target get' to deploy"` hardcodeado → falla |
| 368–399 | Scenario D: partial deployment | `agentExists` usa path antiguo |

**Todos estos 6 tests deben actualizarse en E3, no solo el helper.**

### ⚠️ Mitigación R4: Refactorizar `_verifyTarget()`

Tras E3, `_verifyTarget(adapter)` verifica skills vía adapter (correcto) pero el agente
vía `workingDirectory` (ignora el adapter). Separar las responsabilidades:

```dart
// En DoctorCommand:
bool _verifyRepoAgent() =>
    _fileSystem.fileExists(p.join(_workingDirectory, '.github', 'agents', 'inquiry.agent.md'));

TargetCheck _verifyTarget(TargetAdapter adapter) {
  final agentExists = _verifyRepoAgent(); // repo-scoped, independiente del adapter
  final skillsExist = _verifySkills(adapter); // adapter-scoped
  return TargetCheck(targetName: adapter.name, agentExists: agentExists, skillsDeployed: skillsExist);
}
```

### Tests (escribir primero — deben FALLAR)

```dart
// test/doctor_test.dart

// ─── Nuevo helper (reemplaza allPassFs) ──────────────────────────────────

MockFileSystemOps repoScopedAllPass(String workingDir, String homeDir, List<String> skills) {
  final fs = MockFileSystemOps();
  fs.setDirectoryExists('.inquiry', true);
  // NUEVO: agente en path repo-scoped
  fs.setFileExists(
    p.join(workingDir, '.github', 'agents', 'inquiry.agent.md'),
    true,
  );
  // Skills en path global de usuario (sin cambio)
  for (final skill in skills) {
    fs.setFileExists(
      p.join(homeDir, '.copilot', 'skills', skill, 'SKILL.md'),
      true,
    );
  }
  return fs;
}

// ─── Tests nuevos ────────────────────────────────────────────────────────

test('doctor pasa cuando inquiry.agent.md está en .github/agents/', () async {
  final fs = repoScopedAllPass(workingDir, homeDir, testSkills);
  final command = makeDoctorCmd(fs, workingDirectory: workingDir);

  final output = await command.execute();

  expect(output.checks.first.agentExists, isTrue);
  expect(output.passed, isTrue);
});

test('doctor falla cuando inquiry.agent.md NO está en .github/agents/', () async {
  final fs = MockFileSystemOps()..setDirectoryExists('.inquiry', true);
  // No ponemos el agente en ningún path
  final command = makeDoctorCmd(fs, workingDirectory: workingDir);

  final output = await command.execute();

  expect(output.checks.first.agentExists, isFalse);
  expect(output.passed, isFalse);
});

test('doctor ignora agente en path antiguo ~/.copilot/agents/', () async {
  final fs = MockFileSystemOps()..setDirectoryExists('.inquiry', true);
  // Agente en path antiguo (antes de 0.5.0)
  fs.setFileExists(
    p.join(homeDir, '.copilot', 'agents', 'inquiry.agent.md'),
    true,
  );
  // NO en el nuevo path
  final command = makeDoctorCmd(fs, workingDirectory: workingDir);

  final output = await command.execute();

  expect(output.checks.first.agentExists, isFalse,
      reason: 'El path antiguo ya no es válido — debe correr iq init');
});

test('doctor remediation sugiere "inquiry init" cuando agente falta', () async {
  final fs = MockFileSystemOps()..setDirectoryExists('.inquiry', true);
  final command = makeDoctorCmd(fs, workingDirectory: workingDir);

  final output = await command.execute();
  final text = output.toText() ?? '';

  expect(text, contains("'inquiry init'"),
      reason: 'Remediation debe sugerir iq init, no iq target get');
  expect(text, isNot(contains("'inquiry target get'")));
});

// ─── Actualizar los 5 tests existentes afectados ─────────────────────────

// Scenario A (~line 307): cambiar agentPath en MockFileSystemOps al nuevo repo-scoped path
// Scenario B (~line 324): actualizar string assertion de remediation
// Scenario D (~line 368): cambiar agentPath en MockFileSystemOps al nuevo repo-scoped path
// allPassFs (~line 82): reemplazar con repoScopedAllPass o eliminar
// all checks pass (~line 169): usar repoScopedAllPass

// ─── Regression: agentExists es independiente del adapter ────────────────

test('agentExists no cambia según el adapter — es repo-scoped', () async {
  // Solo un agente en el repo, skills en copilot
  final fs = repoScopedAllPass(workingDir, homeDir, testSkills);
  final command = makeDoctorCmd(fs, workingDirectory: workingDir);

  final output = await command.execute();

  // Todos los target checks deben tener el mismo agentExists
  final allAgentExists = output.checks.map((c) => c.agentExists).toSet();
  expect(allAgentExists, equals({true}),
      reason: 'agentExists es repo-scoped — el mismo para todos los adapters');
});
```

### Implementación E3

1. **`DoctorCommand`**: añadir `String workingDirectory` al constructor (default `Directory.current.path`).
2. **`_verifyRepoAgent()`**: nuevo método privado que verifica `workingDirectory/.github/agents/inquiry.agent.md`.
3. **`_verifyTarget()`**: llamar `_verifyRepoAgent()` en lugar de `adapter.agentDirectory(homeDir)`.
4. **Remediation**: cambiar `"Run 'inquiry target get'"` a `"Run 'inquiry init'"`.
5. **`doctor_test.dart`**: actualizar `allPassFs` helper + los 5 tests concretos listados arriba.
6. **`makeCmd()` helper en test**: añadir parámetro `workingDirectory`.

### Verificar E3

```
dart test test/doctor_test.dart
```

### Commit E3

```
feat(doctor): verify agent at .github/agents/ (repo-scoped contract) (E3)

- DoctorCommand.workingDirectory: verifica <repo>/.github/agents/
- _verifyRepoAgent(): separado de _verifyTarget(adapter) (R4 mitigation)
- agentExists: path antiguo ~/.copilot/agents/ ya no es válido
- Remediation: "Run 'inquiry init'" (no "inquiry target get")
- Tests: allPassFs → repoScopedAllPass; 5 tests de Scenarios actualizados

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

## E4 — Extension: elimina `iq target get` del init flow

### Hipótesis E4

El flujo de la extensión VS Code puede reemplazar la secuencia
`iq init && iq target get` por solo `iq init`, dado que E1 hace que
`iq init` despliegue el agente directamente.

### Evidencia de referencia

- `code/vscode/src/init.ts:42-46` — secuencia actual: `iq init` → `iq target get` → reload.
- F6 (confirmed.md) — extensión encadena ambos comandos automáticamente.
- R2 (diagnosis.md) — si init.ts no se actualiza, target get re-deploya globalmente.

### ⚠️ Mitigación R6: No existe test runner TypeScript

Antes de escribir tests, verificar:
```bash
cd code/vscode && cat package.json | grep -A10 '"scripts"'
```
Si no hay runner de tests configurado, configurarlo primero (jest o vitest).
Si existe, ejecutarlo para verificar baseline antes de añadir tests nuevos.

### Tests (escribir primero — deben FALLAR)

```typescript
// code/vscode/src/init.test.ts — crear desde cero

describe('inquiryInit', () => {
  const sentCommands: string[] = [];
  const fakeTerminal = {
    sendText: (cmd: string) => sentCommands.push(cmd),
    show: () => {},
  };
  const fakeDeps = {
    isInquiryInstalled: () => true,
    getInquiryBinaryPath: () => '/usr/local/bin/iq',
    showErrorMessage: async () => undefined,
    showInformationMessage: async () => 'Reload',
    createTerminal: () => fakeTerminal,
    executeCommand: async () => {},
  };

  beforeEach(() => sentCommands.length = 0);

  it('envía exactamente un sendText con "init" — NO "target get"', async () => {
    await inquiryInit('/workspace/project', fakeDeps);

    // shellExec(binaryPath(), ['init']) → '"/usr/local/bin/iq" init' (unix)
    // o '& "/usr/local/bin/iq" init' (windows)
    const initCalls = sentCommands.filter(c => /\binit\b/.test(c) && !/target/.test(c));
    const targetGetCalls = sentCommands.filter(c => /target\s+get/.test(c));

    expect(initCalls.length).toBe(1);
    expect(targetGetCalls.length).toBe(0);
  });

  it('solicita reload de ventana después de iq init', async () => {
    let reloadCalled = false;
    const deps = {
      ...fakeDeps,
      showInformationMessage: async () => 'Reload',
      executeCommand: async (cmd: string) => {
        if (cmd === 'workbench.action.reloadWindow') reloadCalled = true;
      },
    };

    await inquiryInit('/workspace/project', deps);

    expect(reloadCalled).toBe(true);
  });
});
```

### Implementación E4

1. **`code/vscode/src/init.ts`**: eliminar la línea `terminal.sendText('iq target get')` (o equivalente).
2. Verificar que el mensaje de onboarding refleje el nuevo flujo.
3. Revisar `install.sh` / `install.ps1`: si lanzan `iq target get` post-install, eliminar.

### Verificar E4

```bash
dart test
cd code/vscode && npm test
```

### Commit E4

```
fix(vscode): remove target get from init flow (E4)

- inquiryInit() ahora solo ejecuta 'iq init'
- El agente se despliega dentro de iq init (E1)
- Elimina la contaminación global que ocurría al encadenar target get

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

## E5 — Limpieza explícita del agente repo-scoped en uninstall y target clean

### Hipótesis E5

`iq uninstall` y `iq target clean` deben eliminar `.github/agents/inquiry.agent.md`
del repositorio actual, ya que `deployer.clean()` solo conoce los paths de los adapters
(`~/.copilot/`, `~/.claude/`, etc.) y el archivo repo-scoped está fuera de esa estructura.

### Evidencia de referencia

- `uninstall.dart:67` — `deployer.clean()` → limpia adapter paths, no `.github/agents/`.
- `clean.dart` — `TargetCleanCommand` → mismo problema.
- R2 y R5 (`analyze/risk-analysis.md`) — ghost file en `.github/agents/` tras uninstall/clean.

### Tests (escribir primero — deben FALLAR)

```dart
// test/uninstall_command_test.dart

test('iq uninstall elimina .github/agents/inquiry.agent.md del repo actual', () async {
  // Crear el archivo repo-scoped
  final agentFile = File(
    p.join(tempDir.path, '.github', 'agents', 'inquiry.agent.md'),
  );
  agentFile.parent.createSync(recursive: true);
  agentFile.writeAsStringSync('# APE Agent');

  final command = UninstallCommand(
    UninstallInput(installDir: tempDir.path),
    deployer: mockDeployer,
    workingDirectory: tempDir.path,  // nuevo param
    platformOps: mockPlatformOps,
  );

  await command.execute();

  expect(agentFile.existsSync(), isFalse,
      reason: 'iq uninstall debe limpiar el agente repo-scoped');
});

test('iq uninstall no falla si .github/agents/inquiry.agent.md no existe', () async {
  // No crear el archivo — verify no exception
  final command = UninstallCommand(
    UninstallInput(installDir: tempDir.path),
    deployer: mockDeployer,
    workingDirectory: tempDir.path,
    platformOps: mockPlatformOps,
  );

  await expectLater(command.execute(), completes);
});

// test/target_commands_test.dart

test('iq target clean elimina .github/agents/inquiry.agent.md', () async {
  final agentFile = File(
    p.join(tempDir.path, '.github', 'agents', 'inquiry.agent.md'),
  );
  agentFile.parent.createSync(recursive: true);
  agentFile.writeAsStringSync('# APE Agent');

  final command = TargetCleanCommand(
    TargetCleanInput(),
    deployer: mockDeployer,
    workingDirectory: tempDir.path,  // nuevo param
  );

  await command.execute();

  expect(agentFile.existsSync(), isFalse);
});
```

### Implementación E5

1. **`UninstallCommand`**: añadir `String workingDirectory` (default `Directory.current.path`).
   ```dart
   @override
   Future<UninstallOutput> execute() async {
     deployer.clean();  // limpia skills + old agent paths (~/.copilot/agents/, etc.)
     _cleanRepoScopedAgent();  // limpia .github/agents/inquiry.agent.md
     _removeFromPath(p.join(input.installDir, 'bin'));
     await platformOps.scheduleDeletion(input.installDir);
     return UninstallOutput(message: 'Inquiry uninstalled. Restart terminal to apply PATH changes.');
   }

   void _cleanRepoScopedAgent() {
     final agentFile = File(
       p.join(_workingDirectory, '.github', 'agents', 'inquiry.agent.md'),
     );
     if (agentFile.existsSync()) agentFile.deleteSync();
   }
   ```

2. **`TargetCleanCommand`**: mismo patrón — añadir `workingDirectory` + `_cleanRepoScopedAgent()`.

### Verificar E5

```
dart test test/uninstall_command_test.dart test/target_commands_test.dart
dart test
```

### Commit E5

```
fix(uninstall,clean): explicit cleanup of repo-scoped agent (E5)

- UninstallCommand: removes .github/agents/inquiry.agent.md from workingDir
- TargetCleanCommand: same explicit cleanup
- No-op if file doesn't exist (safe for first installs)
- Resolves ghost file on iq uninstall (R2) and iq target clean (R5)

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

## E6 — Bump de versión y changelog

### Checklist E6

- [ ] Actualizar `pubspec.yaml` → `version: 0.5.0`
- [ ] Añadir entrada en `CHANGELOG.md`:
  ```markdown
  ## 0.5.0 — Repo-scoped deploy + target exclusivo

  ### Breaking changes
  - `iq init` ahora despliega `inquiry.agent.md` en `.github/agents/` (repo-scoped).
  - `iq target get` ya no despliega el agente — solo skills al target especificado.
  - `iq doctor` verifica `.github/agents/inquiry.agent.md`.

  ### Nuevas funcionalidades
  - `iq target get --target=[copilot|claude|codex|opencode|gemini]`
  - Solo un target activo a la vez — cambia de target limpia los demás automáticamente.

  ### Upgrade path
  1. `iq uninstall`
  2. Instalar 0.5.0
  3. `iq init` (en cada repo que use Inquiry)
  ```
- [ ] Actualizar `version_sync_test.dart` si valida versiones cruzadas.

### Verificar E6

```
dart test test/version_sync_test.dart
dart test
```

### Commit E6

```
chore(release): bump to 0.5.0 — repo-scoped deploy + target exclusivo

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

## Suite de Regresión Final

```bash
dart test
```

Contrato observable tras 0.5.0:

| Comando | Antes | Después |
|---------|-------|---------|
| `iq init` | Crea `.inquiry/` | Crea `.inquiry/` + `.github/agents/inquiry.agent.md` |
| `iq target get` | Despliega agent + skills → `~/.copilot/` | Despliega solo skills → `~/.copilot/skills/` (target=copilot) |
| `iq target get --target=claude` | N/A | Despliega skills → `~/.claude/skills/`; limpia los otros |
| `iq doctor` | Verifica `~/.copilot/agents/inquiry.agent.md` | Verifica `.github/agents/inquiry.agent.md` |
| `iq uninstall` | Limpia skills + global agents | Limpia skills + global agents + `.github/agents/inquiry.agent.md` |
| `iq target clean` | Limpia skills + global agents | Limpia skills + global agents + `.github/agents/inquiry.agent.md` |
| Extension init | `iq init` + `iq target get` | Solo `iq init` |

---

## Orden de Ejecución

E1 → E2 → E3 → E4 → E5 → E6

Cada etapa es atómica: si los tests fallan, NO continuar a la siguiente.
