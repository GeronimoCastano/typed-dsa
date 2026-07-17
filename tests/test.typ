#import "../src/lib.typ": *

#set page(paper: "a4", margin: 1.2cm)
#set text(font: "New Computer Modern", size: 11pt)

#let section(title, body) = {
  block(below: 1.2em)[
    #strong(title)
    #v(0.4em)
    #body
  ]
}

= typed-dsa visual test

#section("Binary search tree", bst(50, 30, 70, 20, 40, 60, 80).diagram)

#section("AVL tree (balanced on build)", avl(10, 20, 30, 40, 50, 25).diagram)

#section("BST insert (search path → new node)", transition("bst", (50, 30, 70, 20, 40), tree-insert(45)))

#section("BST delete (two-child node)", transition("bst", (50, 30, 70, 20, 40, 60, 80), tree-delete(30)))

#section("BST search (traversal path)", transition("bst", (50, 30, 70, 20, 40, 60, 80), tree-search(40)))

#section("AVL insert with rotation (green = new, blue = rotation schematic parts)", transition(
  "avl",
  (20, 10, 30, 40),
  tree-insert(50),
))

#section("AVL single rotation, rebalance: (enabled: true): rotation schematic parts marked", transition(
  "avl",
  (20, 10, 30, 40),
  tree-insert(50, rebalance: (enabled: true)),
))

#section("AVL insert, rebalance: (enabled: true) but no rotation fires (stays 2 panels)", transition(
  "avl",
  (50, 30, 70),
  tree-insert(40, rebalance: (enabled: true)),
))

#section("AVL double rotation (LR), all-steps: true: before -> unrotated -> after-inner -> after-outer", transition(
  "avl",
  (30, 10),
  tree-insert(20, rebalance: (enabled: true, all-steps: true)),
))

#section(
  "AVL double rotation (LR) collapsed (all-steps: false): broken + final only, both rotation events marked",
  transition("avl", (30, 10), tree-insert(20, rebalance: (enabled: true))),
)

#section("AVL delete with rebalance (red = removed, blue = rotation nodes)", transition(
  "avl",
  (30, 20, 40, 10, 25),
  tree-delete(40),
))

#section("Min-heap and max-heap (array-backed complete binary tree)", std.stack(
  dir: ltr,
  spacing: 1.5em,
  min-heap(50, 30, 70, 20, 40, 60, 80).diagram,
  max-heap(50, 30, 70, 20, 40, 60, 80).diagram,
))

#section("Min-heap insert (new value green, sift-up path yellow)", transition("min-heap", (10, 20, 15, 40, 50, 30), heap-insert(5)))

#section("Max-heap extract (root removed in red, sift-down path in yellow)", transition(
  "max-heap",
  (50, 30, 70, 20, 40, 60, 80),
  heap-extract,
))

#section("Heap object: step.diagram, then chained op on step.result", {
  let h = min-heap(10, 20, 15, 40, 50, 30)
  let step = (h.insert)(5)
  std.stack(spacing: 1em, step.diagram, ((step.result).extract)().diagram)
})

#section("Unified tree object: step.diagram, then chained op on step.result", {
  let b = bst(50, 30, 70, 20, 40)
  let step = (b.insert)(45)
  std.stack(spacing: 1em, step.diagram, ((step.result).delete)(30).diagram)
})

#section("Tree object step composed manually (custom arrow)", {
  let step = (bst(50, 30, 70, 20, 40).insert)(45)
  std.stack(dir: ltr, spacing: 1.2em, align(horizon, step.before), op-arrow[custom label], align(horizon, step.after))
})

#section(
  "Styling: square nodes, custom colors, larger",
  bst(50, 30, 70, 20, style: (
    node-shape: "square",
    node-radius: 0.4,
    node-fill: rgb("#fd9ddb"),
    node-stroke: 1pt + rgb("#70255d"),
    node-text: (size: 11pt),
  )).diagram,
)

#section("Styling persists through .result: square style stays square across a chained insert then delete", {
  let sq = (
    node-shape: "square",
    node-radius: 0.4,
    node-fill: rgb("#E3F2FD"),
    node-stroke: 1pt + rgb("#1565C0"),
    node-text: (size: 11pt),
  )
  let b = bst(50, 30, 70, 20, style: sq)
  let step = (b.insert)(45)
  std.stack(spacing: 1em, step.diagram, ((step.result).delete)(30).diagram)
})

#section("new-style/path-style/rotate-style as dicts: shape + stroke override, color still distinct by default", {
  let custom = (
    // new node: square instead of circle, thicker stroke, default green fill kept (not specified)
    new-style: (shape: "square", stroke: 2pt + rgb("#2E7D32")),
    // search path: just a heavier stroke, default circle/yellow kept
    path-style: (stroke: 1.5pt + rgb("#F9A825")),
    // rotation schematic parts: bigger radius, still default blue fill
    rotate-style: (node-radius: 0.45),
  )
  std.stack(spacing: 1em, transition("bst", (50, 30, 70, 20, 40), tree-insert(45), style: custom), transition(
    "avl",
    (20, 10, 30, 40),
    tree-insert(50),
    style: custom,
  ))
})

