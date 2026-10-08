// typst compile --root . --ppi 300 assets/readme/examples/dijkstra-city-map.typ assets/readme/examples/dijkstra-city-map.png
#import "../../../src/lib.typ": *

#set page(width: 17cm, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#let teal = rgb("#0F4C5C")
#let slate = rgb("#5C6B73")
#let amber = rgb("#E8A33D")

#let trace = dijkstra(
  (
    "H": (("P", 2), ("M", 4), ("T", 9)),
    "P": (("M", 1), ("S", 6)),
    "M": (("S", 3), ("U", 5)),
    "S": (("C", 5),),
    "U": (("C", 2), ("T", 3)),
    "T": (),
    "C": (),
  ),
  "H",
  target: "C",
  directed: false,
  captions: false,
  layout: "manual",
  labels: (
    "H": [Harbor], "P": [Park], "M": [Market], "S": [Station],
    "U": [Campus], "T": [Tower], "C": [Castle],
  ),
  positions: (
    "H": (0, 0), "P": (2.6, 2.0), "M": (5.2, 0.2), "S": (8.8, 2.0),
    "U": (7.6, -1.2), "T": (3.6, -2.6), "C": (11.6, 0.0),
  ),
  style: graph-style(
    node-shape: "capsule", node-radius: 0.52, scale: 1,
    node-fill: rgb("#E3F1F0"), node-stroke: 0.9pt + teal,
    edge-stroke: 0.7pt + slate,
    node-text: (size: 9.5pt, fill: rgb("#0F3B47")),
    edge-label-text: (fill: slate),
    visited-style: (fill: rgb("#D3E9E7"), stroke: 0.9pt + teal),
    queued-style: (fill: white, stroke: 0.9pt + rgb("#8A9BA3")),
    active-edge-style: (stroke: 2.6pt + amber),
    node-labels: node-label-style(position: "bottom", gap: 0.3),
  ),
  node-labels: ("H", "P", "M", "S", "U", "T", "C").map(node-id => (node-id, (color: teal))),
)

#block(width: 100%, fill: white, stroke: 0.6pt + luma(215), radius: 8pt, inset: 18pt,
  align(center, (trace.steps.last()).diagram))
