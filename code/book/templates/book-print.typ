// book-print.typ — Print-ready template for 6"×9" books
// Compatible with Amazon KDP paperback and hardcover

// ─── Page Setup ──────────────────────────────────────
#set page(
  width: 6.25in,
  height: 9.25in,
  margin: (top: 0.5in, bottom: 0.5in, outside: 0.5in, inside: 0.75in),
  header: context {
    let page-num = counter(page).get().first()
    if page-num > 1 {
      set text(size: 9pt, style: "italic")
      if calc.rem(page-num, 2) == 0 {
        [Critique of Pure Abduction]
      } else {
        // Chapter title would go here via state
      }
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
  font: "Libertinus Serif",
  size: 11pt,
  lang: "en",
)

#set par(
  justify: true,
  first-line-indent: 1.5em,
  leading: 0.65em,
)

// ─── Headings ────────────────────────────────────────
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(2in)
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

// ─── Horizontal Rules (Pandoc generates #horizontalrule) ─
#let horizontalrule = line(length: 100%, stroke: 0.5pt + luma(180))

// ─── Figures ─────────────────────────────────────────
#show figure.caption: set text(size: 9pt, style: "italic")
