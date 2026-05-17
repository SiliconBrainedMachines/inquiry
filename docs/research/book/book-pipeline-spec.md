# Book-as-Code Publishing Pipeline

**Version:** 0.1.0
**Purpose:** Reusable pipeline for writing, building, and publishing books from markdown source to Amazon KDP (Kindle, paperback, hardcover) and wide distribution.
**Philosophy:** The book is code. The publication is a `git push`.

---

## 1. Overview

```
┌─────────────┐     ┌──────────┐     ┌───────────┐     ┌──────────────┐
│  Markdown    │────▶│  Build   │────▶│  Validate │────▶│  Distribute  │
│  (src/*.md)  │     │  System  │     │  & QA     │     │  KDP / IS    │
└─────────────┘     └──────────┘     └───────────┘     └──────────────┘
       │                  │                                    │
       │           ┌──────┴──────┐                            │
       │           │             │                     ┌──────┴──────┐
       │        Typst        Pandoc                    │             │
       │           │             │                   Amazon     IngramSpark
       │      PDF (print)   EPUB (digital)          (KDP)       (wide)
       │           │             │
       ▼           ▼             ▼
    VSCode    libro.pdf     libro.epub
    writing   (6"×9")      (reflowable)
```

### Design Principles

1. **Single source of truth.** All content lives in `.md` files. Everything else is generated.
2. **Separation of content and presentation.** Markdown has no styling. Templates handle all formatting.
3. **Reproducible builds.** Same source → same output. Always. `make build` on any machine.
4. **Version everything.** Git tracks every change. SemVer tags mark editions. `git diff v1.0.0..v1.1.0` shows exactly what changed between editions.
5. **Automate the tedious.** Linting, word count, builds, validation, releases — all in the Makefile. GitHub Actions handles CI/CD.

---

## 2. Tech Stack

| Role | Tool | Why |
|------|------|-----|
| Editor | VSCode + Markdown All in One + Word Count | Best markdown editing experience |
| Prose linting | Vale + LanguageTool | Style consistency + grammar |
| PDF build | Typst | Modern typesetting, fast compilation, clean output |
| EPUB build | Pandoc | Best markdown-to-EPUB converter |
| EPUB validation | EPUBCheck | IDPF standard validator |
| EPUB preview | Calibre | Visual review, device simulation |
| Bibliography | Hayagriva (.yml) or BibTeX (.bib) | Native Typst support + Pandoc compatible |
| Diagrams | Mermaid CLI | Diagrams as code |
| Image processing | ImageMagick | DPI verification, format conversion, optimization |
| Automation | Make | Universal, simple, declarative |
| Version control | Git + SemVer | Complete change history |
| Releases | GitHub Releases + `gh` CLI | Automated artifact distribution |
| CI/CD | GitHub Actions | Build on tag, attach artifacts to release |

### Prerequisites

```bash
# Core tools
brew install typst pandoc vale calibre imagemagick gh git

# EPUBCheck (Java required)
brew install epubcheck

# Node tools (for Mermaid)
npm install -g @mermaid-js/mermaid-cli

# Vale styles
vale sync

# LanguageTool (optional, for grammar)
brew install languagetool
```

---

## 3. Repository Structure

