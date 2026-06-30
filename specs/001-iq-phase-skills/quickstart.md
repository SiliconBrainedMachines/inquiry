# Quickstart: iq-* phase skills

## Use them (manual / weak-model mode)

You have a cycle going but the `inquiry` scheduler agent isn't driving reliably
(weak model). Drive a phase yourself with the matching skill:

1. `iq host get --host <opencode|claude>` once installs `iq-analyze`,
   `iq-plan`, `iq-execute` (with research/legion/kritik).
2. In the host, run `/iq-analyze`. It tells you to:
   - `iq fsm state --json` (confirm you're in ANALYZE),
   - investigate with the SOCRATES method,
   - write `cleanrooms/<branch>/analyze/diagnosis.md` to the shown shape,
   - `iq fsm transition --event complete_analysis` — fix what it reports, retry.
3. When the gate passes, continue with `/iq-plan`, then `/iq-execute`.
   Start/end of a cycle use plain `iq`/`gh`/`git` commands (no dedicated skill).

## Regenerate after a contract change (maintainer)

Edit `assets/fsm/states/<phase>.yaml`, `assets/apes/<operator>.yaml`, or
`assets/artifacts/<artifact>.template.md`, then re-deploy:
`iq host get --host <host>` — the `SkillBuilder` rebuilds the `iq-*` skills from
the updated contracts (no manual skill edits).

## Validate the hypothesis (SC-003)

Run the same task on the weak model twice: once driving the scheduler agent
unaided, once following `/iq-analyze`. Compare how often `complete_analysis`
passes. The skill should win.