#section("remove-style as a plain color still works (shorthand for fill:)", transition(
  "bst",
  (50, 30, 70, 20, 40, 60, 80),
  tree-delete(30),
  style: (remove-style: blue),
))

#section("diff-colors: false removes highlight fills but keeps shape and stroke overrides", transition(
  "bst",
  (50, 30, 70, 20, 40),
  tree-insert(45),
  style: (
    diff-colors: false,
    new-style: (shape: "square", stroke: 1.5pt + black),
    path-style: (stroke: 1.5pt + black),
  ),
))

#section("style: (scale:) shrinks and grows the whole diagram, .diagram/.before/.after alike", {
  let step = (bst(50, 30, 70, 20, style: (scale: 0.6)).insert)(45)
  std.stack(
    dir: ltr,
    spacing: 1.5em,
    bst(50, 30, 70, style: (scale: 0.6)).diagram,
    bst(50, 30, 70).diagram,
    bst(50, 30, 70, style: (scale: 1.6)).diagram,
    align(horizon, step.before),
  )
})

#section("style: (scale:) on a stack and a graph", std.stack(
  dir: ltr,
  spacing: 2em,
  stack(9, 7, 2, style: (scale: 1.5)).diagram,
  graph(("v1": ("v2", "v3"), "v2": ("v3",), "v3": ()), style: (scale: 0.7)).diagram,
))

#section("Hand-composed tree with subtree triangles (abstract AVL invariant)", tree(
  node(
    text(fill: rgb("#C75B12"))[$v$],
    left: subtree($T_ell$, fill: rgb("#1F6FBF")),
    right: subtree($T_r$, fill: rgb("#8E44AD"), scale: 0.8),
  ),
  style: (edge-arrow: true),
))

#section("Edge arrows: none / end / both", std.stack(
  dir: ltr,
  spacing: 1.5em,
  bst(30, 20, 40).diagram,
  bst(30, 20, 40, style: (edge-arrow: "end")).diagram,
  bst(30, 20, 40, style: (edge-arrow: "both")).diagram,
))

#section("Tree edge-pattern: normal, dashed, dotted, wavy", std.stack(
  dir: ltr,
  spacing: 1.4em,
  bst(30, 20, 40, style: (edge-arrow: "end", edge-pattern: "normal")).diagram,
  bst(30, 20, 40, style: (edge-arrow: "end", edge-pattern: "dashed")).diagram,
  bst(30, 20, 40, style: (edge-arrow: "end", edge-pattern: "dotted")).diagram,
  bst(30, 20, 40, style: (edge-arrow: "end", edge-pattern: "wavy", y-gap: 1.8, scale: 1.35)).diagram,
))

#section(
  "Tree edge-customizations: local options keyed by parent/child values",
  bst(
    30,
    20,
    40,
    10,
    25,
    style: (y-gap: 1.8),
    edge-customizations: (
      (30, 20, (stroke: 1.4pt + red, pattern: "dashed", arrow: "both")),
      (20, 10, (pattern: "wavy", color: rgb("#1565C0"))),
    ),
  ).diagram,
)

#section("Linked list (simple, with head)", linked-list(3, 1, 4, 1, 5, head: true).diagram)

#section(
  "Linked list (pointer style, addresses)",
  linked-list(15, 3, 17, 90, pointer: true, head: true, addresses: ("3200", "3600", "4000", "4400")).diagram,
)

#section("Doubly linked list (simple, two-way arrows)", doubly-linked-list(3, 1, 4, 1, 5, head: true).diagram)

#section(
  "Doubly linked list (pointer style, custom prev/next fills)",
  doubly-linked-list(15, 3, 17, 90, pointer: true, head: true, addresses: ("3200", "3600", "4000", "4400"), style: (
    prev-ptr-fill: rgb("#FDE2E4"),
    next-ptr-fill: rgb("#D7ECC9"),
  )).diagram,
)

#section("Doubly linked list object: insert (append, green) and delete (red)", {
  let l = doubly-linked-list(3, 1, 4)
  std.stack(spacing: 1em, (l.insert)(5).diagram, (l.delete)(1).diagram)
})

#section("Linked list object: insert (append, green) and delete (red)", {
  let l = linked-list(3, 1, 4)
  std.stack(spacing: 1em, (l.insert)(5).diagram, (l.delete)(1).diagram)
})

#section("Stack", stack(9, 7, 2).diagram)

#section("Stack object: push (green top) and pop (red top)", {
  let s = stack(9, 7, 2)
  std.stack(dir: ltr, spacing: 2.5em, (s.push)(4).diagram, (s.pop)().diagram)
})

#section("Queue", queue(3, 8, 5, 1).diagram)

