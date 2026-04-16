---
name: memory-write
description: 'Protocol for writing structured documentation. Use when: creating analysis documents, documenting findings, writing specifications, updating project memory. Enforces YAML frontmatter schema, one topic per document, and index.md maintenance. Based on memory-as-code architecture.'
---

# memory-write — Structured Documentation Writing Protocol

## When to Use

- When creating new documentation files (.md)
- When updating existing documentation
- When documenting analysis findings, decisions, or research
- After any write operation (to update the index)

## Schema

Every document MUST begin with a YAML frontmatter block:

```yaml
---
id: <slug>                           # Unique identifier, matches filename
title: <descriptive title>           # Human-readable, one sentence
date: <YYYY-MM-DD>                   # Creation date
status: draft | active | completed   # Current lifecycle state
tags: [tag1, tag2]                   # Searchable keywords
author: <agent-name>                 # Who created this document
---
```

### Rules for Frontmatter

- All fields are required
- `id` must be unique within the directory (check index before writing)
- `status` transitions: `draft → active → completed`
- `tags` use lowercase, hyphenated terms

## Document Rules

1. **One topic per document** — If the document covers two distinct themes, split it
2. **Descriptive filenames** — The filename should reflect the content: `root-cause-analysis.md`, not `doc1.md`
3. **No empty sections** — If a section has no content yet, write "To be determined" with context
4. **Headers follow hierarchy** — H1 is the document title, H2 for major sections, H3 for subsections

## Index Maintenance

After creating or modifying ANY document, update the directory's `index.md`:

### Index Table Format

```markdown
| ID | Title | Date | Status | Tags |
|----|-------|------|--------|------|
| <id> | <title> | <date> | <status> | <tags> |
```

### Index Rules

1. Every document in the directory MUST have an entry in the index
2. Index entries MUST match the frontmatter of the file they reference
3. Update the index **immediately** after writing — never defer
4. If the index doesn't exist, create it with a descriptive H1 and the table

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
