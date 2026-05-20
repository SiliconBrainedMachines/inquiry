---
id: risk-analysis
title: "Análisis de riesgos de regresión — plan.md (issue #201)"
date: 2026-05-20
status: active
tags: [risks, regression, plan, tdd, 0.5.0]
author: inquiry
---

# Análisis de Riesgos: Plan Repo-Scoped Deploy

Riesgos encontrados mediante lectura directa de código fuente y tests existentes.
Cada riesgo tiene: severidad, archivo exacto afectado, y corrección recomendada.

---

## R1 — Assets threading: `InitInput` no puede construirse con `Assets` desde el CLI real

**Severidad:** 🔴 BLOQUEANTE  
**Etapa:** E1  
**Archivos:** `global_builder.dart:23-26`, `init.dart:28-33`

### Problema

El plan propone que `InitInput` reciba `Assets assets` (requerido). Pero en producción,
`InitCommand` se construye en `global_builder.dart` así:

```dart
// global_builder.dart:23-26
m.command<InitInput, InitOutput>(
  'init',
  (req) => InitCommand(InitInput.fromCliRequest(req)),  // sin assets
  ...
);
```

`InitInput.fromCliRequest` no tiene acceso a `assetsRoot` (que viene de
`Platform.resolvedExecutable` en `inquiry_cli.dart:25`). El compilador rechazaría
`Assets` como campo requerido en `InitInput`.

Además, todos los tests existentes en `init_command_test.dart` construyen:
```dart
InitInput(workingDirectory: tempDir.path)  // sin assets
```
Si `Assets` es requerido, **todos los tests existentes de init rompen**.

### Corrección

- `Assets` debe ser **opcional** en `InitInput` (`Assets? assets`).
- El paso 7 se omite silenciosamente si `assets == null` (el plan original lo tenía correcto, se eliminó por error).
- En `global_builder.dart`, pasar assets al comando:
  ```dart
  (req) => InitCommand(InitInput.fromCliRequest(req), assets: assets)
  ```
  … donde `assets` llega como parámetro a `buildGlobalModule` (ya existe: `Assets? assets`).
- Alternativamente: mover `Assets` como parámetro directo de `InitCommand` (no en `InitInput`),
  lo que es más limpio para inyección de dependencias.

---

## R2 — Ghost file: `iq uninstall` no limpia `.github/agents/inquiry.agent.md`

**Severidad:** 🔴 BLOQUEANTE (para el upgrade path)  
**Etapa:** E2 + flujo de upgrade  
**Archivos:** `uninstall.dart:66-67`, `inquiry_cli.dart:36-43`

### Problema

`UninstallCommand` llama `deployer.clean()` donde `deployer` es el `cleaner`
(`allAdapters`). Tras E2, `clean()` ya no toca `agentDirectory`, por lo que
`iq uninstall` **deja `.github/agents/inquiry.agent.md` en disco**.

El upgrade path documentado en E5 del plan es: `iq uninstall` → instalar 0.5.0.
Si `uninstall` deja el archivo del agente en `.github/agents/`, el usuario parte
de un estado sucio hacia 0.5.0 (aunque no roto, sí confuso).

Adicionalmente: el archivo **antiguo** `~/.copilot/agents/inquiry.agent.md`
tampoco se limpia (E2 lo elimina de `clean()`). Si el usuario venía de 0.4.x,
ese ghost file queda en el directorio global indefinidamente.

### Corrección

`UninstallCommand` necesita limpieza específica del nuevo path además del deployer:

```dart
// En execute():
deployer.clean();  // limpia skills de ~/.copilot/skills/

// Limpieza explícita del agente repo-scoped
final repoAgent = File(p.join(Directory.current.path, '.github', 'agents', 'inquiry.agent.md'));
if (repoAgent.existsSync()) repoAgent.deleteSync();
```

O bien: `TargetDeployer` conserva `_deployAgents()` solo para `clean()` (sigue
conociendo el agentDirectory) pero `deploy()` ya no lo llama.

---

## R3 — Regresión silenciosa: `allPassFs` y 5 tests de doctor fallan tras E3

**Severidad:** 🟠 ALTA  
**Etapa:** E3 (doctor)  
**Archivos:** `doctor_test.dart:82-93, 169-177, 307-321, 324-343, 368-399`

### Problema

El helper `allPassFs` (doctor_test.dart:82-93) fija el agente en:
```dart
p.join(home, '.copilot', 'agents', 'inquiry.agent.md')  // path antiguo
```

Los tests que usan `makeCmd()` sin pasar `fs` explícito pasan por `allPassFs` y
verifican que el agente existe. Tras E3, `_verifyTarget()` buscará el agente
en `workingDirectory/.github/agents/inquiry.agent.md`. El `MockFileSystemOps`
del helper no tiene ese path → **`agentExists` será `false`** → los tests rompen:

| Test | Falla porque |
|------|-------------|
| `all checks pass → exit 0` (line 169) | `allPassFs` no pone agente en nuevo path |
| `toJson()` verifica estructura (line 251) | `targetChecks.first.agentExists` falso |
| `Scenario A: all targets deployed` (line 307) | `agentExists: isTrue` falla |
| `Scenario B: nothing deployed` (line 324) | mensaje `"Run 'inquiry target get'"` cambia → text assertion falla |
| `Scenario D: partial deployment` (line 368) | agente fijo en path antiguo |

El plan menciona "actualizar `allPassFs` helper" pero **no enumera los 5 tests
concretos** que usan ese helper. Sin actualizarlos todos, la suite parece verde
en algunos y roja en otros de forma no obvia.

### Corrección

