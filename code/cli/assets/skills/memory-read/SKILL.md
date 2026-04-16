---
name: memory-read
description: 'Protocol for reading structured documentation. Use when: searching project memory, reading analysis documents, looking up previous findings, consulting index files. Implements query planner: index scan → filter → partial read → full read. Never scan directories file by file.'
---

# memory-read — Structured Documentation Reading Protocol

## When to Use

- Before writing new documentation (to avoid duplicates)
- When you need context from previous analysis or findings
- When answering questions that may have been explored before
- When referencing existing decisions or documents

## Protocol

Follow these steps in order. Stop as soon as you have enough information.

### Step 1: Index Scan

Read the `index.md` in the relevant directory. This is your primary index.

```
ALWAYS read index.md FIRST.
NEVER list or scan a directory file by file.
```

### Step 2: Filter on Index

Use the index table columns (ID, Title, Date, Status, Tags) to identify relevant documents. If the index provides enough information, **stop here**.

### Step 3: Partial Read

If you need more detail, read only the frontmatter (first 15 lines) of candidate files to verify relevance before committing to a full read.

### Step 4: Full Read

Only perform a full read of files confirmed as relevant in Steps 2-3.

## Rules

1. **Index first** — Never open individual files without consulting the index
2. **Filter before reading** — Use index metadata to narrow candidates
3. **Partial before full** — Read frontmatter to verify relevance
4. **No full scans** — If the index doesn't help, report that the query returned no results
5. **Minimum reads** — Optimize for fewest file reads that answer the question