#section("Queue object: enqueue (green rear) and dequeue (red front)", {
  let q = queue(3, 8, 5, 1)
  std.stack(spacing: 1em, (q.enqueue)(9).diagram, (q.dequeue)().diagram)
})

#section(
  "Queue with enqueue / dequeue (single-frame arrows)",
  queue(
    3,
    4,
    5,
    6,
    7,
    8,
    enqueue: 9,
    dequeue: 2,
    front-label: [Front / Head],
    rear-label: [Back / Tail / Rear],
  ).diagram,
)

#section(
  "Directed graph (adjacency dict, arrows on every declared edge)",
  graph((
    "v1": ("v2", "v3"),
    "v2": ("v3",),
    "v3": (),
  )).diagram,
)

#section(
  "Undirected graph (declaring both directions still draws one edge)",
  graph(
    (
      "v1": ("v2", "v3"),
      "v2": ("v1", "v3"),
      "v3": (),
    ),
    directed: false,
  ).diagram,
)

#section(
  "Directed graph, a neighbor not declared as its own key (v4 picked up automatically)",
  graph((
    "v1": ("v2", "v4"),
    "v2": ("v3",),
    "v3": ("v1",),
  )).diagram,
)

#section(
  "Larger directed graph (radius grows with node count)",
  graph((
    "a": ("b", "c"),
    "b": ("c", "d"),
    "c": ("d",),
    "d": ("e",),
    "e": ("f",),
    "f": ("a",),
  )).diagram,
)

#section("layout: auto circle growth from 2 to 6 nodes", {
  let panel(body) = block(
    width: 6.2em,
    height: 6.2em,
    inset: 0.2em,
    stroke: 0.5pt + luma(210),
    radius: 3pt,
    clip: true,
    align(center + horizon, scale(55%, reflow: true, body)),
  )
  std.stack(
    dir: ltr,
    spacing: 0.4em,
    panel(graph(("1": (), "2": ())).diagram),
    panel(graph(("1": (), "2": (), "3": ())).diagram),
    panel(graph(("1": (), "2": (), "3": (), "4": ())).diagram),
    panel(graph(("1": (), "2": (), "3": (), "4": (), "5": ())).diagram),
    panel(graph(("1": (), "2": (), "3": (), "4": (), "5": (), "6": ())).diagram),
  )
})

#section("layout: auto radius override separates circular nodes", std.stack(
  dir: ltr,
  spacing: 1.5em,
  graph(("1": (), "2": (), "3": (), "4": ())).diagram,
  graph(("1": (), "2": (), "3": (), "4": ()), radius: 1.8).diagram,
))

#section("Graph-wide edge-arrow-fill: none (open, default) vs a solid color", std.stack(
  dir: ltr,
  spacing: 2em,
  graph(("v1": ("v2",), "v2": ("v1",))).diagram,
  graph(("v1": ("v2",), "v2": ("v1",)), style: (edge-arrow-fill: rgb("#1565C0"))).diagram,
))

#section(
  "Graph-wide edge style: undirected graph with both tips, dashed and wavy",
  graph(
    ("v1": ("v2", "v3"), "v2": ("v3",), "v3": ()),
    directed: false,
    style: (edge-arrow: "both", edge-pattern: "wavy", scale: 1.25),
  ).diagram,
)

#section(
  "edge-customizations: per-edge stroke, color, and a bent edge (angle controls the bow)",
  graph(
    ("v1": ("v2", "v3"), "v2": ("v3",), "v3": ()),
    edge-customizations: (
      ("v1", "v2", (stroke: 2pt + red)),
      ("v2", "v3", (color: rgb("#2E7D32"))),
      ("v1", "v3", (bend: "right", angle: 35deg)),
    ),
  ).diagram,
)

#section(
  "edge-customizations: local dashed, wavy, and both-tip graph edges",
  graph(
    ("v1": ("v2", "v3"), "v2": ("v3",), "v3": ()),
    edge-customizations: (
      ("v1", "v2", (pattern: "dotted", arrow: "both")),
      ("v2", "v3", (pattern: "wavy", color: rgb("#1565C0"))),
    ),
  ).diagram,
)

#section(
  "edge-customizations: a mutual pair, each bent to its own side so they don't overlap",
  graph(
    ("v1": ("v2",), "v2": ("v1",)),
    edge-customizations: (
      ("v1", "v2", (bend: "left", angle: 30deg)),
      ("v2", "v1", (bend: "left", angle: 30deg, color: red)),
    ),
  ).diagram,
)

#section(
  "labels: content distinct from the adjacency keys (math, styled text)",
  graph(
    ("v1": ("v2", "v3"), "v2": ("v3",), "v3": ()),
    labels: (
      "v1": $v_1$,
      "v2": $v_2$,
      "v3": text(fill: rgb("#8E44AD"))[*C*],
    ),
  ).diagram,
)