```
book-title/
├── .github/
│   └── workflows/
│       └── release.yml              # CI/CD: build + release on tag
│
├── src/
│   ├── en/                          # Primary language: English
│   │   ├── 00-front-matter.md       # Title, dedication, epigraph
│   │   ├── 01-chapter-one.md        # Chapter 1
│   │   ├── 02-chapter-two.md        # Chapter 2
│   │   ├── ...                      # One file per chapter
│   │   ├── 99-back-matter.md        # Acknowledgments, about author
│   │   └── appendix-a.md            # Appendices
│   │
│   ├── es/                          # Secondary language: Spanish
│   │   ├── 00-front-matter.md
│   │   ├── 01-capitulo-uno.md
│   │   └── ...
│   │
│   └── shared/                      # Language-independent assets
│       ├── images/                   # Illustrations, figures
│       │   └── fig-01-01.png         # Naming: fig-{chapter}-{number}
│       ├── diagrams/                 # Mermaid source files
│       │   └── fig-01-01.mmd
│       └── bibliography.yml         # Hayagriva format (or .bib)
│
├── templates/
│   ├── book-print.typ               # Typst template: print PDF (6"×9")
│   ├── book-digital.typ             # Typst template: digital/screen PDF
│   ├── epub.css                     # EPUB stylesheet
│   └── epub-metadata.yaml           # Pandoc EPUB metadata
│
├── covers/
│   ├── ebook-cover.jpg              # Kindle: 2560×1600px, 300 DPI, RGB
│   ├── paperback-cover.pdf          # KDP paperback: calculated dimensions
│   ├── hardcover-cover.pdf          # KDP hardcover: calculated dimensions
│   └── cover-source/                # Editable cover files (PSD, AI, etc.)
│
├── dist/                            # Build output (gitignored)
│   ├── book-en.pdf                  # Print-ready PDF
│   ├── book-en.epub                 # Validated EPUB
│   ├── book-en-digital.pdf          # Screen-optimized PDF
│   ├── book-es.pdf
│   └── book-es.epub
│
├── .vale/                           # Vale configuration
│   ├── styles/                      # Custom style rules
│   └── .vale.ini                    # Vale config
│
├── main-en.typ                      # Typst entry point (English)
├── main-es.typ                      # Typst entry point (Spanish)
├── Makefile                         # Build automation
├── CHANGELOG.md                     # Edition history
└── README.md                        # Project documentation
```

### File Naming Conventions

- **Chapters:** `{NN}-{slug}.md` where NN is zero-padded order (01, 02, ... 99)
- **Images:** `fig-{chapter}-{number}.{ext}` (e.g., `fig-03-02.png`)
- **Diagrams:** Same naming as images but `.mmd` extension
- **Output:** `{book-slug}-{lang}.{ext}` (e.g., `philo-sophia-en.pdf`)

---

## 4. Amazon KDP Specifications

### 4.1 Kindle eBook

| Spec | Value |
|------|-------|
| File format | EPUB (recommended), DOCX as fallback |
| Cover image | 2,560 × 1,600 px (height × width), 1.6:1 ratio |
| Cover DPI | 300 minimum |
| Cover format | JPEG (preferred) or TIFF |
| Cover color | RGB (not CMYK) |
| Cover max size | 50 MB |
| EPUB version | EPUB 3 preferred, EPUB 2 accepted |
| Validation | Must pass EPUBCheck + Kindle Previewer |
| ISBN | Not required for Kindle eBooks |
| MOBI | No longer accepted (deprecated March 2025) |

**Royalties:**
- 70% for eBooks priced $2.99–$9.99 (must be 20% cheaper than print)
- 35% for eBooks priced below $2.99 or above $9.99

### 4.2 Paperback (Pasta Blanda)

| Spec | Value |
|------|-------|
| Trim size | 6" × 9" (standard non-fiction) |
| Interior with bleed | 6.125" × 9.25" |
| Interior without bleed | 6" × 9" |
| Bleed | 0.125" (3.2mm) all sides |
| Margins (outside, top, bottom) | Minimum 0.375" (with bleed) |
| Gutter (inside margin) | Varies by page count (see formula) |
| Interior DPI | 300 minimum |
| Cover DPI | 300 minimum |
| Paper options | White, Cream |
| Ink options | Black & white, Standard color, Premium color |
| Page count | 24–828 pages (6"×9") |
| Interior format | PDF |
| Cover format | Single PDF (front + spine + back) |

**Spine width calculation:**
- White paper: `page_count × 0.002252"`
- Cream paper: `page_count × 0.0025"`

**Cover PDF dimensions:**
```
width  = (2 × trim_width) + spine_width + (2 × 0.125")
height = trim_height + (2 × 0.125")

Example (300 pages, white paper, 6"×9"):
  spine  = 300 × 0.002252 = 0.676"
  width  = (2 × 6) + 0.676 + 0.25 = 12.926"
  height = 9 + 0.25 = 9.25"
```

**Royalties (effective June 2025):**
- 60% for books priced $9.99+
- 50% for books below $9.99

### 4.3 Hardcover (Pasta Dura)

| Spec | Value |
|------|-------|
| Trim size | 6" × 9" (standard non-fiction) |
| Format | Case laminate only (no dust jacket on KDP) |
| Lamination | Glossy or Matte |
| Interior specs | Same as paperback |
| Page count | 75–550 pages (6"×9") |
| Paper (B&W) | White or Cream |
| Paper (Color) | White only, Premium color |
| Cover wrap | 0.59" (15mm) on all sides |
| Spine hinge | 0.4" (10mm) each side |

