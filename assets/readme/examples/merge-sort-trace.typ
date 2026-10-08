// typst compile --root . --ppi 300 assets/readme/examples/merge-sort-trace.typ assets/readme/examples/merge-sort-trace.png
#import "../../../src/lib.typ": *

#set page(width: 18cm, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#let sage = rgb("#4F7A62")
#let sage-tint = rgb("#E4EFE7")
#let sage-deep = rgb("#2D4A3A")

#let sage-array-style = array-style(
  box-fill: sage-tint,
  box-stroke: 0.8pt + sage,
  box-shape: "rounded",
  box-h: 0.6,
  node-text: (size: 10pt, weight: "bold", fill: sage-deep),
  indices: indices-style(enabled: false),
  label-text: (fill: sage-deep),
  algorithm-label-text: (fill: sage-deep),
)

#let merge-trace = merge-sort(array-view(
  38, 27, 43, 3, 9, 82, 10,
  style: sage-array-style,
))

#block(width: 100%, fill: white, stroke: 0.6pt + luma(215), radius: 8pt, inset: 18pt,
  align(center, merge-trace.diagram))
