// typst compile --root . --ppi 300 assets/readme/styling.typ assets/readme/styling.png
#import "../../src/lib.typ": *
#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#table(
  columns: (auto, auto),
  column-gutter: 2.5em,
  align: center + horizon,
  stroke: none,
  [*Per-call styling*], [*Hand-composed tree with subtree triangles*],
  bst(50, 30, 70, 20, 40, style: (
    node-shape: "square", node-radius: 0.4,
    node-fill: rgb("#E3F2FD"), node-stroke: 1pt + rgb("#1565C0"),
  )).diagram,
  tree(
    node(
      text(fill: rgb("#C75B12"))[$v$],
      left: subtree($T_ell$, fill: rgb("#1F6FBF"), height: $h_ell$),
      right: subtree($T_r$, fill: rgb("#8E44AD"), height: $h_r$),
    ),
    style: (edge-arrow: true),
  ),
)
