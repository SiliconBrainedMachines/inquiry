# Changelog
All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/)
and the project adheres to [Semantic Versioning](https://semver.org/).

## [0.0.5]
### Added
- `ape uninstall` command (#16).

## [0.0.4]
### Fixed
- `ape upgrade` renames the running executable before extracting the new one (#14).

## [0.0.3]
### Added
- `ape upgrade` command and automatic release on merge (#3).
### Fixed
- `copilot` target is skipped when `claude` coexists (#12).

## [0.0.2]
### Added
- Initial Dart project scaffold and `ape init` command.
- `assets` module with `ape` agent and memory skills.
- Adapter pattern with 5 targets (claude, codex, copilot, crush, gemini).
- Deployer and `ape target get` / `ape target clean` commands.
- `ape version` command.
