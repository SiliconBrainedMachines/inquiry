# Philo SophIA — Book Source

This directory contains the source code for the book **Philo SophIA: The Thinking Tools Humanity Built**.

The book is now part of Inquiry and lives in `code/book/` as the product's canonical long-form doctrinal manuscript. Supporting research and working notes live under `docs/research/book/` and `docs/research/inquiry/`.

## Quick Start

1. Open this folder in VS Code
2. On Windows, run `./scripts/build.ps1 -Format epub -Lang en` for the native wrapper build
3. On environments with Typst and a POSIX shell, run `make draft LANG=en` to build a preview PDF
4. Run `make build LANG=en` to build PDF + EPUB where the full toolchain is available

## Commands

| Command | Action |
|---------|--------|
| `./scripts/build.ps1 -Format epub -Lang en` | Windows-native EPUB build |
| `./scripts/build.ps1 -Format all -Lang en` | Windows wrapper: EPUB plus PDF when `typst` exists |
| `make draft` | Quick PDF build for preview |
| `make build` | Full build: PDF + EPUB |
| `make count` | Word count per chapter |
| `make lint` | Lint prose with Vale |
| `make preview` | Build draft and open PDF |
| `make clean` | Remove build artifacts |
| `make release VERSION=x.y.z` | Tag, push, create GitHub release |

## Languages

Build a specific language with `LANG`:

```bash
make draft LANG=en    # English (default)
make draft LANG=es    # Spanish
```

## Structure

```
src/en/          English source (primary)
src/es/          Spanish source
src/shared/      Images, diagrams, bibliography
templates/       Typst + EPUB templates
covers/          Cover images for all formats
dist/            Build output (gitignored)
```
