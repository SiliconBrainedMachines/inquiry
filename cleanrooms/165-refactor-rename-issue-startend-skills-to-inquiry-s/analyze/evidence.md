# Evidence

## Semantic Distinction Confirmed In Live Code

- `issue-create` is defined as deterministic GitHub issue selection/creation in IDLE/TRIAGE, before explicit start intent, and must not trigger `start_analyze` on its own.
  - Sources: `code/cli/assets/instructions/issue-create.md`, `code/cli/assets/fsm/states/idle.yaml`

- `issue-start` is a separate operational handoff for an already-confirmed issue. It prepares the issue-linked branch and cleanroom and then transitions into ANALYZE.
  - Sources: `code/cli/assets/instructions/issue-start.md`, `code/cli/assets/fsm/states/idle.yaml`

- `issue-end` is a cycle-completion protocol tied to EXECUTE/END behavior rather than GitHub issue triage.
  - Sources: `code/cli/assets/instructions/issue-end.md`, `code/cli/assets/fsm/transition_contract.yaml`

- The active firmware keeps the same separation: create/select work remains inside IDLE/TRIAGE, while only explicit start intent triggers `issue-start` plus `start_analyze`.
  - Source: `code/cli/assets/agents/inquiry.agent.md`

- Active tests encode the same distinction and explicitly prevent blending `issue-create` into the `issue-start` / `issue-end` runtime protocols.
  - Sources: `code/cli/test/assets_test.dart`, `code/cli/test/fsm_contract_test.dart`

## Result

- Evidence supports keeping `issue-create` unchanged in issue #165.
- No contradictory evidence was found in live repository code during this check.