1. Actualizar `allPassFs` para aceptar `workingDir` y poner el agente en el nuevo path.
2. Actualizar `makeCmd()` para pasar `workingDirectory`.
3. Revisar cada test que verifica strings como `"Run 'inquiry target get' to deploy"` (Scenario B/C/D) → cambian a `"Run 'inquiry init'"`.

---

## R4 — `_verifyTarget()` queda inconsistente: adapter ignorado para el agente

**Severidad:** 🟡 MEDIA  
**Etapa:** E3 (doctor)  
**Archivos:** `doctor.dart:344-371`

### Problema

Tras E3, `_verifyTarget(adapter)` hace dos cosas distintas:
- Skills: usa `adapter.skillsDirectory(homeDir)` → correcto
- Agente: usa `workingDirectory/.github/agents/` → ignora al adapter

El método recibe un `TargetAdapter` pero lo usa solo para la mitad de la verificación.
Esto crea deuda conceptual: el `TargetCheck` tiene `targetName: adapter.name`
pero el agente no se verificó contra ese adapter.

Si en el futuro se añade un segundo adapter de deploy, el doctor verificaría
el agente solo en `.github/agents/` (repo-scoped) lo cual es correcto, pero
la firma del método insinúa lo contrario.

### Corrección

Separar la verificación:
```dart
// Un check para el agente repo-scoped (no depende del adapter)
bool _verifyRepoAgent(String workingDir) =>
    _fileSystem.fileExists(p.join(workingDir, '.github', 'agents', 'inquiry.agent.md'));

// Verifica skills por adapter (sin cambios)
List<String> _verifySkills(TargetAdapter adapter) { ... }
```

O simplemente documentar el método con un comentario que explique el split,
si la separación completa se deja para una refactorización posterior.

---

## R5 — `iq target clean` deja de limpiar el agente silenciosamente

**Severidad:** 🟡 MEDIA  
**Etapa:** E2  
**Archivos:** `clean.dart:48-50`, `target_builder.dart:21-28`

### Problema

`TargetCleanCommand` llama `deployer.clean()` usando el `cleaner` (allAdapters).
Tras E2, `clean()` ya no toca `agentDirectory`. El usuario que ejecute
`iq target clean` esperará limpiar todo lo que Inquiry desplegó, pero el agente
en `.github/agents/inquiry.agent.md` no se eliminará.

El comportamiento implícito del comando cambia sin que el usuario lo sepa.

### Corrección

`TargetCleanCommand` debe limpiar explícitamente el agente repo-scoped además
de los skills:
```dart
Future<TargetCleanOutput> execute() async {
  deployer.clean();  // skills de ~/.copilot/
  final agentFile = File(p.join(Directory.current.path, '.github', 'agents', 'inquiry.agent.md'));
  if (agentFile.existsSync()) agentFile.deleteSync();
  return TargetCleanOutput(message: 'Inquiry cleaned from all targets');
}
```

---

## R6 — No existen tests de `init.ts` — TDD en E4 parte de cero

**Severidad:** 🟡 MEDIA  
**Etapa:** E4 (extension)  
**Archivos:** `code/vscode/src/` — ningún `*.test.ts` existe

### Problema

El plan dice "escribir tests primero — deben FALLAR". Pero no hay ningún archivo
de test TypeScript para la extensión. Los tests propuestos en el plan son nuevos,
no tests existentes que fallen. Esto cambia el ciclo TDD:

- En Dart (E1–E3): hay tests existentes que **se modifican** para fallar primero.
- En TS (E4): los tests se **crean** desde cero y deben fallar inmediatamente.

No es un bloqueante pero sí requiere configurar el runner de tests de la extensión
si aún no existe. Verificar que `code/vscode/package.json` tiene script `test`.

### Corrección

Antes de E4, verificar:
```bash
cd code/vscode && cat package.json | grep -A5 '"scripts"'
```
Si no hay runner, configurar uno (jest o vitest) antes de escribir el test.

---

## R7 — Descripción desactualizada de `iq target get`

**Severidad:** 🟢 BAJA  
**Etapa:** E2  
**Archivos:** `target_builder.dart:14`

### Problema

```dart
description: 'Deploy Inquiry agents and skills to Copilot'
```

Tras E2, `target get` ya no despliega el agente. La descripción es falsa.

### Corrección

```dart
description: 'Deploy Inquiry skills to Copilot'
```

---

## Resumen de Riesgos por Etapa

| Etapa | Riesgo | Severidad |
|-------|--------|-----------|
| E1 | R1: Assets threading — compilación rota si Assets es requerido | 🔴 |
| E2 | R2: Ghost file tras iq uninstall (agente no se limpia) | 🔴 |
| E2 | R5: iq target clean deja agente repo-scoped sin limpiar | 🟡 |
| E2 | R7: Descripción de target get desactualizada | 🟢 |
| E3 | R3: 5 tests de doctor rompen silenciosamente (allPassFs) | 🟠 |
| E3 | R4: _verifyTarget() inconsistente (adapter ignorado para agente) | 🟡 |
| E4 | R6: No hay test runner TypeScript configurado | 🟡 |

---

## Correcciones Prioritarias Antes de Implementar

1. **R1** (antes de E1): Hacer `Assets` opcional en `InitInput`; pasar assets desde `global_builder.dart`.
2. **R2** (antes de E2): Definir quién limpia `.github/agents/` en uninstall y target clean.
3. **R3** (antes de E3): Enumerar todos los tests de doctor que usan `allPassFs` y actualizarlos en el plan.
4. **R5** (junto con E2): Añadir limpieza del agente repo-scoped a `TargetCleanCommand`.
