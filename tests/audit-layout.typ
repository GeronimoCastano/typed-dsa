#import "../src/lib.typ": *

#set page(width: 17cm, height: auto, margin: 10pt)
#set text(size: 10pt)

= Layout regression evidence

== D45: lone children stay symmetric and tidy contours keep their margin

#grid(
  columns: 2,
  column-gutter: 2em,
  [*Only a left branch*\
  #tree(
    node("P", left: node("R", left: subtree("T", scale: 1.5))),
    style: (tree-layout: "columns", tri-w: 1.2),
  )],
  [*Only a right branch*\
  #tree(
    node("P", right: node("R", right: subtree("T", scale: 1.5))),
    style: (tree-layout: "columns", tri-w: 1.2),
  )],
)

#v(1em)

Tidy placement keeps all four elided subtree triangles separated across both
child contours:

#align(center)[
  #tree(
    node(
      "R",
      left: node("L", left: subtree("A", scale: 1.8), right: subtree("B", scale: 1.2)),
      right: node("S", left: subtree("C", scale: 1.2), right: subtree("D", scale: 1.8)),
    ),
    style: (tree-layout: "tidy", tri-w: 1.4, tri-h: 1.2, node-radius: 0.3),
  )
]

#pagebreak()

== D11: positive x-gap preserves clearance around enlarged nodes

The manual tree uses the audited node arrangement and spacing request.

#align(center)[
  #tree(
    node(1, left: node(2), right: node(3, left: node(4), right: node(5))),
    style: (node-radius: 1, x-gap: 1),
  )
]

#pagebreak()

== D17: automatic routing keeps wavy reciprocal edges bent

#grid(
  columns: 2,
  column-gutter: 2em,
  [*One explicit side; reciprocal edge automatic*\
  #graph(
    ("A": (("B", [A to B]),), "B": (("A", [B to A]),)),
    layout: "manual",
    positions: ("A": (0, 0), "B": (3, 0)),
    edge-routing: "auto",
    style: (edge-pattern: "wavy"),
    edge-customizations: (("A", "B", (bend: "right")),),
  ).diagram],
  [*Boolean bend with a negative angle*\
  #graph(
    ("A": (("B", [bent]),), "B": ()),
    layout: "manual",
    positions: ("A": (0, 0), "B": (3, 0)),
    edge-routing: "auto",
    style: (edge-pattern: "wavy"),
    edge-customizations: (("A", "B", (bend: true, angle: -15deg)),),
  ).diagram],
)

#pagebreak()

== D46: fit all four AVL rebalance panels to the page width

#align(center)[
  #fit-to-width(transition(
    "avl", (50, 30, 70, 20, 40),
    tree-insert(35, rebalance: (enabled: true, all-steps: true)),
  ))
]
