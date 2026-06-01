---
name: doc-write
description: 'Protocol for writing investigation material. Use when: documenting findings, recording confirmed hypotheses, writing analysis documents. The CLI creates file templates with pre-filled frontmatter — the AI fills content sections and maintains the index.'
---

# doc-write — Investigation Documentation Writing Protocol

## Prompt Summary

Write inside the CLI-created template and keep frontmatter unchanged.
Store documents in output_dir.
Update index_file after every write.
Keep one topic per document.
Use confirmations_doc for confirmations when it applies.
Treat upfront_context as your bounded starting context.
Use retrieval_context only when the current uncertainty requires more evidence.
Build authoritative_handoff so later phases do not need to reconstruct ANALYZE from scratch.
Let retrieval_trigger_rule justify any widening beyond bounded context.
Honor reread_avoidance_rule so writing work does not restart discovery by habit.

## When to Use

- When recording confirmed findings during analysis
- When documenting research, evidence, or investigation results
- When creating additional topic-specific documents
- After any write operation (to update the index)

## Reading the inquiry-context Block

At the end of your prompt, the CLI injects a fenced YAML block:

```yaml
# --- inquiry-context ---
output_dir: cleanrooms/<branch>/analyze/
index_file: cleanrooms/<branch>/analyze/index.md
confirmations_doc: cleanrooms/<branch>/analyze/confirmations.md
context_policy: progressive-disclosure
upfront_context: ['cleanrooms/<branch>/issue.md', 'cleanrooms/<branch>/analyze/index.md']
retrieval_context: ['cleanrooms/<branch>/analyze/index.md', 'cleanrooms/<branch>/analyze/confirmations.md', '<project_root>']
deferred_context: ['broad repository rereads not justified by the active uncertainty']
retrieval_trigger_rule: widen retrieval only when the bounded analysis corpus leaves a named uncertainty unresolved
reread_avoidance_rule: do not restart repository-wide discovery when issue.md, index.md, and confirmations.md already bound the active uncertainty
authoritative_handoff: cleanrooms/<branch>/analyze/diagnosis.md
authority_rule: diagnosis.md becomes the authoritative handoff to PLAN once written
```

- `output_dir` — where ALL your documents go
- `index_file` — the index you MUST update after every write
- `confirmations_doc` — the mandatory living document for confirmations
- `upfront_context` — the bounded starting context you should trust before wider retrieval
- `retrieval_context` — the next retrieval surfaces if bounded context is insufficient
- `deferred_context` — context that should stay out of the working set unless a concrete gap justifies it
- `retrieval_trigger_rule` — the explicit condition that must be true before widening retrieval
- `reread_avoidance_rule` — the rule that marks broad rediscovery as harness waste for this phase
- `authoritative_handoff` — the artifact this phase is expected to leave as durable authority for the next phase
- `authority_rule` — the rule that defines when the handoff outranks broad rereads

## How It Works

The CLI creates file templates with pre-filled YAML frontmatter. Your job:

1. **Fill content sections** — write below the frontmatter
2. **Never modify frontmatter** — the CLI sets id, title, date, status, tags, author
3. **Update the index** — after every write (see Index Update Procedure below)
4. **Reduce duplicate rereads** — prefer `confirmations_doc`, `index_file`, and current bounded context over restarting repository-wide discovery

## Creating New Documents

When you need a new document beyond `confirmations.md`:

1. Create the file in `output_dir` with this frontmatter:

```yaml
---
id: <slug>                           # Matches filename (without .md)
title: <descriptive title>           # One sentence
date: <YYYY-MM-DD>                   # Today's date
status: active                       # Start as active
tags: [tag1, tag2]                   # Lowercase, hyphenated
author: <your-ape-name>              # e.g., socrates
---
```

2. Use a descriptive filename: `root-cause-analysis.md`, not `doc1.md`
3. One topic per document — if covering two themes, split into two files
4. No empty sections — write "To be determined" if content is pending

## Index Update Procedure

After EVERY file create or modify, update `index_file`:

### Format

Add or update a row in the documents table:

```markdown
| # | File | Title | Status | Tags |
|---|------|-------|--------|------|
| 1 | confirmations.md | Confirmations | active | confirmations, findings |
| 2 | <new-file>.md | <title> | <status> | <tags> |
```

### Rules

1. Every document in `output_dir` MUST have a row in the index
2. Index rows MUST match the frontmatter of the file they reference
3. Update the index **immediately** after writing — never defer
4. Increment the row number sequentially
5. If the index doesn't exist, create it with a descriptive H1 and the table

## Authority Discipline

While analyzing, `diagnosis.md` is not just another output. It is the handoff artifact later phases should trust first.

1. Use `confirmations_doc` and topic docs to ground claims.
2. Synthesize those findings into `authoritative_handoff`.
3. Do not force PLAN to rediscover context you could have stabilized in `diagnosis.md`.
4. Treat duplicate rereads that do not materially reduce uncertainty as harness waste.
5. Use `retrieval_trigger_rule` to justify any widening beyond bounded context.
6. Treat `reread_avoidance_rule` as the default unless new uncertainty is concrete and named.

## Checklist

Before completing any write operation, verify:

```
□ Frontmatter YAML present and valid
□ All required fields populated
□ ID is unique (checked against index)
□ Document covers a single topic
□ No empty sections
□ index.md updated with new/modified entry
```
