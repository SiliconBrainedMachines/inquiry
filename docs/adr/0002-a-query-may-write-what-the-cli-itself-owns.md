# ADR 0002: A query may write what the CLI itself owns

**Status:** Accepted

**Date:** 2026-08-13

## Context

`modular_cli_sdk` 0.4.0 splits a CLI's routes in two, and the split is
structural rather than an annotation:

- a **`Query`** reads and answers. Its contract says, in as many words,
  *"Must change nothing"*
- a **`Command`** changes something, as an ordered list of steps that state what
  they would do before anything runs. The framework declares `--plan`,
  `--apply` and `--autoapprove` on every one of them, and refuses a bare
  invocation: neither flag is a default

The two share no method, so a route cannot be both.

Registering every route that writes a byte as a `Command` would put
`--plan` / `--apply` on `iq fsm transition`, `iq ape transition`, `iq ape
prompt` and `iq init`. Those are the operations a person runs continuously
while driving a cycle. Asking them to approve each one would make the
convention noise, and noise is what gets `--autoapprove` pasted into every
invocation until the approval means nothing.

The alternative — registering them as queries and saying nothing — leaves the
next reader with three queries that write, a contract that says they must not,
and no way to tell a deliberate decision from a mistake.

## Decision

**A route is a `Command` when it changes the user's work or their machine. A
route that only changes state the CLI itself owns is a `Query`.**

"State the CLI itself owns" is not a judgement call here. Inquiry declares it,
in code, in `lib/src/gitignore.dart`:

```dart
const inquiryGitignoreEntries = <String>[
  '.inquiry/',
  // The cleanroom is a per-cycle working area, not documentation: the durable
  // artifacts of a cycle are the published issue, the code and the tests. The
  // whole directory is local — previously only `.iq.state.yaml` was ignored,
  // which left diagnosis.md / plan.md accumulating in the repo.
  'cleanrooms/',
];
```

`iq init` writes those two entries into the target repository's `.gitignore`.
Everything under them is, by the CLI's own declaration, derived and local: it
is reproducible from the issue, the code and the tests, and it is never
committed.

So the test is mechanical rather than a matter of taste: **if the CLI git-ignores
it in the repositories it serves, writing it does not make a route a command.**

### The five commands

`iq upgrade`, `iq uninstall`, `iq host get`, `iq host clean`,
`iq implementation start`.

Each changes something outside that boundary: the installed binary, the PATH,
the agent and skills deployed into a host's global directory, or a git branch
in the user's repository. `iq implementation start` is the clearest case — it
creates and checks out a branch, and there is no way today to ask it what it
would do first.

### The queries that write, and why

| Route | Writes | Why it is still a query |
| --- | --- | --- |
| `iq fsm transition` | `.iq.state.yaml`, and cleanroom scaffolds through its effects | Both are under `cleanrooms/`, which the CLI git-ignores in every repository it serves |
| `iq ape transition` | `.iq.state.yaml` | Cycle-local runtime state, and the `.gitignore` says so: *"cycle-local runtime state is derived, never tracked"* |
| `iq ape prompt` | `cleanrooms/<cycle>/run_trace.yaml` | Same boundary. Whether assembling a prompt should record telemetry at all is a separate question, tracked apart from this decision |
| `iq init` | the workspace, and two entries in the repository's `.gitignore` | It is configuration, not the user's work. It is also the command that *establishes* the boundary the rest of this rule depends on |

**This repository is the exception that proves the boundary.** `cleanrooms/` is
versioned *here*, and only here, because Inquiry's own cycles are research
artifacts worth keeping. Its `.gitignore` says so out loud. In every other
repository the CLI serves, the directory it writes into is ignored — which is
what the rule turns on.

## Consequences

**Easier**

- Driving a cycle stays direct. `iq fsm transition --event ...` needs no flag,
  and the approval that `--apply` asks for keeps meaning something because it is
  only asked where something outside the CLI's own workspace changes
- The five commands gain a preview of an operation that had none.
  `iq implementation start --issue N --plan` will say which branch it would
  create and which cleanroom it would scaffold, before it does either
- The migration is small: nine routes become queries with a one-word change,
  and five become commands

**Harder**

- **Three queries write, and the SDK's contract says they must not.** That is a
  deliberate divergence, and this record is the only thing standing between it
  and someone "fixing" it. The `Query` doc comment is the framework's general
  rule; this is Inquiry's reading of it, and the boundary that makes the reading
  safe is the one the CLI itself declares
- A route that starts inside the boundary and grows outside it has to be
  reclassified, and that is a breaking change for whoever invokes it. The rule
  tells you when: the day it writes something the CLI does not git-ignore

**Deliberately left for later**

- **The FSM's effects are not steps.** `effect_executor.dart` already has the
  shape — named, discrete operations dispatched by name, with `executed.add(...)`
  keeping a list of what ran. What it lacks is the other half: saying what it
  would do before doing it. Converting them buys nothing while `fsm transition`
  is a query, because nothing would compare the claim against the report. The
  day transitions become commands, this is where to start
- **Whether `iq ape prompt` should record a trace at all.** It is a query either
  way under this rule; the open question is one of cohesion, and it is tracked
  separately
