verdict: BLOCKED

# END Pre-PR Inspection

issue: "247"
branch: "247-opencode-host-support"
generated_at: "2026-06-16T23:31:09.904881Z"

## Pass 1 — Consistency
- WARN: no source/build asset mirror detected under assets/ and build/assets; automatic parity skipped for this repo

## Pass 2 — Completeness
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:25
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:26
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:31
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:32
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:38
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:48
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:50
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:59
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:60
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:68
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:75
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:76
- FAIL: unchecked plan checkbox remains at cleanrooms/247-opencode-host-support/plan.md:77

## Pass 3 — Traceability
- PASS: inspection metadata matches active issue "247" and branch "247-opencode-host-support"
- PASS: overhead summary event counts transition=3, sensor_run=15, block=0, retry=0, phase_timing=2, tool_activity=5, model_activity=1 at cleanrooms/247-opencode-host-support/run_trace.yaml:1
- PASS: overhead summary found no blocking boundaries before END in cleanrooms/247-opencode-host-support/run_trace.yaml:1
- PASS: overhead summary found no non-approved gates before END in cleanrooms/247-opencode-host-support/run_trace.yaml:1
- PASS: overhead summary found no retries before END in cleanrooms/247-opencode-host-support/run_trace.yaml:1
- PASS: overhead summary shows highest observed phase cost at ANALYZE=3783.008s in cleanrooms/247-opencode-host-support/run_trace.yaml:1
- PASS: overhead summary estimates model-bound prompt input as [socrates=2382 est_tokens/9526 chars/0.001s assembly] in cleanrooms/247-opencode-host-support/run_trace.yaml:1
- WARN: overhead summary attributes host-boundary activity as [git=4, gh=1], harness control-path activity as 20 trace events plus 0.001s of local prompt assembly time, and leaves only remote model runtime/caching cost unattributed in local surfaces at cleanrooms/247-opencode-host-support/run_trace.yaml:1
- WARN: traceability findings include automatic issue/branch metadata review plus a minimal overhead summary from run_trace and metrics_snapshot, including model-bound prompt estimates and remaining remote runtime attribution limits, when END is entered and refreshed again at pr_ready; replace or complement this with concrete issue/plan mapping findings before approval

## Citation Guidance

- Every FAIL must include a repo-relative file:line citation, for example `code/cli/lib/modules/fsm/commands/transition.dart:355`
- WARN findings should cite file:line when they are grounded in a concrete file-backed observation
