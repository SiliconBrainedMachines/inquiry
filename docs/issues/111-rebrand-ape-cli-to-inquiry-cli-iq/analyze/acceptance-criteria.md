---
id: acceptance-criteria
title: "Detailed Acceptance Criteria for #111"
date: 2026-04-21
status: active
tags: [rebrand, acceptance-criteria, plan]
author: SOCRATES
---

# Detailed Acceptance Criteria for #111

Granular, testable acceptance criteria derived from the impact surface analysis.

---

## AC-1: CLI Binary Rename

- [ ] `dart compile exe` produces `inquiry.exe` (Windows) / `inquiry` (Linux)
- [ ] `build.ps1` outputs `build/bin/inquiry.exe`
- [ ] `build.sh` outputs `build/bin/inquiry`
- [ ] `pubspec.yaml` name is `inquiry_cli`
- [ ] `lib/ape_cli.dart` renamed to `lib/inquiry_cli.dart`
- [ ] `runApe()` renamed to `runInquiry()`
- [ ] All internal `package:ape_cli` imports updated to `package:inquiry_cli`
- [ ] `bin/main.dart` comment updated

## AC-2: Alias/Symlink

- [ ] Install scripts create both `inquiry` and `iq` executables
- [ ] Windows: `inquiry.exe` + `iq.exe` (copy) in bin directory
- [ ] Linux/macOS: `inquiry` + `iq` (symlink → inquiry) in bin directory
- [ ] Both `inquiry --version` and `iq --version` work after install

## AC-3: Config Directory

- [ ] `iq init` creates `.inquiry/` (not `.ape/`)
- [ ] `.inquiry/state.yaml`, `.inquiry/config.yaml`, `.inquiry/mutations.md` created
- [ ] `.gitignore` entry is `.inquiry/` (not `.ape/`)
- [ ] All Dart code references `.inquiry/` path
- [ ] All tests assert `.inquiry/` paths
- [ ] `init_command_test.dart` updated for `.inquiry/`

## AC-4: Install Scripts