#section(
  "Graph edge labels: weighted undirected graph",
  graph(
    (
      "A": (("B", [Hello]), ("C", [5])),
      "B": (("C", [11]), ("D", [9]), ("E", [7])),
      "C": (("E", [3]),),
      "D": (("E", [13]), ("F", [2])),
      "E": (("F", [6]),),
      "F": (),
    ),
    directed: false,
    layout: "manual",
    positions: (
      "A": (0, 0),
      "B": (rel: "A", offset: (2.0, 1.2)),
      "C": (rel: "A", offset: (2.0, -1.2)),
      "D": (rel: "B", offset: (2.0, 0.0)),
      "E": (rel: "C", offset: (2.0, 0.0)),
      "F": (rel: "D", offset: (2.0, -1.2)),
    ),
    style: (
      node-fill: rgb("#499df0"),
      node-stroke: 1pt + rgb("#1f72c5"),
      edge-stroke: 1pt + black,
      node-text: (size: 11pt, color: white),
      label-text: (size: 8pt, color: black),
      node-radius: 0.38,
      scale: 1.2,
    ),
    edge-customizations: (
      ("B", "D", (label: (color: red))),
      ("A", "B", (label: (rotation: "edge"))),
      ("B", "C", (label: (color: purple, weight: "bold"))),
    ),
  ).diagram,
)

#section(
  "positions: v4 placed relative to v1 with an offset, instead of the circular layout",
  graph(
    ("v1": ("v2", "v3"), "v2": ("v3",), "v3": (), "v4": ("v1",)),
    positions: (
      "v4": (rel: "v1", offset: (0, 1.5)),
    ),
  ).diagram,
)

#section(
  "layout: linear: all nodes placed in a row with a large gap",
  graph(
    ("v1": ("v2",), "v2": ("v3", "v4"), "v3": ("v4",), "v4": ()),
    edge-customizations: (
      ("v1", "v2", (bend: true)),
      ("v2", "v3", (bend: true)),
      ("v2", "v4", (bend: true, angle: -15deg)),
      ("v3", "v4", (bend: true)),
    ),
    layout: "linear",
    gap: 3
  ).diagram
)

#section(
  "layout: manual: every node placed from an explicit anchor",
  graph(
    ("v1": ("v2", "v3"), "v2": ("v4",), "v3": ("v4",), "v4": ()),
    layout: "manual",
    positions: (
      "v1": (0, 0),
      "v2": (rel: "v1", offset: (1.4, 0.8)),
      "v3": (rel: "v1", offset: (1.4, -0.8)),
      "v4": (rel: "v2", offset: (1.4, -0.8)),
    ),
  ).diagram,
)

#section("diff mark text overrides: new/remove/rotate/path can style node text", std.stack(
  spacing: 1em,
  transition("bst", (50, 30, 70, 20, 40), tree-insert(45), style: (
    new-style: (fill: rgb("#C8E6C9"), stroke: 1.4pt + rgb("#2E7D32"), text: (color: rgb("#2E7D32"), weight: "bold")),
    path-style: (fill: rgb("#FFE9A8"), stroke: 1.4pt + rgb("#F9A825"), text: (color: rgb("#6D4C00"), weight: "bold")),
  )),
  transition("avl", (50, 30, 70, 20, 40), tree-insert(35, rebalance: (enabled: true, all-steps: true)), style: (
    new-style: (fill: rgb("#C8E6C9"), stroke: 1.4pt + rgb("#2E7D32"), text: (color: rgb("#2E7D32"), weight: "bold")),
    rotate-style: (fill: rgb("#F3E5F5"), stroke: 1.4pt + rgb("#7B3FA1"), text: (color: rgb("#7B3FA1"), weight: "bold")),
  )),
  transition("bst", (50, 30, 70, 20, 40), tree-delete(30), style: (
    remove-style: (fill: rgb("#FFEBEE"), stroke: 1.4pt + rgb("#C62828"), text: (color: rgb("#C62828"), weight: "bold")),
  )),
))

#section("Node shapes: diamond and hexagon work for trees, heaps, and graphs", std.stack(
  dir: ltr,
  spacing: 1.5em,
  bst(30, 20, 40, style: (
    node-shape: "diamond",
    node-radius: 0.42,
    node-fill: rgb("#FFF3BF"),
    node-stroke: 1pt + rgb("#F08C00"),
  )).diagram,
  min-heap(10, 20, 15, style: (
    node-shape: "hexagon",
    node-radius: 0.44,
    node-fill: rgb("#E7F5FF"),
    node-stroke: 1pt + rgb("#1971C2"),
  )).diagram,
  graph(("A": ("B", "C"), "B": (), "C": ()), style: (
    node-shape: "hexagon",
    node-radius: 0.42,
    node-fill: rgb("#F3F0FF"),
    node-stroke: 1pt + rgb("#7048E8"),
  )).diagram,
))

