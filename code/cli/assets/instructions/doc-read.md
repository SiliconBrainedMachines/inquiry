---
name: doc-read
description: 'Protocol for reading investigation material. Use when: consulting existing analysis, looking up previous findings, checking for duplicates. Implements query planner: index scan → filter → partial read → full read. Never scan directories file by file.'
---

# doc-read — Investigation Documentation Reading Protocol

## Prompt Summary

Read index_file first from inquiry-context.
Use the index to filter candidate documents.
If needed read frontmatter before a full document read.
Stop as soon as you have enough evidence.
Never scan a directory file by file.
Trust authoritative_handoff first when the context policy says it is authoritative.
Use retrieval_context only for concrete gaps that the authoritative artifact does not resolve.
Let retrieval_trigger_rule decide when bounded context may be widened.
Treat reread_avoidance_rule as a hard warning against broad rediscovery.

## When to Use

- Before writing new documentation (to avoid duplicates)
- When you need context from previous findings
- When referencing existing analysis documents
- When checking what has already been confirmed

## Reading the inquiry-context Block

At the end of your prompt, the CLI injects a fenced YAML block:

```yaml
# --- inquiry-context ---
output_dir: cleanrooms/<branch>/analyze/
index_file: cleanrooms/<branch>/analyze/index.md
context_policy: authoritative-handoff
upfront_context: ['cleanrooms/<branch>/analyze/diagnosis.md']
retrieval_context: ['cleanrooms/<branch>/analyze/index.md', '<project_root>']
deferred_context: ['reconstructing ANALYZE from broad rereads when diagnosis.md is already authoritative']
retrieval_trigger_rule: retrieve adjacent repo evidence only when diagnosis.md leaves a concrete gap that would change plan structure, scope, or verification
reread_avoidance_rule: do not reconstruct ANALYZE from broad rereads when diagnosis.md already answers the planning question
authoritative_handoff: cleanrooms/<branch>/analyze/diagnosis.md
authority_rule: trust diagnosis.md as the planning baseline unless a concrete gap requires targeted retrieval
```

- `index_file` — ALWAYS read this first
- `output_dir` — where all investigation documents live
- `upfront_context` — the initial bounded context that should be trusted before wider retrieval
- `retrieval_context` — the allowed next retrieval surfaces when a real gap remains
- `deferred_context` — context that should remain outside the prompt window unless explicitly justified
- `retrieval_trigger_rule` — the concrete threshold that licenses widening retrieval beyond bounded context
- `reread_avoidance_rule` — the explicit warning describing which rereads should be treated as harness waste
- `authoritative_handoff` — the durable artifact that currently carries authority across phase boundaries
- `authority_rule` — the condition that decides when to trust the artifact instead of rebuilding context

## Protocol

Follow these steps in order. Stop as soon as you have enough information.

### Step 1: Read the Index

Read `index_file` from the inquiry-context block. This is your primary index.

```
ALWAYS read index_file FIRST.
NEVER list or scan a directory file by file.
```

### Step 2: Filter on Index

Use the index table columns (File, Title, Status, Tags) to identify relevant documents. If the index provides enough information, **stop here**.

### Step 3: Partial Read

If you need more detail, read only the frontmatter (first 15 lines) of candidate files to verify relevance before committing to a full read.

### Step 4: Full Read

Only perform a full read of files confirmed as relevant in Steps 2-3.

## Rules

1. **Index first** — Never open individual files without consulting the index
2. **Trust authority first** — If `authoritative_handoff` already covers the question, do not widen retrieval by habit
3. **Filter before reading** — Use index metadata to narrow candidates
4. **Partial before full** — Read frontmatter to verify relevance
5. **No full scans** — If the index doesn't help, report that the query returned no results
6. **Minimum reads** — Optimize for fewest file reads that answer the question

## Authority Discipline

- Treat duplicate rereads of already-authoritative artifacts as harness waste.
- Widen retrieval only when a concrete ambiguity, missing fact, or code-level question remains unresolved.
- Let `retrieval_trigger_rule` name the exact gap before widening context.
- Keep `deferred_context` outside the working set unless you can name the uncertainty it would resolve.
- Treat `reread_avoidance_rule` as the default unless fresh evidence proves the handoff is insufficient.