**Cover PDF dimensions (different from paperback):**
```
width  = (2 × trim_width) + spine_width + 0.394" + (2 × 0.591")
height = trim_height + 0.236" + (2 × 0.591")
```

### 4.4 ISBN Strategy

| Format | Free KDP ISBN | Own ISBN |
|--------|--------------|----------|
| Kindle eBook | Not available (not needed) | Optional |
| Paperback | Available (imprint: "Independently published") | Recommended |
| Hardcover | Available | Recommended |
| IngramSpark | Not available | **Required** |

**Recommendation:** Purchase your own ISBN ($125 via Bowker) for each format if you plan wide distribution via IngramSpark. Use a custom imprint name for professional branding.

### 4.5 Distribution Strategy

| Channel | Platform | Formats | Notes |
|---------|----------|---------|-------|
| Amazon eBook | KDP | Kindle (from EPUB) | Consider KDP Select for Kindle Unlimited |
| Amazon Print | KDP | Paperback + Hardcover | Automatic Amazon listing |
| Bookstores/Libraries | IngramSpark | Paperback + Hardcover | Requires own ISBN. 40,000+ retailers |
| Direct sales | Gumroad / own site | PDF + EPUB | Highest margin, smallest audience |

---

## 5. Typst Configuration

### 5.1 Known Limitation: Bleed and Crop Marks

