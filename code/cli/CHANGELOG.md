# Changelog
All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/)
and the project adheres to [Semantic Versioning](https://semver.org/).

## [0.0.5]
### Added
- `ape uninstall` command (#16).

## [0.0.4]
### Fixed
- `ape upgrade` renombra el ejecutable en uso antes de extraer el nuevo (#14).

## [0.0.3]
### Added
- `ape upgrade` y release automático en merge (#3).
### Fixed
- Target `copilot` se omite cuando `claude` coexiste (#12).

## [0.0.2]
### Added
- Scaffold inicial del proyecto Dart y comando `ape init`.
- Módulo `assets` con agente `ape` y skills de memoria.
- Adapter pattern con 5 targets (claude, codex, copilot, crush, gemini).
- Deployer y comandos `ape target get` / `ape target clean`.
- Comando `ape version`.
