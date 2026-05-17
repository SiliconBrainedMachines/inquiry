# Book-as-Code Infrastructure — Decisions Record

**Date:** April 2026
**Status:** Approved. Implementation in progress.

---

## Architecture

**Flat repo.** The repository `philo_sophia` is the book. Source, build system, and documentation all live at the root — no intermediate `code/` directory. This project serves as the reference implementation; future books will follow the same patterns observed here.

```
philo_sophia/
├── .devcontainer/     # Reproducible development environment
├── .github/workflows/ # CI/CD: build + validate + release
├── src/               # Markdown source (one dir per language)
│   ├── en/            # English (primary)
│   ├── es/            # Spanish
│   └── shared/        # Images, diagrams, bibliography
├── templates/         # Typst + EPUB templates
├── covers/            # Cover images for all formats
├── docs/              # Analysis, planning, research
│   └── analyze/       # Completed: 15 documents
├── Makefile           # Build automation
├── main-en.typ        # Typst entry point (English)
├── main-es.typ        # Typst entry point (Spanish)
├── .vale.ini          # Prose linting config
└── dist/              # Build output (gitignored)
```

---

## Decisions

### D-01. Repository Strategy — Flat Repo (No `code/` Wrapper)

The book's source and build system live at the repo root. No intermediate `code/` directory — the repo *is* the book. The analysis documentation lives in `docs/`.

**Rationale:** A `code/` wrapper is justified when multiple code domains coexist (e.g., `db/`, `api/`, `ui/`). A book has one domain: content. The flat structure is simpler and conventional for single-purpose repos. If a second book is created, it gets its own repo following the same structure.

### D-02. Language Strategy — English Primary, All Languages Are Originals

- English (`src/en/`) is written first.
- Spanish (`src/es/`) and future languages (German, Japanese) are written as **original compositions**, not automated translations.
- Each language directory is a parallel, complete, independent source.
- The build system treats all languages identically — `LANG=en make build` or `LANG=es make build`.

**Adding a new language:**
1. Create `src/{lang}/` with the same file structure as `src/en/`
2. Create `main-{lang}.typ` entry point
3. Update `templates/epub-metadata-{lang}.yaml`
4. Build with `LANG={lang} make build`

### D-03. Dev Container — All Dependencies in Docker

A `.devcontainer/` configuration provides the complete build environment. No local dependencies required beyond Docker Desktop + WSL2 + VS Code.

**Included in container:**
| Tool | Purpose |
|------|---------|
| Typst | PDF generation (print-ready) |
| Pandoc | EPUB generation + Markdown→Typst conversion |
| Vale | Prose linting and style enforcement |
| ImageMagick | Image DPI verification |
| Make | Build automation |
| gh CLI | GitHub releases |
| Git | Version control |

**Excluded (conscious decision):**
| Tool | Reason | When to add |
|------|--------|-------------|
| Mermaid CLI | ~400 MB (Chromium). No diagrams yet. | When book has actual diagrams to render |
| LanguageTool | ~250 MB (Java). Vale covers 90% of linting. | If Vale proves insufficient |
| EPUBCheck | ~250 MB (Java JRE). Heavy for local dev. | Runs in CI/CD only (GitHub Actions has JRE) |

**EPUB validation strategy:** EPUBCheck runs in GitHub Actions on tag push, not locally. If local validation is needed before release, it can be added to the container later.

### D-04. Makefile — Bash (Runs Inside Container)

The Makefile uses standard bash syntax. It runs inside the dev container (Ubuntu), eliminating all Windows compatibility issues. No PowerShell adaptation needed.

### D-05. Content Strategy — Placeholder with Minimum Available Content

The initial structure contains:
- Front matter with title, subtitle, and dedication placeholder
- 10 chapters with titles, opening questions, and synopses extracted from `chapters.md`
- Back matter with acknowledgments placeholder
- Identical structure in English and Spanish

This produces a compilable book that can be previewed as PDF/EPUB immediately.

---

## Dev Container — Host Requirements

The developer's machine needs only:

1. **WSL2** — Windows Subsystem for Linux
2. **Docker Desktop** — with WSL2 backend enabled
3. **VS Code** — with the **Dev Containers** extension (`ms-vscode-remote.remote-containers`)

**First-time workflow:**
```
1. Open VS Code in philo_sophia/
2. VS Code detects .devcontainer/ → prompts "Reopen in Container"
3. Docker builds the image (~5 min first time, cached after)
4. Terminal is now Ubuntu with all tools installed
5. make draft → produces PDF
```

---

## Future Books — How to Replicate

When starting a new book project:

1. **Create a new repository** for the book
2. **Copy from `philo_sophia/`:**
   - `.devcontainer/` (entire directory — unchanged)
   - `.github/workflows/` (CI/CD — update artifact names)
   - `templates/` (Typst + EPUB templates — adjust typography if needed)
   - `Makefile` (update `BOOK_SLUG` variable)
   - `.vale.ini` + `.vale/` (style rules — unchanged)
3. **Create fresh:**
   - `src/{lang}/` with new chapter files
   - `main-{lang}.typ` with new chapter includes
   - `templates/epub-metadata-{lang}.yaml` with new book metadata
   - `covers/` with new cover images
4. **Build:** `make build` — same commands, same output

**Future optimization:** When the second book is started, extract the dev container image and shared templates into a dedicated `book-pipeline` repo. Publish the image to GHCR. All books then reference the shared image instead of duplicating files. This is not done now to avoid premature abstraction.

---

## CI/CD — Release Pipeline

```
git tag v1.0.0 → push → GitHub Actions:
  1. Build PDF (en) + PDF (es) via Typst
  2. Build EPUB (en) + EPUB (es) via Pandoc
  3. Validate EPUBs via EPUBCheck (JRE available in runner)
  4. Create GitHub Release with all artifacts
  5. Download artifacts → upload to KDP manually
```

KDP upload remains manual (no API available for indie publishers as of 2026).

---

## Version History

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-04 | Flat repo (no `code/` wrapper) | Repo is the book; `code/` only justified with multiple code domains |
| 2026-04 | Dev container with Vale only | Minimal viable toolchain; extend when needed |
| 2026-04 | EPUBCheck in CI only | Saves ~250 MB in container; validation still happens |
| 2026-04 | No Mermaid CLI | No diagrams yet; add when needed |
| 2026-04 | English first, all langs are originals | Author writes all versions; no auto-translation |
