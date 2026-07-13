#import "@preview/touying:0.7.3": *
#import themes.simple: *
#import "../src/lib.typ": *

#show: simple-theme.with(aspect-ratio: "16-9")

#set text(font: "New Computer Modern", size: 20pt)

#let colors = (
  node-fill: rgb("#dbeafe"),
  new-style: node-mark-style(fill: rgb("#bbf7d0")),
  path-style: node-mark-style(fill: rgb("#fde68a")),
  label-text: label-style(size: 11pt),
)

#let figure(body) = align(center, box(width: 92%, body))

= typed-dsa + Touying

Declarative data-structure diagrams directly inside presentation slides.

== Same source, presentation-ready output

#figure[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5cm,
    [
      #text(weight: "bold")[Typst source]

      ```typst
      #bst(8, 3, 10, 1, 6).diagram
      ```

      Keep examples editable in the same file as the slides.
    ],
    [
      #text(weight: "bold")[Rendered diagram]

      #bst(8, 3, 10, 1, 6, style: colors).diagram
    ],
  )
]

== Explain operations step by step

#let s0 = bst(8, 3, 10, 1, 6, style: colors)
#let s1 = (s0.insert)(7, step-label: [insert 7])

#figure[
  #sequence(s0, s1, mode: "after", columns: 3, gap: 1.4em)
]

#pause

The operation label, before/after state, and highlighted node are generated
from the structure operation.

== Linear structures fit lecture examples

#let demo-stack = stack(
  9, 7, 2,
  top-label: [Top],
  style: stack-style(
    box-fill: rgb("#f8fafc"),
    new-style: cell-mark-style(fill: rgb("#fecaca")),
  ),
)

#figure[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1.3cm,
    [
      #text(weight: "bold")[Stack]

      #((demo-stack.push)(4)).diagram
    ],
    [
      #text(weight: "bold")[Queue]

      #queue(
        42,
        style: queue-style(label-text: label-style(size: 10pt)),
      ).diagram
    ],
  )
]

== Animated reveal works normally

#figure[
  #min-heap(4, 9, 7, 12, style: colors).diagram
]

#pause

#figure[
  #((min-heap(4, 9, 7, 12, style: colors).extract)()).diagram
]

Use Touying reveals for the teaching flow; typed-dsa only handles the diagram.

== Bubble sort, one step per reveal

#let bubble-trace = bubble-sort((5, 1, 4, 2))

#for (i, step) in bubble-trace.steps.enumerate(){
  only(i + 1)[#step.diagram]
}
