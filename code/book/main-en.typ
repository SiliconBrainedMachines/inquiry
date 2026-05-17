// main-en.typ — Entry point for English edition
// Build: typst compile main-en.typ dist/philo-sophia-en.pdf

#import "templates/book-print.typ": *

// ─── Front Matter ────────────────────────────────────
#set page(numbering: "i")

#include "build/combined-en.typ"
