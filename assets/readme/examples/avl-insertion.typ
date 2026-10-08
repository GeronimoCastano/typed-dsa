// typst compile --root . --ppi 300 assets/readme/examples/avl-insertion.typ assets/readme/examples/avl-insertion.png
#import "../../../src/lib.typ": *

#set page(width: 18cm, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#let indigo = rgb("#3F3D8F")

#let avl-style = tree-style(
  node-fill: rgb("#EEEBFA"),
  node-stroke: 0.8pt + indigo,
  edge-stroke: 0.7pt + indigo,
  node-text: (size: 10pt, fill: rgb("#2B2A66"), weight: "bold"),
  path-style: rgb("#DCD6F7"),
  new-style: (fill: rgb("#FFD9C7"), stroke: 1pt + rgb("#D9480F")),
  rotate-style: (fill: rgb("#FFE9A6"), stroke: 1pt + rgb("#C58B00")),
  scale: 0.9,
  tree-layout: "tidy",
  x-gap: 0.85,
)

#let rebalance-view = (enabled: true, all-steps: true)

// A single rotation: inserting 50 makes 30 right-heavy by two.
#let single-rotation = (avl(20, 10, 30, 40, style: avl-style).insert)(50, rebalance: rebalance-view)
// Left-right double rotation: 25 lands in 40's left subtree, under 20's right child.
#let double-rotation = ((single-rotation.result).insert)(25, rebalance: rebalance-view)

#block(width: 100%, fill: white, stroke: 0.6pt + luma(215), radius: 8pt, inset: 18pt, {
  align(center, std.stack(
    spacing: 1.65em,
    align(center, single-rotation.diagram),
    align(center, double-rotation.diagram),
  ))
})
