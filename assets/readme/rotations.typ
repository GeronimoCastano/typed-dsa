// typst compile --root . --ppi 300 assets/readme/rotations.typ assets/readme/rotations.png
#import "../../src/lib.typ": *

#set page(width: 620pt, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 12pt)

#let blue = rgb("#1E73BE")
#let purple = rgb("#7B3FA1")
#let green = rgb("#2E7D32")
#let rust = rgb("#C75B12")
#let red = rgb("#B71C1C")

#let rot-style = (
  node-radius: 0.3,
  x-gap: 1.05,
  y-gap: 1.0,
  node-fill: white,
  node-stroke: 0.8pt + rgb("#222222"),
  node-text: (size: 11pt, weight: "bold"),
  edge-stroke: 0.8pt + rgb("#111111"),
  tri-w: 1.1,
  tri-h: 1.2,
  scale: 1.15,
)

#let ta = subtree($T_A$, fill: blue, scale: 1.02)
#let tb = subtree($T_B$, fill: purple)
#let tc = subtree($T_C$, fill: green)

#let before = tree(
  node(
    text(fill: rust)[$x$],
    left: node(text(fill: red)[$y$], left: ta, right: tb),
    right: tc,
  ),
  style: rot-style,
)

#let after = tree(
  node(
    text(fill: red)[$y$],
    left: ta,
    right: node(text(fill: rust)[$x$], left: tb, right: tc),
  ),
  style: rot-style,
)

#block(width: 100%, fill: white, stroke: 0.6pt + luma(215), radius: 8pt, inset: 20pt, {
  align(center)[
    #std.stack(dir: ltr, spacing: 1.6em,
      align(horizon, before),
      align(horizon, std.stack(spacing: 0.55em,
        text(size: 12pt, weight: "bold")[rotate $x$ right],
        text(size: 24pt)[$arrow.r.long$],
        text(size: 24pt)[$arrow.l.long$],
        text(size: 12pt, weight: "bold")[rotate $y$ left],
      )),
      align(horizon, after),
    )
  ]
})
