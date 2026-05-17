// main-es.typ — Entry point for Spanish edition
// Build: typst compile main-es.typ dist/philo-sophia-es.pdf

#import "templates/book-print.typ": *

// Override language
#set text(lang: "es")

// ─── Front Matter ────────────────────────────────────
#set page(numbering: "i")

#include "build/combined-es.typ"