**As of 2026, Typst does not natively support bleed or crop marks.** This is tracked in [GitHub Issue #3131](https://github.com/typst/typst/issues/3131).

**Workaround for KDP:** Typst can generate PDFs with oversized pages (adding bleed area manually), and KDP accepts PDFs without crop marks as long as the page dimensions match the bleed size. This is the approach used in the pipeline.

```typst
// For 6"×9" with 0.125" bleed on all sides:
#set page(
  width: 6.25in,   // 6" + 2×0.125"
  height: 9.25in,  // 9" + 2×0.125"
  margin: (
    top: 0.5in,     // 0.375" minimum + 0.125" bleed offset
    bottom: 0.5in,
    outside: 0.5in,
    inside: 0.75in, // Gutter — adjust by page count
  ),
)
```

### 5.2 Template Structure (book-print.typ)

```typst
// book-print.typ — Print-ready template for 6"×9" books
// Compatible with Amazon KDP paperback and hardcover

// ─── Page Setup ──────────────────────────────────────
#set page(
  width: 6.25in,
  height: 9.25in,
  margin: (top: 0.5in, bottom: 0.5in, outside: 0.5in, inside: 0.75in),
  header: context {
    // No header on chapter opening pages
    if counter(page).get().first() > 1 {
      set text(size: 9pt, style: "italic")
      // Even pages: book title | Odd pages: chapter title
    }
  },
  footer: context {
    set align(center)
    set text(size: 9pt)
    counter(page).display()
  },
)

// ─── Typography ──────────────────────────────────────
#set text(
  font: "Libertinus Serif",  // Professional serif, bundled with Typst
  size: 11pt,
  lang: "en",
)

#set par(
  justify: true,
  first-line-indent: 1.5em,
  leading: 0.65em,           // Line spacing
)

// ─── Headings ────────────────────────────────────────
#show heading.where(level: 1): it => {
  pagebreak(weak: true)       // Each chapter starts on new page
  v(2in)                      // Top margin for chapter opening
  set text(size: 24pt, weight: "bold")
  block[
    Chapter #counter(heading).display()
    #v(0.5em)
    #it.body
  ]
  v(1in)
}

#show heading.where(level: 2): set text(size: 16pt, weight: "bold")
#show heading.where(level: 3): set text(size: 13pt, weight: "bold")

// ─── Block Quotes ────────────────────────────────────
#show quote: set pad(x: 2em)
#show quote: set text(style: "italic", size: 10pt)

// ─── Figures ─────────────────────────────────────────
#show figure.caption: set text(size: 9pt, style: "italic")

// ─── Bibliography ────────────────────────────────────
#set bibliography(style: "chicago-author-date")
```

### 5.3 Main Entry Point (main-en.typ)

```typst
// main-en.typ — Entry point for English edition

#import "templates/book-print.typ": *

// ─── Front Matter ────────────────────────────────────
#set page(numbering: "i")    // Roman numerals for front matter

#include "src/en/00-front-matter.md"

// ─── Body ────────────────────────────────────────────
#set page(numbering: "1")
#counter(page).update(1)

#include "src/en/01-language.md"
#include "src/en/02-knowledge.md"
#include "src/en/03-mind.md"
#include "src/en/04-reason.md"
#include "src/en/05-ethics.md"
#include "src/en/06-learning.md"
#include "src/en/07-truth.md"
#include "src/en/08-freedom.md"
#include "src/en/09-beauty.md"
#include "src/en/10-wisdom.md"

// ─── Back Matter ─────────────────────────────────────
#include "src/en/99-back-matter.md"
#include "src/en/appendix-a.md"

#bibliography("src/shared/bibliography.yml")
```

**Note on Markdown inclusion:** Typst can include `.typ` files natively. For markdown source files, you have two options:
1. **Write in Typst markup directly** — more control, no conversion issues.
2. **Convert markdown to Typst at build time** — use Pandoc: `pandoc src/en/*.md -t typst -o build/combined.typ`, then include the `.typ` output. Add this as a Makefile step.

Recommended: **write in markdown, convert at build time.** This preserves the "markdown as single source" principle while using Typst for final typesetting.

---

## 6. Pandoc EPUB Configuration

### epub-metadata.yaml

```yaml
---
title: "Philo SophIA"
subtitle: "From Thales to GPT"
author: "Dev"
lang: en
date: 2026
rights: "Copyright 2026 Dev. All rights reserved."
description: >
  A panoramic exploration of artificial intelligence through the
  lens of 2,500 years of philosophy.
cover-image: covers/ebook-cover.jpg
css: templates/epub.css
toc: true
toc-depth: 2
epub-chapter-level: 1
reference-section-title: "References"
bibliography: src/shared/bibliography.yml
csl: chicago-author-date.csl
---
```

### EPUB Build Command

```bash
pandoc src/en/*.md \
  --metadata-file=templates/epub-metadata.yaml \
  --css=templates/epub.css \
  --epub-cover-image=covers/ebook-cover.jpg \
  --bibliography=src/shared/bibliography.yml \
  --citeproc \
  --toc --toc-depth=2 \
  --epub-chapter-level=1 \
  -o dist/philo-sophia-en.epub
```

---

## 7. Makefile

```makefile
# ─── Configuration ────────────────────────────────────
BOOK_SLUG    := philo-sophia
LANG         := en
VERSION      ?= 0.0.1
TRIM_WIDTH   := 6
TRIM_HEIGHT  := 9
BLEED        := 0.125

# ─── Paths ────────────────────────────────────────────
SRC_DIR      := src/$(LANG)
SHARED_DIR   := src/shared
TEMPLATE_DIR := templates
COVER_DIR    := covers
DIST_DIR     := dist
BUILD_DIR    := build

SRC_FILES    := $(sort $(wildcard $(SRC_DIR)/*.md))
IMAGES       := $(wildcard $(SHARED_DIR)/images/*.png $(SHARED_DIR)/images/*.jpg)
DIAGRAMS     := $(wildcard $(SHARED_DIR)/diagrams/*.mmd)

PDF_OUT      := $(DIST_DIR)/$(BOOK_SLUG)-$(LANG).pdf
EPUB_OUT     := $(DIST_DIR)/$(BOOK_SLUG)-$(LANG).epub
DIGITAL_OUT  := $(DIST_DIR)/$(BOOK_SLUG)-$(LANG)-digital.pdf

# ─── Default ──────────────────────────────────────────
.PHONY: all clean lint count draft build validate preview release help

all: build validate

help:
	@echo "Usage:"
	@echo "  make draft      - Quick PDF build (no optimization)"
	@echo "  make build      - Full build: PDF + EPUB"
	@echo "  make validate   - Validate EPUB with EPUBCheck"
	@echo "  make lint       - Lint prose with Vale"
	@echo "  make count      - Word count per chapter"
	@echo "  make preview    - Build draft and open PDF"
	@echo "  make diagrams   - Render Mermaid diagrams to PNG"
	@echo "  make images-check - Verify all images are 300+ DPI"
	@echo "  make release    - Tag, push, and create GitHub release"
	@echo "  make clean      - Remove build artifacts"

# ─── Directories ──────────────────────────────────────
$(DIST_DIR) $(BUILD_DIR):
	mkdir -p $@

# ─── Prose Quality ────────────────────────────────────
lint:
	vale $(SRC_DIR)/*.md

count:
	@echo "──────────────────────────────────"
	@echo "Word count per chapter:"
	@echo "──────────────────────────────────"
	@for f in $(SRC_FILES); do \
		printf "%-40s %s\n" "$$(basename $$f)" "$$(wc -w < $$f)"; \
	done
	@echo "──────────────────────────────────"
	@printf "%-40s %s\n" "TOTAL" "$$(cat $(SRC_FILES) | wc -w)"

# ─── Diagrams ─────────────────────────────────────────
diagrams:
	@for f in $(DIAGRAMS); do \
		mmdc -i $$f -o $(SHARED_DIR)/images/$$(basename $$f .mmd).png -w 2400; \
	done

# ─── Image Verification ──────────────────────────────
images-check:
	@echo "Checking image DPI (minimum 300)..."
	@for f in $(IMAGES); do \
		DPI=$$(identify -format "%x" $$f 2>/dev/null | cut -d. -f1); \
		if [ -n "$$DPI" ] && [ "$$DPI" -lt 300 ]; then \
			echo "WARNING: $$f is $$DPI DPI (needs 300+)"; \
		fi; \
	done
	@echo "Image check complete."

# ─── Build: Markdown → Typst ─────────────────────────
$(BUILD_DIR)/combined.typ: $(SRC_FILES) | $(BUILD_DIR)
	pandoc $(SRC_FILES) -t typst -o $@ \
		--bibliography=$(SHARED_DIR)/bibliography.yml \
		--citeproc

# ─── Build: PDF (print-ready) ────────────────────────
$(PDF_OUT): $(BUILD_DIR)/combined.typ | $(DIST_DIR)
	typst compile main-$(LANG).typ $@ \
		--font-path=templates/fonts

draft: | $(BUILD_DIR) $(DIST_DIR)
	pandoc $(SRC_FILES) -t typst -o $(BUILD_DIR)/combined.typ
	typst compile main-$(LANG).typ $(DIST_DIR)/draft-$(LANG).pdf

# ─── Build: EPUB ──────────────────────────────────────
$(EPUB_OUT): $(SRC_FILES) | $(DIST_DIR)
	pandoc $(SRC_FILES) \
		--metadata-file=$(TEMPLATE_DIR)/epub-metadata.yaml \
		--css=$(TEMPLATE_DIR)/epub.css \
		--epub-cover-image=$(COVER_DIR)/ebook-cover.jpg \
		--bibliography=$(SHARED_DIR)/bibliography.yml \
		--citeproc \
		--toc --toc-depth=2 \
		--epub-chapter-level=1 \
		-o $@

# ─── Build: All ───────────────────────────────────────
build: diagrams $(PDF_OUT) $(EPUB_OUT)
	@echo "Build complete: $(PDF_OUT) $(EPUB_OUT)"

# ─── Validate ─────────────────────────────────────────
validate: $(EPUB_OUT)
	epubcheck $<
	@echo "EPUB validation passed."

# ─── Preview ──────────────────────────────────────────
preview: draft
	open $(DIST_DIR)/draft-$(LANG).pdf

# ─── Release ──────────────────────────────────────────
release: build validate
	git tag -a v$(VERSION) -m "Edition $(VERSION)"
	git push origin v$(VERSION)
	gh release create v$(VERSION) $(PDF_OUT) $(EPUB_OUT) \
		--title "Edition $(VERSION)" \
		--notes "Release $(VERSION). See CHANGELOG.md for details."
	@echo "Release v$(VERSION) created."

# ─── Clean ────────────────────────────────────────────
clean:
	rm -rf $(DIST_DIR) $(BUILD_DIR)
```

---

## 8. GitHub Actions CI/CD

### .github/workflows/release.yml

```yaml
name: Build and Release Book

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install Typst
        uses: typst-community/setup-typst@v4

      - name: Install Pandoc
        uses: pandoc/actions/setup@v1

      - name: Install EPUBCheck
        run: |
          wget -q https://github.com/w3c/epubcheck/releases/download/v5.1.0/epubcheck-5.1.0.zip
          unzip -q epubcheck-5.1.0.zip -d /opt/epubcheck

      - name: Build PDF (English)
        run: |
          mkdir -p build dist
          pandoc src/en/*.md -t typst -o build/combined.typ \
            --bibliography=src/shared/bibliography.yml --citeproc
          typst compile main-en.typ dist/philo-sophia-en.pdf

      - name: Build EPUB (English)
        run: |
          pandoc src/en/*.md \
            --metadata-file=templates/epub-metadata.yaml \
            --css=templates/epub.css \
            --epub-cover-image=covers/ebook-cover.jpg \
            --bibliography=src/shared/bibliography.yml \
            --citeproc --toc --toc-depth=2 --epub-chapter-level=1 \
            -o dist/philo-sophia-en.epub

      - name: Validate EPUB
        run: |
          java -jar /opt/epubcheck/epubcheck-5.1.0/epubcheck.jar \
            dist/philo-sophia-en.epub

      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          files: |
            dist/philo-sophia-en.pdf
            dist/philo-sophia-en.epub
          generate_release_notes: true
```

---

## 9. VSCode Configuration

### Recommended Extensions

```json
// .vscode/extensions.json
{
  "recommendations": [
    "yzhang.markdown-all-in-one",
    "streetsidesoftware.code-spell-checker",
    "ms-ceintl.vscode-language-pack-es",
    "nvarner.typst-lsp",
    "myriad-dreamin.tinymist",
    "bierner.markdown-preview-github-styles",
    "ms-vscode.wordcount"
  ]
}
```

### Workspace Settings

```json
// .vscode/settings.json
{
  // Markdown
  "markdown.preview.fontSize": 14,
  "markdown.preview.lineHeight": 1.8,

  // Spell check
  "cSpell.language": "en,es",
  "cSpell.ignorePaths": ["dist/", "build/", "templates/"],

  // Files
  "files.exclude": {
    "dist/": true,
    "build/": true
  },

  // Editor
  "editor.wordWrap": "wordWrapColumn",
  "editor.wordWrapColumn": 80,
  "editor.rulers": [80],
  "[markdown]": {
    "editor.defaultFormatter": "yzhang.markdown-all-in-one",
    "editor.quickSuggestions": false,
    "editor.tabSize": 2
  },

  // Typst
  "[typst]": {
    "editor.defaultFormatter": "nvarner.typst-lsp"
  },

  // Vale
  "vale.valeCLI.path": "/opt/homebrew/bin/vale"
}
```

### Writing Tasks

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Draft",
      "type": "shell",
      "command": "make draft",
      "group": "build",
      "problemMatcher": []
    },
    {
      "label": "Build All",
      "type": "shell",
      "command": "make build",
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": []
    },
    {
      "label": "Word Count",
      "type": "shell",
      "command": "make count",
      "problemMatcher": []
    },
    {
      "label": "Lint Prose",
      "type": "shell",
      "command": "make lint",
      "problemMatcher": []
    },
    {
      "label": "Preview PDF",
      "type": "shell",
      "command": "make preview",
      "problemMatcher": []
    },
    {
      "label": "Validate EPUB",
      "type": "shell",
      "command": "make validate",
      "problemMatcher": []
    }
  ]
}
```

### Keyboard Shortcuts for Writing

Add to `keybindings.json`:

```json
[
  { "key": "cmd+shift+b", "command": "workbench.action.tasks.runTask", "args": "Build Draft" },
  { "key": "cmd+shift+w", "command": "workbench.action.tasks.runTask", "args": "Word Count" },
  { "key": "cmd+shift+l", "command": "workbench.action.tasks.runTask", "args": "Lint Prose" }
]
```

---

## 10. Writing Workflow

### Daily Writing Session

```
1. Open VSCode in book repo
2. Write in src/en/{chapter}.md
3. Cmd+Shift+W → check word count (progress tracking)
4. Cmd+Shift+B → build draft PDF (visual review)
5. Cmd+Shift+L → lint prose (style consistency)
6. git add + git commit (save progress)
```

### Chapter Completion

```
1. make lint          → fix all style issues
2. make build         → full PDF + EPUB build
3. make validate      → EPUB passes EPUBCheck
4. make preview       → visual review of PDF
5. git commit         → "Complete chapter N: {title}"
```

### Edition Release

```
1. Update CHANGELOG.md with edition notes
2. make build validate   → clean build
3. make release VERSION=1.0.0
   → tags v1.0.0
   → pushes tag
   → GitHub Actions builds + creates release with artifacts