#section("Tree edge labels: local content and label style, like graph edge labels", tree(
  node("root", left: node("L"), right: node("R")),
  style : (
    x-gap : 2,
    
  ),
  edge-customizations: (
    ("root", "L", (label: (content: [L], color: rgb("#1971C2"), weight: "bold"))),
    ("root", "R", (label: [R], color: rgb("#C92A2A"), pattern: "dashed")),
  ),
))

#section("Hand-composed multi-child tree for B-tree-style diagrams", tree(
  node([20 | 40], children: (
    node([5 | 10], children: (
      node([2]),
      node([7]),
      node([15])
    )),
    node([25 | 30], children: (
      node([22]),
      node([27]),
      node([35])
    )),
    node([50 | 60], children : (
      node([45]),
      node([55]),
      node([70])
    )),
  )),
  style: (
    node-shape: "square",
    node-radius: 0.55,
    node-fill: rgb("#FFF9DB"),
    node-stroke: 1pt + rgb("#F08C00"),
    x-gap: 1.4,
    y-gap : 2.0
  ),
))

#section("sequence(..., columns:) wraps operation steps into rows", {
  let b = bst(50, 30, 70, 20, 40)
  let s1 = (b.insert)(60)
  let s2 = ((s1.result).search)(20)
  let s3 = ((s2.result).delete)(30)
  sequence(s1, s2, s3, columns: 1, row-gap: 2em)
})

#section("Array diagram with per-cell customizations", array-view(
  4, 1, 7, 3, 9,
  cell-customizations: (
    (1, (fill: rgb("#FFF3BF"), stroke: 1pt + rgb("#F59F00"))),
    (2, (fill: rgb("#D3F9D8"), stroke: 1pt + rgb("#2B8A3E"), text: (weight: "bold"))),
    (4, (fill: rgb("#FFE3E3"), stroke: 1pt + rgb("#C92A2A"))),
  ),
  style: (
    box-fill: rgb("#F8F9FA"),
    box-stroke: 0.8pt + rgb("#495057"),
  ),
).diagram)

#section("Matrix diagram with row/column labels and per-cell customizations", matrix(
  (
    (0, 1, 0, 0),
    (1, 0, 1, 1),
    (0, 1, 0, 1),
  ),
  row-labels: ([A], [B], [C]),
  column-labels: ([A], [B], [C], [D]),
  cell-customizations: (
    ((0, 1), (fill: rgb("#E7F5FF"), stroke: 1pt + rgb("#1971C2"))),
    ((1, 2), (fill: rgb("#D3F9D8"), stroke: 1pt + rgb("#2B8A3E"))),
    ((2, 3), (fill: rgb("#FFE3E3"), stroke: 1pt + rgb("#C92A2A"))),
  ),
  style: (
    box-w: 0.7,
    box-h: 0.55,
    box-fill: rgb("#F8F9FA"),
    box-stroke: 0.7pt + rgb("#495057"),
  ),
).diagram)

#section("Tree and graph node-customizations plus symmetric binary edge labels", std.stack(
  dir: ltr,
  spacing: 2em,
  tree(
    node("root", left: node("L"), right: node("R")),
    edge-customizations: (
      ("root", "L", (label: (content: [L], color: rgb("#1971C2")))),
      ("root", "R", (label: (content: [R], color: rgb("#C92A2A")))),
    ),
    node-customizations: (
      ("root", (shape: "diamond", fill: rgb("#FFF3BF"), stroke: 1pt + rgb("#F59F00"))),
      ("L", (fill: rgb("#E7F5FF"), stroke: 1pt + rgb("#1971C2"))),
      ("R", (fill: rgb("#FFE3E3"), stroke: 1pt + rgb("#C92A2A"))),
    ),
  ),
  graph(
    ("A": ("B", "C"), "B": (), "C": ()),
    node-customizations: (
      ("A", (shape: "diamond", fill: rgb("#FFF3BF"), stroke: 1pt + rgb("#F59F00"))),
      ("C", (shape: "hexagon", fill: rgb("#D3F9D8"), stroke: 1pt + rgb("#2B8A3E"))),
    ),
    style: (edge-arrow: "end"),
  ).diagram,
))

#section("Tree and graph node-labels for per-node annotations", std.stack(
  dir: ltr,
  spacing: 2em,
  bst(
    50, 30, 70, 20, 40, 60, 80,
    node-labels: (
      (50, (content: [$d=0$], position: "top", color: rgb("#2B8A3E"), weight: "bold")),
      (30, [$d=2$]),
      (70, [$d=3$]),
      (20, (content: [$d=5$], position: 225deg)),
    ),
    style: (
      x-gap: 1.4,
      y-gap: 1.35,
      node-labels: (position: "left", offset: (-0.04, 0), color: rgb("#1971C2")),
    ),
  ).diagram,
  graph(
    (
      "S": (("A", [7]), ("B", [2])),
      "A": (("C", [3]),),
      "B": (("C", [1]),),
      "C": (),
    ),
    layout: "manual",
    positions: (
      "S": (0, 0),
      "A": (1.4, 0.8),
      "B": (1.4, -0.8),
      "C": (2.8, 0),
    ),
    node-labels: (
      ("S", (content: [$0$], position: "top", color: rgb("#2B8A3E"), weight: "bold")),
      ("A", [$7$]),
      ("B", (content: [$2$], position: "bottom", offset: (0, -0.04), color: rgb("#7048E8"))),
      ("C", [$3$]),
    ),
    style: (
      edge-arrow: "end",
      node-labels: (position: "top", offset: (0, 0.04), color: rgb("#1971C2")),
    ),
  ).diagram,
))

