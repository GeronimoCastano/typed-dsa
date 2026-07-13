// typst compile --root . --ppi 300 assets/readme/bubble-sort.typ assets/readme/bubble-sort.png
#import "../../src/lib.typ": *
#import "@preview/algo:0.3.6": algo, i, d

#set page(width: 760pt, height: auto, margin: 14pt)
#set text(font: "New Computer Modern", size: 10pt)

#let steps = bubble-sort((3, 1, 2), pointers: true).steps

#let pseudocode = algo(
  title: "Bubble sort",
  line-numbers: true,
  indent-size: 10pt,
  row-gutter: 8pt,
  column-gutter: 9pt,
  inset: 6pt,
  fill: luma(248),
  stroke: 1.4pt + luma(225),
  radius: 4pt,
  main-text-styles: (size: 10pt),
  line-number-styles: (size: 6pt, fill: rgb("#607D8B")),
)[
  for $p <- 0$ to $n - 2$:#i\
  for $j <- 0$ to $n - p - 2$:#i\
  if $A_j > A_(j + 1)$:#i\
  swap $A_j$ and $A_(j + 1)$#d#d#d
]

#let trace = grid(
  columns: 2,
  column-gutter: 8pt,
  row-gutter: 1.6em,
  ..steps.enumerate().map(((index, step)) => align(center)[
    #text(size: 6.5pt, fill: rgb("#607D8B"), weight: "bold")[Step #(index + 1)]
    #v(0.12em)
    #scale(78%, reflow: true, step.diagram)
  ]),
)

#block(
  width: 100%,
  fill: white,
  stroke: 0.6pt + luma(220),
  radius: 7pt,
  inset: 12pt,
)[
  #text(size: 15pt, weight: "bold", fill: rgb("#1565C0"))[Bubble sort]
  #v(0.65em)
  #grid(
    columns: (0.34fr, 0.66fr),
    column-gutter: 12pt,
    align: horizon,
    align(center + horizon, pseudocode),
    align(center + horizon, trace),
  )
]
