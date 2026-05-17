# ─── Configuration ────────────────────────────────────
BOOK_SLUG    := philo-sophia
LANG         ?= en
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

PDF_OUT      := $(DIST_DIR)/$(BOOK_SLUG)-$(LANG).pdf
EPUB_OUT     := $(DIST_DIR)/$(BOOK_SLUG)-$(LANG).epub

# ─── Default ──────────────────────────────────────────
.PHONY: all clean lint count draft build validate preview release help

all: build

help:
	@echo "Usage:"
	@echo "  make draft            Quick PDF build (no optimization)"
	@echo "  make build            Full build: PDF + EPUB"
	@echo "  make lint             Lint prose with Vale"
	@echo "  make count            Word count per chapter"
	@echo "  make preview          Build draft and open PDF"
	@echo "  make images-check     Verify all images are 300+ DPI"
	@echo "  make release          Tag, push, and create GitHub release"
	@echo "  make clean            Remove build artifacts"
	@echo ""
	@echo "Set language: LANG=es make build"

# ─── Directories ──────────────────────────────────────
$(DIST_DIR):
	mkdir -p $@

# ─── Prose Quality ────────────────────────────────────
lint:
	vale $(SRC_DIR)/*.md

count:
	@echo "──────────────────────────────────"
	@echo "Word count per chapter ($(LANG)):"
	@echo "──────────────────────────────────"
	@for f in $(SRC_FILES); do \
		printf "%-40s %s\n" "$$(basename $$f)" "$$(wc -w < $$f)"; \
	done
	@echo "──────────────────────────────────"
	@printf "%-40s %s\n" "TOTAL" "$$(cat $(SRC_FILES) | wc -w)"

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
$(BUILD_DIR)/combined-$(LANG).typ: $(SRC_FILES)
	@mkdir -p $(BUILD_DIR)
	pandoc $(SRC_FILES) -t typst -o $@.tmp
	cat $(TEMPLATE_DIR)/pandoc-typst-header.typ $@.tmp > $@
	rm $@.tmp

# ─── Build: PDF (print-ready) ────────────────────────
$(PDF_OUT): $(BUILD_DIR)/combined-$(LANG).typ | $(DIST_DIR)
	typst compile main-$(LANG).typ $@

draft:
	@mkdir -p $(BUILD_DIR) $(DIST_DIR)
	pandoc $(SRC_FILES) -t typst -o $(BUILD_DIR)/combined-$(LANG).typ.tmp
	cat $(TEMPLATE_DIR)/pandoc-typst-header.typ $(BUILD_DIR)/combined-$(LANG).typ.tmp > $(BUILD_DIR)/combined-$(LANG).typ
	rm $(BUILD_DIR)/combined-$(LANG).typ.tmp
	typst compile main-$(LANG).typ $(DIST_DIR)/draft-$(LANG).pdf

# ─── Build: EPUB ──────────────────────────────────────
$(EPUB_OUT): $(SRC_FILES) | $(DIST_DIR)
	pandoc $(SRC_FILES) \
		--metadata-file=$(TEMPLATE_DIR)/epub-metadata-$(LANG).yaml \
		--css=$(TEMPLATE_DIR)/epub.css \
		--toc --toc-depth=2 \
		--split-level=1 \
		-o $@

# ─── Build: All ───────────────────────────────────────
build: $(PDF_OUT) $(EPUB_OUT)
	@echo "Build complete: $(PDF_OUT) $(EPUB_OUT)"

# ─── Preview ──────────────────────────────────────────
preview: draft
	@echo "Draft PDF: $(DIST_DIR)/draft-$(LANG).pdf"

# ─── Release ──────────────────────────────────────────
release: build
	git tag -a v$(VERSION) -m "Edition $(VERSION)"
	git push origin v$(VERSION)
	gh release create v$(VERSION) $(PDF_OUT) $(EPUB_OUT) \
		--title "Edition $(VERSION)" \
		--notes "Release $(VERSION). See CHANGELOG.md for details."
	@echo "Release v$(VERSION) created."

# ─── Clean ────────────────────────────────────────────
clean:
	rm -rf $(DIST_DIR) $(BUILD_DIR)