#section("Array indices below cells", std.stack(
  spacing: 1em,
  array-view(
    13, 21, 34, 55, 89,
    style: (
      box-fill: rgb("#F8FBFF"),
      box-stroke: 0.8pt + rgb("#1565C0"),
      indices: (enabled: true, size: 7pt, color: rgb("#455A64"), weight: "bold"),
    ),
  ).diagram,
  array-view(
    [A], [B], [C], [D],
    style: (
      box-fill: rgb("#FFF9DB"),
      box-stroke: 0.8pt + rgb("#F08C00"),
      indices: (enabled: true, labels: ([i], [j], [k], [m]), size: 7pt, color: rgb("#6D4C00"), weight: "bold"),
    ),
  ).diagram,
))

#section("Tree delete marks the lookup path before removal", transition(
  "bst",
  (50, 30, 70, 20, 40, 60),
  tree-delete(30),
  style: (
    path-style: (fill: rgb("#FFE9A8"), stroke: 1.2pt + rgb("#F9A825")),
    remove-style: (fill: rgb("#FFCDD2"), stroke: 1.2pt + rgb("#C62828")),
  ),
))

#section("Tree edge-label rotation and node-text rotation", tree(
  node("root", left: node("L"), right: node("R")),
  edge-customizations: (
    ("root", "L", (label: (content: [left], rotation: "edge", color: rgb("#1971C2")))),
    ("root", "R", (label: (content: [45deg], rotation: 45deg, color: rgb("#C92A2A")))),
  ),
  style: (
    node-text: (rotation: -12deg),
    edge-arrow: "end",
    x-gap: 1.5,
  ),
))

#section("sequence mode: result shows plain post-operation objects", {
  let b = bst(50, 30, 70)
  let s1 = (b.insert)(40)
  let s2 = ((s1.result).delete)(30)
  sequence(b, s1, s2, mode: "result", columns: 5, gap: 1.4em)
})

#section("sequence mode: after shows one highlighted panel per step", {
  let b = bst(50, 30, 70)
  let s1 = (b.insert)(40)
  let s2 = ((s1.result).delete)(30)
  sequence(b, s1, s2, mode: "after", columns: 5, gap: 1.4em)
})

#section("sequence mode: after with heap steps, columns: 3 starts rows with trees", {
  let h0 = max-heap(2, 7, 4, 1, 8, 1)
  let s1 = (h0.extract)(step-label: [take 8])
  let s2 = ((s1.result).extract)(step-label: [take 7])
  let s3 = ((s2.result).insert)(1, step-label: [smash 8, 7 \ insert 1])
  let s4 = ((s3.result).extract)(step-label: [take 4])
  let s5 = ((s4.result).extract)(step-label: [take 2])
  let s6 = ((s5.result).insert)(2, step-label: [smash 4, 2 \ insert 2])
  sequence(h0, s1, s2, s3, s4, s5, s6, mode: "after", columns: 3, gap: 1.1em, row-gap: 1.3em)
})

#section("sequence mode: after with heap steps, columns: 4 can leave arrows at row ends", {
  let h0 = max-heap(2, 7, 4, 1, 8, 1)
  let s1 = (h0.extract)(step-label: [take 8])
  let s2 = ((s1.result).extract)(step-label: [take 7])
  let s3 = ((s2.result).insert)(1, step-label: [smash 8, 7 \ insert 1])
  let s4 = ((s3.result).extract)(step-label: [take 4])
  let s5 = ((s4.result).extract)(step-label: [take 2])
  let s6 = ((s5.result).insert)(2, step-label: [smash 4, 2 \ insert 2])
  sequence(h0, s1, s2, s3, s4, s5, s6, mode: "after", columns: 4, gap: 1.1em, row-gap: 1.3em)
})

#section("Heap insert marks only the inserted duplicate value", {
  let h = max-heap(4, 2, 1, 1)
  let s = (h.insert)(1, step-label: [insert duplicate 1])
  sequence(h, s, mode: "after", columns: 3, gap: 1.2em)
})

#section("Singleton structures", std.stack(
  dir: ltr,
  spacing: 1.5em,
  bst(42).diagram,
  min-heap(42).diagram,
  linked-list(42, head: true).diagram,
  stack(42).diagram,
  queue(42).diagram,
))