- [ ] `code/cli/scripts/install.ps1`: installs to `$LOCALAPPDATA\inquiry\bin\`
- [ ] `code/site/install.ps1`: same as above
- [ ] `code/site/install.sh`: installs to `$HOME/.inquiry/bin/`
- [ ] Asset pattern: `inquiry-windows-x64.zip`, `inquiry-linux-x64.tar.gz`
- [ ] Both scripts create `iq` alias after installing `inquiry`
- [ ] Success messages reference "Inquiry CLI" (not "APE CLI")
- [ ] Commands shown post-install: `iq doctor`, `iq init`, `iq target get`

## AC-5: CI/CD Release Workflow

- [ ] `.github/workflows/release.yml` produces `inquiry-windows-x64.zip` containing `inquiry.exe`
- [ ] `.github/workflows/release.yml` produces `inquiry-linux-x64.tar.gz` containing `inquiry`
- [ ] Dart compile step outputs correct binary name
- [ ] Release asset upload uses new names
- [ ] Windows Defender workaround still functional (re-test)

## AC-6: VS Code Extension — New (inquiry-vscode)

- [ ] New extension ID: `ccisnedev.inquiry-vscode`
- [ ] Display name: `Inquiry`
- [ ] Commands prefixed `inquiry.*`: `inquiry.init`, `inquiry.toggleEvolution`, `inquiry.addMutation`
- [ ] Activation event: `workspaceContains:.inquiry/`
- [ ] `guard.ts` functions renamed: `getInquiryBinaryPath()`, `isInquiryInstalled()`, `isInquiryWorkspace()`
- [ ] `installer.ts` downloads `inquiry-*` assets
- [ ] Extension icon is the new "iq" mark (SVG + PNG)
- [ ] Sidebar icon is the new "iq" mark (monochrome SVG)
- [ ] README.md describes Inquiry, not APE
- [ ] Published to VS Code Marketplace as `ccisnedev.inquiry-vscode`

## AC-7: VS Code Extension — Deprecate Old (ape-vscode)

- [ ] Final version of `ape-vscode` published with:
  - Display name: `APE (Deprecated — use Inquiry)`
  - Description: "DEPRECATED: Replaced by Inquiry (ccisnedev.inquiry-vscode)"
  - `extensionDependencies`: `["ccisnedev.inquiry-vscode"]`
  - All commands and activation events removed (empty shell)
  - README replaced with deprecation notice + link to Inquiry
- [ ] Marketplace page shows deprecation banner
- [ ] CI workflow updated to publish `inquiry-vscode` (not `ape-vscode`)

## AC-8: Logo — iq Mark

- [ ] `code/vscode/assets/icon.svg` — new "iq" vector icon
- [ ] `code/vscode/assets/icon.png` — new "iq" rasterized 128×128
- [ ] `code/vscode/assets/sidebar.svg` — new "iq" monochrome sidebar icon
- [ ] `code/site/img/favicon.svg` — new "iq" favicon
- [ ] CLI TUI banner updated with "iq" / "Inquiry" branding

## AC-9: Website

- [ ] `index.html` title: updated to reflect Inquiry branding
- [ ] `index.html` meta tags (description, og:description, twitter:description) updated
- [ ] `index.html` install commands use new URLs/binary names
- [ ] `methodology.html` breadcrumbs and title updated
- [ ] `agents.html` breadcrumbs and title updated
- [ ] `evolution.html` breadcrumbs and title updated
- [ ] `ape-builds-ape.html` — evaluate: rename file? content is methodology, may keep "APE builds APE"
- [ ] Favicon reference points to new "iq" favicon
- [ ] Badge version updated

## AC-10: Documentation

- [ ] `README.md` title, install section, command table, `.inquiry/` references
- [ ] `docs/architecture.md` — `.inquiry/` references, command examples
- [ ] `docs/spec/ape-cli-spec.md` — rename to `inquiry-cli-spec.md`, update all `.ape/` → `.inquiry/`, all `ape` → `iq` commands
- [ ] `docs/spec/index.md` — reference updated filename
- [ ] `docs/roadmap.md` — tool name references
- [ ] `docs/lore.md` — tool name references (methodology stays)
- [ ] Agent file `ape.agent.md` → `inquiry.agent.md`, content updated
- [ ] Skill files: command references updated (`ape doctor` → `iq doctor`)

## AC-11: Tests

- [ ] All existing tests pass with new naming
- [ ] `init_command_test.dart` — `.inquiry/` paths
- [ ] `scaffold_test.dart` — if references `.ape/`
- [ ] `doctor_test.dart` — binary name checks
- [ ] `state_transition_test.dart` — no naming dependency expected
- [ ] `fsm_contract_test.dart` — no naming dependency expected
- [ ] `target_commands_test.dart` — agent file references
- [ ] `assets_test.dart` — asset file references
- [ ] VS Code tests: `guard.ts` tests, `installer.ts` tests
- [ ] `dart test` passes
- [ ] `npm test` (vscode) passes

## AC-12: Repository Rename

- [ ] Rename GitHub repo from `finite_ape_machine` to `inquiry-cli`
- [ ] Verify redirect: old URLs (`ccisnedev/finite_ape_machine`) redirect to new
- [ ] Update `git remote` in local clones: `git remote set-url origin <new-url>`
- [ ] Update all internal references to repo name (install scripts, CI, installer.ts)
- [ ] GitHub repo About/description updated to reflect Inquiry CLI
- [ ] GitHub Pages: verify site still works after rename (custom domain unaffected)

---

## Execution Order (suggested)

1. **Logo** (AC-8) — unblocks extension and site work
2. **CLI rename** (AC-1, AC-2, AC-3) — core change
3. **Tests** (AC-11) — validate core change
4. **Install scripts** (AC-4) — depend on binary names
5. **CI/CD** (AC-5) — depend on binary + asset names
6. **Repo rename** (AC-12) — before publishing new extension (URLs must be correct)
7. **New VS Code extension** (AC-6) — depend on CLI + logo + repo name
8. **Website** (AC-9) — depend on logo + install URLs + repo name
9. **Documentation** (AC-10) — depend on all above being settled
10. **Deprecate old extension** (AC-7) — last, after new is published
