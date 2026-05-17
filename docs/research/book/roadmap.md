# Roadmap — Philo SophIA

**Last updated:** 2026-04-03

---

## Current State (v0.0.1)

### Infrastructure: Done

| Component | Status | Notes |
|-----------|--------|-------|
| Dev container | ✅ Working | Typst 0.13.1, Pandoc 3.6.4, Vale 3.9.5, gh CLI |
| Makefile | ✅ Working | `draft`, `build`, `lint`, `count`, `release` targets |
| PDF pipeline | ✅ Working | Markdown → Pandoc → Typst → PDF (6"×9" KDP) |
| EPUB pipeline | ✅ Working | Markdown → Pandoc → EPUB 3 |
| Typst template | ✅ Working | Print-ready 6.25"×9.25" with bleed |
| EPUB stylesheet | ✅ Working | Georgia serif, proper heading hierarchy |
| Vale linting | ✅ Configured | proselint + write-good (EN), Vale base (ES) |
| CI/CD | ⬜ Not tested | GitHub Actions release.yml exists, needs first tag |
| Bibliography | ✅ Started | ~24 Hayagriva entries |

### Content: Early Draft

| Chapter (EN) | Words | Status |
|---|---:|---|
| 00 Front Matter | 48 | ✅ Title, subtitle, epigraph |
| 01 Prologue | 648 | ✅ Draft complete |
| 02 Language | 83 | ⬜ Outline only |
| 03 Knowledge | 80 | ⬜ Outline only |
| 04 Mind | 69 | ⬜ Outline only |
| 05 Reason | 97 | ⬜ Outline only |
| 06 Ethics | 77 | ⬜ Outline only |
| 07 Learning | 70 | ⬜ Outline only |
| 08 Truth | 82 | ⬜ Outline only |
| 09 Freedom | 79 | ⬜ Outline only |
| 10 Beauty | 75 | ⬜ Outline only |
| 11 Wisdom | 114 | ⬜ Outline only |
| 99 Back Matter | 17 | ⬜ Placeholder |
| **TOTAL EN** | **1,539** | |
| **TOTAL ES** | **1,670** | Parallel structure, same status |

### Assets: Missing

| Asset | Status | Needed for |
|-------|--------|------------|
| eBook cover (2560×1600 JPG) | ❌ Missing | Kindle eBook, EPUB |
| Paperback cover PDF | ❌ Missing | KDP paperback |
| Interior images | ❌ None yet | Content (optional) |
| ISBN | ❌ Not purchased | IngramSpark (optional for KDP) |

---

## Milestones

### M1 — Minimum Viable Book (target: TBD)

- [ ] Write all 10 chapters (target: ~5,000–8,000 words each → 50,000–80,000 total)
- [ ] Complete front matter and back matter
- [ ] Create eBook cover image
- [ ] First full proofread pass
- [ ] Build and validate EPUB (EPUBCheck)
- [ ] Build print-ready PDF

### M2 — Kindle Publication

- [ ] Upload EPUB to KDP for Kindle eBook
- [ ] Set pricing ($2.99–$9.99 for 70% royalty)
- [ ] Preview in Kindle Previewer
- [ ] Publish

### M3 — Paperback Publication

- [ ] Create full paperback cover (front + spine + back)
- [ ] Verify all images ≥ 300 DPI
- [ ] Upload PDF to KDP for paperback
- [ ] Order and review printed proof
- [ ] Publish

### M4 — Spanish Edition

- [ ] Write all ES chapters (original composition, not translation)
- [ ] Create ES-specific cover if needed
- [ ] Build and validate ES EPUB + PDF
- [ ] Publish ES Kindle + paperback

### M5 — Wide Distribution (optional)

- [ ] Purchase ISBNs (Bowker)
- [ ] Upload to IngramSpark for bookstores/libraries
- [ ] Hardcover edition