#section("Unsuccessful tree search preserves the tree", transition(
  "bst",
  (50, 30, 70, 20, 40, 60, 80),
  tree-search(65),
))

#section("Heap insert and extract round trip", {
  let h0 = min-heap(3, 5, 7)
  let s1 = (h0.insert)(1, step-label: [insert 1])
  let s2 = ((s1.result).extract)(step-label: [extract minimum])
  sequence(h0, s1, s2, mode: "after", columns: 5, gap: 1.2em)
})

#section("One-cell queue combines front and rear labels", queue(42).diagram)

#section("Custom stack top label persists through operations", {
  let s = stack(9, 7, 2, top-label: [Top])
  std.stack(dir: ltr, spacing: 2.5em, s.diagram, (s.push)(4).diagram, (s.pop)().diagram)
})

#section("Named style builders match dictionary styling", std.stack(
  dir: ltr,
  spacing: 2em,
  {
    assert.eq(tree-style(), (:))
    assert.eq(stack-style(box-gap: 0), (box-gap: 0))
    assert.eq(text-style(size: 10pt), (size: 10pt))
    assert.eq(node-mark-style(fill: red), (fill: red))
    assert.eq(cell-mark-style(fill: red), (fill: red))
    none
  },
  bst(
    50, 30, 70,
    style: tree-style(
      x-gap: 1.4,
      node-fill: rgb("#E7F5FF"),
      node-text: text-style(color: rgb("#1864AB"), weight: "bold"),
      path-style: node-mark-style(fill: rgb("#FFF3BF"), stroke: 1pt + rgb("#F08C00")),
    ),
  ).diagram,
  array-view(
    [A], [B], [C],
    style: array-style(
      box-fill: rgb("#F3F0FF"),
      indices: indices-style(enabled: true, labels: auto, color: rgb("#7048E8")),
    ),
  ).diagram,
))

#section("Merge sort renders one breadth-by-depth divide and merge tree", merge-sort((38, 27, 43, 3, 9)).diagram)

#section("Quick sort partitions every active subarray at the same level", quick-sort((8, 3, 1, 7, 0, 10, 2)).diagram)

#section("Bubble sort shows compare and swap steps", bubble-sort((5, 1, 4, 2)).diagram)

#section("Insertion sort shows comparisons and adjacent swaps", insertion-sort((5, 2, 4, 1)).diagram)

#section("Selection sort shows inspected positions and swaps", selection-sort((64, 25, 12, 22, 11)).diagram)

#section("Merge sort handles duplicates", merge-sort((4, 2, 4, 1, 2)).diagram)

#section("Sorting result fields", {
  let m = merge-sort((4, 2, 4, 1, 2))
  let q = quick-sort((4, 2, 4, 1, 2), order: "desc")
  assert.eq(m.result, (1, 2, 2, 4, 4))
  assert(m.steps.len() > 3)
  assert.eq(q.result, (4, 4, 2, 2, 1))
  assert(q.steps.len() > 3)
  assert.eq(bubble-sort((3, 2, 1)).result, (1, 2, 3))
  assert.eq(insertion-sort((3, 2, 1)).result, (1, 2, 3))
  assert.eq(selection-sort((3, 2, 1)).result, (1, 2, 3))
  [OK]
})

#section("Sorting comparison and swap steps", {
  let bubble = bubble-sort((2, 1))
  let insertion = insertion-sort((5, 2))
  let selection = selection-sort((2, 1))
  assert.eq(bubble.result, (1, 2))
  assert.eq(insertion.result, (2, 5))
  assert.eq(selection.result, (1, 2))
  std.stack(dir: ttb, spacing: 1em, bubble.diagram, insertion.diagram, selection.diagram)
})

#section("Merge operation compares two sorted arrays into a progressive result", {
  let asc = merge-operation((1, 4, 7), (2, 3, 8))
  let desc = merge-operation((9, 5, 1), (8, 4, 2), order: "desc")
  assert.eq(asc.result, (1, 2, 3, 4, 7, 8))
  assert.eq(desc.result, (9, 8, 5, 4, 2, 1))
  std.stack(dir: ttb, spacing: 1em, asc.diagram, desc.diagram)
})

#section("Phase braces and striped i = m selection scans", std.stack(
  dir: ttb,
  spacing: 1em,
  merge-operation((1, 4), (2, 3)).diagram,
  selection-sort((3, 1, 2)).diagram,
))

#section("Partition step scans around a selected pivot", {
  let partition = partition-step((7, 2, 9, 3, 6))
  assert.eq(partition.result, (7, 2, 6, 3, 9))
  partition.diagram
})

#section("Quick sort pivot: first, last, and index all sort correctly", {
  let data = (8, 3, 1, 7, 0, 10, 2)
  let sorted = (0, 1, 2, 3, 7, 8, 10)
  assert.eq(quick-sort(data, pivot: "first").result, sorted)
  assert.eq(quick-sort(data, pivot: "last").result, sorted)
  assert.eq(quick-sort(data, pivot: 3).result, sorted)
  std.stack(
    dir: ttb,
    spacing: 1.2em,
    quick-sort((5, 1, 4, 2), pivot: "first").diagram,
    quick-sort((5, 1, 4, 2), pivot: 0).diagram,
  )
})

