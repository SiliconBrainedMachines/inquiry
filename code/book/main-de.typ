// main-de.typ — Entry point for German edition
// Build: typst compile main-de.typ dist/critique-of-pure-abduction-de.pdf

#import "templates/book-print.typ": *

// Override language
#set text(lang: "de")

// ─── Front Matter ────────────────────────────────────
#set page(numbering: "i")

#include "build/combined-de.typ"