4. Download PDF + EPUB from GitHub release
5. Upload to KDP (Kindle: EPUB, Print: PDF)
6. Upload to IngramSpark (PDF) if using wide distribution
```

---

## 11. KDP Upload Checklist

### Kindle eBook

- [ ] EPUB passes EPUBCheck with zero errors
- [ ] Cover image: 2,560 × 1,600 px, JPEG, RGB, 300 DPI
- [ ] Preview in Kindle Previewer (download from KDP)
- [ ] TOC navigates correctly
- [ ] Images display properly at different screen sizes
- [ ] Price set between $2.99–$9.99 for 70% royalty
- [ ] eBook price is 20%+ cheaper than print price

### Paperback

- [ ] Interior PDF: pages are 6.125" × 9.25" (with bleed)
- [ ] All images 300 DPI minimum (`make images-check`)
- [ ] Fonts embedded in PDF
- [ ] No content in bleed zone (0.125" from edge) except intentional full-bleed images
- [ ] Gutter margin sufficient for page count
- [ ] Cover PDF: dimensions match KDP calculator for your page count
- [ ] Cover spine text centered and legible
- [ ] Cover barcode area clear (back cover, bottom-right)
- [ ] Review printed proof before approving

### Hardcover

- [ ] All paperback checks above
- [ ] Page count between 75–550
- [ ] Cover wrap dimensions include 0.59" wrap on all sides
- [ ] Spine hinge (0.4" each side) is clear of text/images
- [ ] Lamination selected (glossy or matte)
- [ ] Review printed proof before approving

---

## 12. Vale Configuration

### .vale.ini

```ini
StylesPath = .vale/styles