#section("Sorting carries the array's own style through every step", {
  let styled = array-view(
    5, 1, 4, 2,
    style: array-style(
      box-fill: rgb("#EEF6FF"),
      node-text: text-style(fill: rgb("#1D4ED8")),
      indices: indices-style(enabled: true, labels: auto, color: rgb("#1D4ED8")),
    ),
  )
  assert.eq(bubble-sort(styled).result, (1, 2, 4, 5))
  std.stack(
    dir: ttb,
    spacing: 1.2em,
    bubble-sort(styled).diagram,
    merge-sort(styled).diagram,
  )
})

#section("Pointer markers: index arrows above cells instead of fills", {
  // Pointers keep the cell fill clean and spread when they share a cell.
  assert.eq(bubble-sort((5, 1, 4, 2)).result, (1, 2, 4, 5))
  std.stack(
    dir: ttb,
    spacing: 1.2em,
    bubble-sort((5, 1, 4, 2)).diagram,
    insertion-sort((5, 2, 4, 1)).diagram,
    selection-sort((64, 25, 12, 22, 11)).diagram,
  )
})

#section("Per-role mark styling in both fill and pointer mode", std.stack(
  dir: ttb,
  spacing: 1.2em,
  selection-sort(
    (5, 1, 4, 2),
    current: node-mark-style(fill: rgb("#FFC9C9")),
    minimum: node-mark-style(fill: rgb("#B2F2BB")),
    compare: node-mark-style(fill: rgb("#D0EBFF")),
  ).steps.at(1).diagram,
  bubble-sort(
    (5, 1, 4, 2),
    pointers: true,
    compare: node-mark-style(stroke: 1pt + rgb("#E8590C")),
    swap: node-mark-style(stroke: 1pt + rgb("#2F9E44")),
  ).diagram,
))

#section("Sorting step panels keep labels with their arrays", {
  let steps = bubble-sort((5, 1, 4, 2)).steps
  std.stack(dir: ttb, spacing: 1em, steps.at(0).diagram, steps.at(1).diagram)
})

#section("Bubble sort keeps its settled suffix green after each pass", {
  let steps = bubble-sort((5, 1, 4, 2)).steps
  std.stack(dir: ttb, spacing: 1em, steps.at(10).diagram, steps.at(11).diagram)
})

#section("Selection sort keeps its sorted prefix green after each minimum swap", {
  let steps = selection-sort((64, 25, 12, 22, 11)).steps
  std.stack(dir: ttb, spacing: 1em, steps.at(5).diagram, steps.at(6).diagram)
})

#section("Merge operation labels left, right, and output cursors", {
  let merge = merge-operation((1, 4), (2, 3))
  assert.eq(merge.result, (1, 2, 3, 4))
  assert.eq(merge-operation((1, 4), (2, 3), pointers: false).result, (1, 2, 3, 4))
  std.stack(dir: ttb, spacing: 1em, merge.steps.at(0).diagram, merge.steps.at(1).diagram)
})

#section("Last-pivot partition shows every quicksort cursor step", {
  let partition = partition-step((7, 1, 6, 2, 5, 3, 4), pivot: "last", pointers: true)
  assert.eq(partition.result, (1, 2, 3, 4, 5, 6, 7))
  partition.diagram
})

#section("Sorting labels can be hidden without removing pointers or marks", {
  let merge = merge-operation((1, 4), (2, 3), labels: false)
  let partition = partition-step((3, 1, 2), pivot: "last", pointers: true, labels: false)
  let bubble = bubble-sort((3, 1, 2), labels: false)
  let insertion = insertion-sort((3, 1, 2), labels: false)
  let selection = selection-sort((3, 1, 2), labels: false)
  assert.eq(merge.result, (1, 2, 3, 4))
  assert.eq(partition.result, (1, 2, 3))
  assert.eq(bubble.result, (1, 2, 3))
  assert.eq(insertion.result, (1, 2, 3))
  assert.eq(selection.result, (1, 2, 3))
  std.stack(
    dir: ttb,
    spacing: 1em,
    merge.steps.at(1).diagram,
    partition.steps.at(1).diagram,
    bubble.steps.at(1).diagram,
    insertion.steps.at(1).diagram,
    selection.steps.at(1).diagram,
  )
})

#section("Composite sorting diagrams can hide structural labels", {
  let merge = merge-sort((3, 1, 2), labels: false)
  let quick = quick-sort((3, 1, 2), labels: false)
  assert.eq(merge.result, (1, 2, 3))
  assert.eq(quick.result, (1, 2, 3))
  std.stack(dir: ttb, spacing: 1em, merge.diagram, quick.diagram)
})
