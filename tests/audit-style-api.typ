#import "../src/lib.typ": *

#set page(width: 21cm, height: auto, margin: 1.2cm)
#set text(font: "New Computer Modern", size: 11pt)

= Shared style and API audit

== Dark themes keep marked values readable

#block(fill: rgb("#15181E"), inset: 1em)[
  #set text(fill: white)
  *Dark preset*
  #transition("bst", (50, 30, 70, 20, 40), tree-insert(45), style: theme-preset("dark"))
]

#block(fill: white, inset: 1em)[
  #set text(fill: black)
  *Chalkboard preset*
  #transition("avl", (20, 10, 30, 40), tree-insert(50), style: theme-preset("chalkboard"))
]

#block(fill: rgb("#15181E"), inset: 1em)[
  #set text(fill: white)
  #grid(
    columns: 2,
    column-gutter: 1.6em,
    [*label-text: (fill: red)*\ #linked-list(1, 2, head: true, style: theme-preset("dark") + (label-text: (fill: red))).diagram],
    [*label-text: (color: red)*\ #linked-list(1, 2, head: true, style: theme-preset("dark") + (label-text: (color: red))).diagram],
  )
]

#pagebreak()

== Edge overrides preserve stroke width

#bst(
  5, 3, 7,
  edge-customizations: (
    (5, 3, (color: red, pattern: "dashed")),
    (5, 7, (stroke: 0.6pt + rgb("#333333"))),
  ),
).diagram

#v(1em)
#text(size: 9pt)[The red dashed edge uses the same base thickness as the neighboring edge.]

#pagebreak()

== Queue results and explicit skip-list levels

#let staged-queue = queue(3, 8, enqueue: 6, dequeue: 2)
#grid(
  columns: 2,
  column-gutter: 1.6em,
  align: top,
  [*Builder frame*\ #staged-queue.diagram],
  [*Chained result*\ #(staged-queue.enqueue)(9).result.diagram],
)

#v(1.2em)
#(skip-list(1, 2, 3, max-level: 2).insert)(4, level: 3).diagram

#pagebreak()

== Linear highlight strokes follow box styling

#(linked-list(3, 1, 7, style: (box-stroke: 2pt + blue)).search)(4).after

#pagebreak()
== Cell stripes and gradient marks
#grid(columns: 2, column-gutter: 2em,
  (stack(1, 2, style: (box-shape: "capsule", new-style: (fill: white, stripe-fill: rgb("#C4B5FD")))).push)(3).after,
  (stack(1, 2, style: (new-style: gradient.linear(red, blue))).push)(3).after,
)