MinAlertLevel = suggestion

Packages = proselint, write-good

[src/en/*.md]
BasedOnStyles = Vale, proselint, write-good

# Book-specific rules
Vale.Repetition = YES
Vale.Spelling = YES

# Disable rules that conflict with book writing
write-good.Passive = suggestion    # Allow some passive voice
write-good.Weasel = suggestion     # Flag but don't block
write-good.TooWordy = warning

[src/es/*.md]
BasedOnStyles = Vale
# Spanish-specific rules TBD
```

---

## 13. Bibliography Management

### Hayagriva Format (bibliography.yml)

```yaml
# Preferred format for Typst — cleaner than BibTeX

aristotle-organon:
  type: book
  title: "The Organon"
  author: Aristotle
  date: -350
  note: "Collected works on logic"

hopcroft-2006:
  type: book
  title: "Introduction to Automata Theory, Languages, and Computation"
  author:
    - Hopcroft, John E.
    - Motwani, Rajeev
    - Ullman, Jeffrey D.
  date: 2006
  edition: 3
  publisher: Pearson/Addison-Wesley
  isbn: 978-0-321-45536-9

taleb-2012:
  type: book
  title: "Antifragile: Things That Gain from Disorder"
  author: "Taleb, Nassim Nicholas"
  date: 2012
  publisher: Random House
  isbn: 978-0-812-97968-8

wittgenstein-1953:
  type: book
  title: "Philosophical Investigations"
  author: "Wittgenstein, Ludwig"
  date: 1953
  publisher: Blackwell
  translator: "Anscombe, G. E. M."
```

### Citing in Markdown

In markdown source files, use Pandoc citation syntax:

```markdown
As Wittgenstein argued, meaning is use in context [@wittgenstein-1953].

The formal model draws on automata theory [@hopcroft-2006, ch. 2].
```

---

## 14. Scaling to Multiple Books

This pipeline is designed to be reusable. To start a new book:

```bash
# Option A: Template repository
gh repo create my-new-book --template=cacsidev/book-pipeline

# Option B: Manual setup
mkdir my-new-book && cd my-new-book
cp -r ~/book-pipeline/{Makefile,templates/,.vale/,.vscode/,.github/} .
mkdir -p src/{en,es,shared/{images,diagrams}} covers dist
git init
```

Customize per book:
1. Edit `BOOK_SLUG` in Makefile
2. Edit `epub-metadata.yaml` with new book details
3. Adjust `main-en.typ` chapter includes
4. Add book-specific Vale rules if needed

Everything else — build system, CI/CD, KDP specs, validation — is identical across all books.
