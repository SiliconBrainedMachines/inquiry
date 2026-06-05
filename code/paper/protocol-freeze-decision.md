# Protocol Freeze Decision

> **Type:** method
> **Status:** stable
> **Depends on:** [experimental-protocol.md](experimental-protocol.md), [limitations-and-threats-to-validity.md](limitations-and-threats-to-validity.md), [evidence/pilot-claim-summary-t1-t2-t3.md](evidence/pilot-claim-summary-t1-t2-t3.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), future method section, future evidence collection

This document records the explicit post-pilot decision about whether the first-paper
protocol should be frozen or revised again before broader evidence collection.

## Decision

Freeze the current revised protocol and use it as the controlling method for the next
evidence-collection phase.

This is a real freeze, not a vague provisional endorsement. Further changes should not
be folded silently into the study method. If later work reveals a new design-level
problem, the method should be reopened explicitly as a new revision rather than drifting
by accretion.

## Why freeze rather than revise again

The pilot now supports a freeze decision for methodological reasons.

### The T1 problems were repaired at the protocol level

T1 showed that the initial protocol was not yet strong enough on three fronts:

- shared scored stop-line definition,
- durable export symmetry across conditions,
- and explicit separation of post-target extension from the primary paired comparison.

Those repairs are now present in [experimental-protocol.md](experimental-protocol.md)
and were actually exercised in T2 and T3 rather than merely stated on paper.

### T2 and T3 stayed scoreable under the stricter reread

Both later pairs remained stable under conservative second-pass scoring. That matters
more than aesthetic cleanliness. A frozen protocol does not require perfect runs; it
requires that the method produce interpretable evidence when deviations are recorded
honestly.

### The remaining T3 issues are operational, not design-level gaps

T3 still included real complications:

- H needed operator-side handoff recovery on a historical revision,
- F needed a bounded relaunch after an exploratory first attempt,
- and F required fallback artifact capture after a post-validation shell hang.

These are important limits and must remain visible in the paper. But they do not show
that the revised protocol itself is underspecified. The protocol already tells the
investigator how to preserve, separate, and score such deviations.

## Scope of the freeze

The freeze applies to the current first-paper comparison design:

1. two conditions, Harness versus Freestyle,
2. same host and model family within a paired run,
3. same starting revision and same task packet across conditions,
4. mandatory shared scored stop line,
5. mandatory durable session export or explicit export-failure note for each condition,
6. explicit separation of post-target extension from the primary scored comparison,
7. mandatory paired preflight from the packet's starting revision,
8. strict independence between conditions,
9. explicit deviation recording and invalidation review when needed.

This freeze is therefore narrow and operational. It does not claim that the broader
thesis is settled, only that the protocol is now strong enough to support the next study
phase without another preemptive redesign.

## What the freeze does not claim

Freezing the protocol does **not** mean:

- that the harness is already validated on C1-C3,
- that T1-T3 are free of threats to validity,
- that historical harness startup/handoff fragility has been eliminated,
- or that later task classes will not require a future protocol revision.

The freeze only means that the current method is good enough to stop pilot-driven
redesign and move into disciplined evidence collection.

## Rules for reopening the protocol

The protocol should be reopened only if a later run shows a new design-level failure
that the frozen rules cannot already represent cleanly. Examples would include:

- inability to define a credible shared scored stop line for the chosen task class,
- inability to preserve durable session evidence symmetrically enough to score C1-C4,
- repeated condition contamination that the current independence rules do not control,
- or a construct-validity problem that makes the current C1-C4 coding framework unusable.

Historical implementation bugs, export glitches, or single-run recoveries are not by
themselves grounds to reopen the method if the frozen protocol already captures them as
deviations or invalidation-review cases.

## Immediate implications

1. treat [experimental-protocol.md](experimental-protocol.md) as the frozen method base
   for the next phase,
2. write the method section from that frozen protocol rather than continuing pilot-era
   redesign,
3. write the results section against the now-explicit weaker reading of the thesis,
4. keep [limitations-and-threats-to-validity.md](limitations-and-threats-to-validity.md)
   attached to the pilot narrative so the freeze is not misread as clean validation.