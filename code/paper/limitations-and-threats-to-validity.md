# Pilot Limitations and Threats to Validity

> **Type:** evidence
> **Status:** draft
> **Depends on:** [evidence/evidence-plan.md](evidence/evidence-plan.md), [evidence/pilot-claim-summary-t1-t2-t3.md](evidence/pilot-claim-summary-t1-t2-t3.md), [evidence/t1-pilot-second-scoring-pass.md](evidence/t1-pilot-second-scoring-pass.md), [evidence/t3-pair-capture.md](evidence/t3-pair-capture.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), future manuscript draft

This document states the current pilot's limitations and threats to validity in a form
that can be carried into the manuscript. It is not a generic disclaimer list. The
points below are tied to the retained T1-T3 evidence and to the protocol changes that
the pilot itself forced.

## Controlling stance

Three writing constraints follow directly from the completed pilot:

1. report null and mixed results as results rather than softening them into rhetorical
   advantages,
2. report harness overhead unconditionally, even where it weakens the practical case,
3. separate protocol effects from harness effects whenever the evidence does not cleanly
   isolate them.

## Internal validity threats

### Protocol maturation across the pilot

The three pilot tasks were not run under an identical protocol.

- T1 exposed weaknesses in shared stop-line definition, session-export symmetry, and
  post-target extension recording.
- T2 and T3 were then run under the revised protocol, which materially improved the
  retained freestyle record.

This means the three-task pilot is informative, but not a pure like-for-like series.
Part of the observed change from T1 to T2/T3 reflects methodological repair rather than
task effect alone.

### Operator intervention inside the harness path

T3 H required manual intervention before the scored run could proceed cleanly from
`IDLE` into `ANALYZE`. Two pre-scored attempts and a preserved operator handoff were
needed before the final scored pass ran.

This matters for interpretation in two ways:

- some observed H overhead includes recovery from historical handoff fragility rather
  than only the intended harness workflow,
- and the pilot cannot honestly present the harness as fully self-propelling on all
  historical revisions tested so far.

### Relaunch effects inside the freestyle path

T3 F also required a preserved exploratory first attempt and then a stricter bounded
relaunch. That relaunch stayed within the same condition and reused only locally
discovered context, but it still introduces a within-condition learning effect.

The defensible claim is therefore limited: the T3 F run remained scoreable and bounded,
not that it was a pristine single-pass execution.

## Measurement and construct validity threats

### Capture quality changes the apparent comparative story

T1 showed that weak freestyle capture can depress C2 and C3 scores even when the live
run looked more competent than the durable record later allowed the investigator to
credit. T2 and T3 then showed that once durable export symmetry is enforced, those same
constructs can move toward parity.

This is a central validity threat, not a side note: some apparent H advantage on C2/C3
may actually be a capture-quality advantage rather than a reasoning-quality advantage.

### The pilot does not yet isolate the full strong-path construct

The thesis is stronger than what the current pilot cleanly demonstrates. The present
evidence supports that the harness externalizes process and preserves a scoreable record,
but it does not yet justify a broad claim that the named philosophical machinery itself
drives better outcomes on C1-C3.

Until a design isolates operator effect from generic structure and capture discipline,
the paper should treat the strong path as unconfirmed rather than partially validated.

### Artifact irregularities can be scoreable without being clean

T3 F remained scoreable despite a post-validation artifact-capture failure that required
investigator-side fallback files. That is good news for robustness, but it also means
the retained record includes recovery procedures rather than only native run outputs.

The paper should present that as a limitation of the measurement path, not as invisible
background cleanup.

## External validity threats

### Small N and single repository

The pilot covers only three tasks in one repository. That is enough to surface method
problems and stabilize some measurements, but not enough to justify broad generalization
about agentic coding systems across repositories, languages, or organizational settings.

### Environment coupling

The pilot is tightly coupled to the observed Windows environment, the specific host tool
stack, and the concrete versions in use during the runs. Historical revision behavior,
terminal behavior, export behavior, and validation wrappers all matter here.

The current evidence therefore supports claims about this evaluated setup, not about all
possible host/model/tool combinations.

### Bounded task class

T1-T3 are all bounded engineering tasks. They are useful for studying evidence capture,
reconstructability, and overhead, but they do not yet establish how the comparison
behaves on larger design tasks, ambiguous diagnosis tasks, or long-running multi-file
change programs.

## Conclusion-validity threats

### Overhead is the strongest stable result

The pilot's most stable cross-task result is C4, not a broad H advantage on C1-C3.
If later prose foregrounds reconstructability or evidence-discipline gains without
giving equal weight to the repeated overhead asymmetry, the conclusion will overstate
what the data currently supports.

### Null and mixed findings constrain the paper's thesis

After T1-T3, C1 remains unconfirmed and C2/C3 remain mixed, with the stronger recent
pattern at parity once durable freestyle capture improves. That means the paper cannot
honestly present the pilot as preliminary confirmation of the full strong-path thesis.

The strongest defensible use of the pilot is narrower: it supports a methodological
claim about protocol design and a practical claim about high harness overhead.

## Immediate implications for the paper

1. write the pilot as a methodological correction against overclaiming, not as an early
   victory lap for the full thesis,
2. keep the thesis narrow unless a later study isolates operator effect more cleanly,
3. freeze or revise the protocol explicitly before opening full evidence collection,
4. treat T1-style record asymmetry and T3-style rescue paths as findings about the
   method, not as noise to be edited away.