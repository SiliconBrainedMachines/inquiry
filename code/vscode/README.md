# APE — VS Code Extension

APE (Autonomous Programming Engine) is a finite-state methodology for AI-assisted development.

This extension brings APE's FSM lifecycle into your editor:

- **Status Bar** — Live display of the current APE state (IDLE → ANALYZE → PLAN → EXECUTE → EVOLUTION)
- **Toggle Evolution** — Enable/disable the Evolution phase via `.ape/config.yaml`
- **Add Mutation Note** — Append observations to `.ape/mutations.md` during EVOLUTION
- **Auto-activation** — Extension activates automatically when a `.ape/` directory exists in the workspace

## Requirements

- VS Code ≥ 1.85
- A workspace with a `.ape/` directory (created by the APE CLI)

## Links

- [APE CLI Repository](https://github.com/ccisne-dev/finite_ape_machine)
