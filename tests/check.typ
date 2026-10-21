// Invariant checks for the tree operations. Compiling this file runs them;
// any broken invariant aborts compilation with a failed assert.
//   typst compile --root . tests/check.typ tests/check.pdf

#import "../src/tree/facade.typ": _build-search-tree, _remove-bst-node, _insert-bst-node, _remove-avl-node
#import "../src/graph/layout.typ": _project-point-to-graph-edge
#import "../src/sorting/common.typ": _sorting-trace-shows-indices
#import "../src/shared/style.typ": graph-style, heap-style, resolve, theme-preset, tree-style
#import "../src/lib.typ": transition, tree-insert

#let inorder(tree-node) = if tree-node == none {
  ()
} else {
  inorder(tree-node.left) + (tree-node.key,) + inorder(tree-node.right)
}

#let is-strictly-sorted(values) = {
  for value-index in range(1, values.len()) {
    if values.at(value-index - 1) >= values.at(value-index) {
      return false
    }
  }
  true
}

#let actual-tree-height(tree-node) = if tree-node == none {
  0
} else {
  1 + calc.max(actual-tree-height(tree-node.left), actual-tree-height(tree-node.right))
}

#let is-height-balanced(tree-node) = {
  if tree-node == none { return true }
  (
    calc.abs(actual-tree-height(tree-node.left) - actual-tree-height(tree-node.right)) <= 1
    and is-height-balanced(tree-node.left)
    and is-height-balanced(tree-node.right)
  )
}

// A BST keeps its in-order traversal sorted.
#assert(is-strictly-sorted(inorder(
  _build-search-tree("bst", (50, 30, 70, 20, 40, 60, 80)),
)))

// An AVL tree stays sorted and height-balanced under many inserts.
#let avl-tree = _build-search-tree(
  "avl",
  (10, 20, 30, 40, 50, 25, 5, 1, 99, 3, 33, 7),
)
#assert(is-strictly-sorted(inorder(avl-tree)), message: "AVL not sorted")
#assert(is-height-balanced(avl-tree), message: "AVL not height-balanced")

// Deleting a two-child node removes the key and keeps the tree sorted.
#let bst-after-deletion = _remove-bst-node(
  _build-search-tree("bst", (50, 30, 70, 20, 40, 60, 80)),
  30,
)
#assert(
  not inorder(bst-after-deletion).contains(30),
  message: "deleted key still present",
)
#assert(
  is-strictly-sorted(inorder(bst-after-deletion)),
  message: "delete broke ordering",
)

// AVL delete rebalances after removal.
#let (avl-after-deletion, rotation-events) = _remove-avl-node(
  _build-search-tree("avl", (30, 20, 40, 10, 25)),
  40,
)
#assert(
  not inorder(avl-after-deletion).contains(40),
  message: "AVL deleted key still present",
)
#assert(
  is-strictly-sorted(inorder(avl-after-deletion)),
  message: "AVL delete broke ordering",
)
#assert(
  is-height-balanced(avl-after-deletion),
  message: "AVL delete left tree unbalanced",
)
#assert(rotation-events.len() > 0, message: "AVL delete should rotate here")

// Duplicate inserts are ignored.
#assert(inorder(
  _insert-bst-node(_build-search-tree("bst", (5, 3, 8)), 3),
).len() == 3)

// ── Valid input stays valid ──────────────────────────────────────────────────
//
// The counterpart to tests/negative.typ: a lookup that finds nothing is a
// legitimate result reported through `found:`, not an error, and the optional
// spellings of every style value keep working. Anything asserted here must
// never become a diagnostic.

#import "../src/lib.typ": (
  array-view, bfs, bst, dfs, dijkstra, doubly-linked-list, fit-to-width, graph, hash-table,
  linked-list, matrix, merge-sort, min-heap, skip-list, stack, theme-preset,
  transition, tree, node, subtree, queue, tree-search, quick-sort,
  merge-operation, partition-step, bubble-sort, insertion-sort, selection-sort,
  indices-style,
)

// An unsuccessful search reports itself instead of failing.
#let bst-search = (bst(50, 30, 70).search)(99)
#assert(not bst-search.found, message: "absent BST key should report found: false")
#assert((bst(50, 30, 70).search)(30).found, message: "present BST key should be found")

#let list-search = (linked-list(3, 1, 4).search)(9)
#assert(not list-search.found, message: "absent list value should report found: false")
#assert(list-search.index == none, message: "absent list value has no index")
#assert.eq((linked-list(3, 1, 4).search)(4).index, 2)
#assert(not (doubly-linked-list(3, 1).search)(9).found)
#assert(not (skip-list(1, 3, 5).search)(4).found)
#assert((skip-list(1, 3, 5).search)(3).found)

// Hash tables report unsuccessful lookups and deletions the same way, under
// both collision strategies.
#assert(not (hash-table("a", "b", size: 5).search)("z").found)
#assert((hash-table("a", "b", size: 5).search)("a").found)
#assert(not (hash-table("a", "b", size: 5).delete)("z").found)
#assert(not (hash-table("a", "b", size: 5, collision: "linear").search)("z").found)
#assert((hash-table("a", "b", size: 5, collision: "linear").search)("b").found)

// Hash keys use one consistent textual representation for comparable values.
#let content-key-table = hash-table([Ada], [Grace], size: 5)
#assert(content-key-table.diagram != none)
#let numeric-key-table = hash-table(1, 1.0, size: 5)
#assert(numeric-key-table.diagram != none)
#assert(hash-table(1, size: 5, style: (pointer-text: (rotation: 10deg))).diagram != none)

// Sparse text overrides preserve preset colors while changing typography.
#let dark-text-style = resolve(theme-preset("dark") + (value-text: (weight: "bold")))
#assert(dark-text-style.value-text.fill == rgb("#F8F9FA"))
#assert(dark-text-style.value-text.weight == "bold")
#assert(resolve(theme-preset("dark")).index-text.fill == rgb("#CED4DA"))

// Bare algorithm-role colors normalize into their documented role dictionaries.
#assert(resolve((visited-style: red)).visited-style.fill == red)
#assert(resolve((active-edge-style: red)).active-edge-style.stroke == red)

// Queue operation results are plain queue objects; builder-only frame values
// do not carry into later operations.
#let queue-chain = (queue(3, 8, enqueue: 6, dequeue: 2).enqueue)(9)
#assert(queue-chain.result.diagram != none)
#let rotated-operation-caption = transition("bst", (5, 3, 7), tree-insert(4), style: (operation-text: (rotation: 10deg)))

// Explicit skip-list levels may exceed the automatic decision function bound.
#let tall-skip-insert = (skip-list(1, 2, 3, max-level: 2).insert)(4, level: 3)
#assert(tall-skip-insert.after != none)

// Queue spacing is controlled by box-gap while its default remains contiguous.
#let spaced-queue = queue(3, 8, 5, style: (box-gap: 1.5))
#assert(spaced-queue.diagram != none)

// A target the traversal cannot reach is a result, not an error.
#let unreachable = ("a": ("b",), "b": (), "c": ())
#assert(not bfs(unreachable, "a", target: "c").result.found)
#assert(bfs(unreachable, "a", target: "b").result.found)
#assert(not dijkstra(("a": (("b", 2),), "b": (), "c": ()), "a", target: "c").result.found)

// Optional and alternative spellings of style values stay accepted.
#let _ = bst(5, 3, style: (node-fill: none, edge-arrow: none, edge-pattern: none)).diagram
#assert.eq(tree-style(edge-arrow-symbol: ">>"), (edge-arrow-symbol: ">>"))
#assert.eq(heap-style(edge-arrow-symbol: "o"), (edge-arrow-symbol: "o"))
#assert.eq(graph-style(edge-arrow-symbol: "stealth"), (edge-arrow-symbol: "stealth"))
#let _ = bst(30, 20, 40, style: (edge-arrow: "both", edge-arrow-symbol: ">>", edge-pattern: "wavy")).diagram
#let _ = min-heap(4, 2, 3, style: (edge-arrow: "end", edge-arrow-symbol: "o")).diagram
#let _ = graph(("A": ("B",), "B": ()), style: (edge-arrow-symbol: "stealth", edge-pattern: "wavy")).diagram
#let _ = graph(("A": ("B",), "B": ()), style: graph-style(edge-arrow-symbol: "parenthesis")).diagram
#let _ = graph(
  ("A": ("B",), "B": ()),
  edge-customizations: (("A", "B", (bend: "left")),),
  style: (edge-arrow-symbol: "stealth", edge-pattern: "wavy"),
).diagram
#let _ = bst(5, 3, style: theme-preset("dark")).diagram
#let _ = bst(5, 3, style: (node-text: (color: red), new-style: (fill: red, shape: "square"))).diagram
#let _ = bst(5, 3, 7, edge-customizations: ((5, 3, (stroke: 2pt, pattern: (2pt, 2pt))),)).diagram
#let _ = bst(5, 3, 7, edge-customizations: ((5, 3, (stroke: none, pattern: "dotted")),)).diagram
#let _ = graph(("A": (("B", [edge]),), "B": ()), layout: "manual", positions: ("A": (0, 0), "B": (3, 0)), edge-customizations: (("A", "B", (label: (rotation: "edge"))),)).diagram
#let _ = linked-list(1, 2, style: (box-gap: 0)).diagram
#let _ = graph(("a": ("b",), "b": ()), positions: ("a": (rel: "b", offset: (0, 1)))).diagram
#let _ = graph(("a": ("b",), "b": ()), layout: "linear", gap: 2).diagram
#let force-adjacency = (
  "a": ("b", "c"),
  "b": ("c",),
  "c": (),
  "d": (),
)
#let _ = graph(force-adjacency, directed: false, layout: "force").diagram
#let _ = graph(("solo": ()), layout: "force").diagram
#let _ = graph(("a": (), "b": ()), layout: "force").diagram
#let _ = graph(("a": ("b",), "b": ()), directed: false, layout: "force").diagram
#let _ = graph(
  force-adjacency,
  directed: false,
  layout: "force",
  positions: ("a": (7, 3)),
).diagram

#let layered-adjacency = (
  "source-a": ("merge",),
  "source-b": ("merge", "side"),
  "merge": ("sink",),
  "side": ("sink",),
  "sink": (),
  "isolated": (),
)
#for direction in ("right", "left", "down", "up") {
  let _ = graph(
    layered-adjacency,
    layout: "layered",
    layout-options: (direction: direction),
  ).diagram
}
#let _ = graph(
  layered-adjacency,
  layout: "layered",
  positions: ("merge": (8, 4)),
).diagram

#let force-bfs = bfs(
  force-adjacency,
  "a",
  directed: false,
  layout: "force",
  layout-options: (
    edge-length: 2.0,
    repulsion: 1.1,
    attraction: 0.9,
    node-edge-repulsion: 1.2,
    node-edge-clearance: 0.3,
    iterations: 45,
    component-gap: 2.8,
  ),
)
#let force-dfs = dfs(
  force-adjacency,
  "a",
  directed: false,
  layout: "force",
)
#let force-dijkstra = dijkstra(
  ("a": (("b", 2), ("c", 5)), "b": (("c", 1),), "c": ()),
  "a",
  layout: "force",
)
#let layered-bfs = bfs(layered-adjacency, "source-a", layout: "layered")
#let layered-dfs = dfs(
  layered-adjacency,
  "source-a",
  layout: "layered",
  layout-options: (direction: "down", crossing-sweeps: 0),
)
#let layered-dijkstra = dijkstra(
  ("a": (("b", 2), ("c", 5)), "b": (("c", 1),), "c": ()),
  "a",
  layout: "layered",
)
#for trace in (
  force-bfs, force-dfs, force-dijkstra,
  layered-bfs, layered-dfs, layered-dijkstra,
) {
  let first-node-positions = trace.steps.first().node-positions
  assert(
    trace.steps.all(step => step.node-positions == first-node-positions),
    message: "graph algorithm panels must reuse one resolved layout",
  )
}
#let repeated-force-bfs = bfs(
  force-adjacency,
  "a",
  directed: false,
  layout: "force",
  layout-options: (
    edge-length: 2.0,
    repulsion: 1.1,
    attraction: 0.9,
    node-edge-repulsion: 1.2,
    node-edge-clearance: 0.3,
    iterations: 45,
    component-gap: 2.8,
  ),
)
#assert.eq(
  force-bfs.steps.first().node-positions,
  repeated-force-bfs.steps.first().node-positions,
)

// Force placement keeps every straight edge outside non-endpoint node bounds.
#let node-edge-regression-adjacency = (
  "A": ("B", "C"),
  "B": ("C", "D"),
  "C": ("D", "E"),
  "D": ("E",),
  "E": ("A",),
)
#let node-edge-regression-positions = bfs(
  node-edge-regression-adjacency,
  "A",
  directed: false,
  layout: "force",
).steps.first().node-positions
#let center-to-hidden-edge = _project-point-to-graph-edge(
  node-edge-regression-positions.at("C"),
  node-edge-regression-positions.at("B"),
  node-edge-regression-positions.at("D"),
)
#assert(
  center-to-hidden-edge.distance >= 0.54,
  message: "force layout placed the B-D edge inside node C",
)
#let node-edge-regression-edges = (
  ("A", "B"), ("A", "C"), ("B", "C"), ("B", "D"),
  ("C", "D"), ("C", "E"), ("D", "E"), ("E", "A"),
)
#for (from-node-id, to-node-id) in node-edge-regression-edges {
  for node-id in node-edge-regression-adjacency.keys() {
    if node-id in (from-node-id, to-node-id) { continue }
    let projection = _project-point-to-graph-edge(
      node-edge-regression-positions.at(node-id),
      node-edge-regression-positions.at(from-node-id),
      node-edge-regression-positions.at(to-node-id),
    )
    assert(
      projection.distance >= 0.54,
      message: "force layout placed an edge inside a non-endpoint node",
    )
  }
}
#let large-center-node-positions = bfs(
  node-edge-regression-adjacency,
  "A",
  directed: false,
  layout: "force",
  node-customizations: (("C", (node-radius: 0.6)),),
).steps.first().node-positions
#let large-center-to-hidden-edge = _project-point-to-graph-edge(
  large-center-node-positions.at("C"),
  large-center-node-positions.at("B"),
  large-center-node-positions.at("D"),
)
#assert(
  large-center-to-hidden-edge.distance >= 0.84,
  message: "force layout did not account for a customized node radius",
)
#for (from-node-id, to-node-id) in node-edge-regression-edges {
  for node-id in node-edge-regression-adjacency.keys() {
    if node-id in (from-node-id, to-node-id) { continue }
    let projection = _project-point-to-graph-edge(
      large-center-node-positions.at(node-id),
      large-center-node-positions.at(from-node-id),
      large-center-node-positions.at(to-node-id),
    )
    let minimum-clearance = if node-id == "C" { 0.84 } else { 0.54 }
    assert(
      projection.distance >= minimum-clearance,
      message: "force layout ignored a customized node boundary",
    )
  }
}

#let assert-force-edges-clear(adjacency, source, layout-options: (:)) = {
  let node-positions = bfs(
    adjacency,
    source,
    directed: false,
    layout: "force",
    layout-options: layout-options,
  ).steps.first().node-positions
  let minimum-clearance = 0.3 + layout-options.at(
    "node-edge-clearance", default: 0.25,
  ) - 0.01
  for from-node-id in adjacency.keys() {
    for to-node-id in adjacency.at(from-node-id) {
      for node-id in adjacency.keys() {
        if node-id in (from-node-id, to-node-id) { continue }
        let projection = _project-point-to-graph-edge(
          node-positions.at(node-id),
          node-positions.at(from-node-id),
          node-positions.at(to-node-id),
        )
        assert(
          projection.distance >= minimum-clearance,
          message: (
            "force layout placed edge " + from-node-id + "-" + to-node-id
              + " inside node " + node-id
          ),
        )
      }
    }
  }
}

// Denser and larger graphs preserve node-edge clearance as the number of
// possible obstructions grows.
#let dense-mesh-adjacency = (
  "A": ("B", "C", "D"),
  "B": ("C", "E", "F"),
  "C": ("D", "F", "G"),
  "D": ("G", "H"),
  "E": ("F", "H"),
  "F": ("G",),
  "G": ("H",),
  "H": ("A",),
)
#assert-force-edges-clear(
  dense-mesh-adjacency,
  "A",
  layout-options: (edge-length: 2.1, node-edge-clearance: 0.3),
)

#let long-range-adjacency = (
  "N1": ("N2", "N3", "N7"),
  "N2": ("N3", "N4", "N9"),
  "N3": ("N5", "N8"),
  "N4": ("N5", "N6", "N10"),
  "N5": ("N6", "N11"),
  "N6": ("N12",),
  "N7": ("N8", "N9"),
  "N8": ("N9", "N10"),
  "N9": ("N11",),
  "N10": ("N11", "N12"),
  "N11": ("N12",),
  "N12": ("N1",),
)
#assert-force-edges-clear(
  long-range-adjacency,
  "N1",
  layout-options: (edge-length: 2.2, node-edge-clearance: 0.3),
)

#let nonplanar-adjacency = (
  "L1": ("R1", "R2", "R3"),
  "L2": ("R1", "R2", "R3"),
  "L3": ("R1", "R2", "R3"),
  "R1": (),
  "R2": (),
  "R3": (),
)
#assert-force-edges-clear(
  nonplanar-adjacency,
  "L1",
  layout-options: (edge-length: 2.1, node-edge-clearance: 0.3),
)
#let repeated-layered-bfs = bfs(
  layered-adjacency,
  "source-a",
  layout: "layered",
)
#assert.eq(
  layered-bfs.steps.first().node-positions,
  repeated-layered-bfs.steps.first().node-positions,
)
#let force-override-trace = bfs(
  force-adjacency,
  "a",
  directed: false,
  layout: "force",
  positions: ("a": (7, 3)),
)
#assert.eq(force-override-trace.steps.first().node-positions.at("a"), (7, 3))
#let layered-override-trace = bfs(
  layered-adjacency,
  "source-a",
  layout: "layered",
  positions: ("merge": (8, 4)),
)
#assert.eq(layered-override-trace.steps.first().node-positions.at("merge"), (8, 4))
#let right-layered-positions = layered-bfs.steps.first().node-positions
#let left-layered-positions = bfs(
  layered-adjacency,
  "source-a",
  layout: "layered",
  layout-options: (direction: "left"),
).steps.first().node-positions
#let down-layered-positions = layered-dfs.steps.first().node-positions
#let up-layered-positions = bfs(
  layered-adjacency,
  "source-a",
  layout: "layered",
  layout-options: (direction: "up"),
).steps.first().node-positions
#assert(right-layered-positions.at("source-a").at(0) < right-layered-positions.at("sink").at(0))
#assert(left-layered-positions.at("source-a").at(0) > left-layered-positions.at("sink").at(0))
#assert(down-layered-positions.at("source-a").at(1) > down-layered-positions.at("sink").at(1))
#assert(up-layered-positions.at("source-a").at(1) < up-layered-positions.at("sink").at(1))
#let _ = array-view(1, 2, 3, style: (indices: true)).diagram
#let merge-index-labels-trace = merge-sort(array-view(
  4, 2, 3, 1,
  style: (indices: (enabled: true, labels: ("1", "2", "3", "4"))),
))
#assert.eq(merge-index-labels-trace.result, (1, 2, 3, 4))
#let _ = merge-index-labels-trace.diagram

// Sorting traces show index labels by default and hide them whenever the
// caller's style switches them off, in any accepted spelling.
#assert(_sorting-trace-shows-indices((:)))
#assert(_sorting-trace-shows-indices((indices: true)))
#assert(_sorting-trace-shows-indices((indices: indices-style(labels: ("a", "b")))))
#assert(_sorting-trace-shows-indices((indices: indices-style(enabled: true))))
#assert(not _sorting-trace-shows-indices((indices: false)))
#assert(not _sorting-trace-shows-indices((indices: none)))
#assert(not _sorting-trace-shows-indices((indices: indices-style(enabled: false))))
#assert(not _sorting-trace-shows-indices((indices: indices-style(enabled: false, labels: ("a", "b")))))
#for hidden-index-style in (
  (indices: indices-style(enabled: false)),
  (indices: false),
  (indices: none),
) {
  let unsorted = array-view(4, 2, 3, 1, style: hidden-index-style)
  let merge-trace = merge-sort(unsorted)
  assert.eq(merge-trace.result, (1, 2, 3, 4))
  let _ = merge-trace.diagram
  let _ = merge-trace.steps.map(step => step.diagram)
  let _ = merge-operation(
    array-view(1, 4, style: hidden-index-style),
    array-view(2, 3, style: hidden-index-style),
  ).diagram
  let _ = partition-step(unsorted).diagram
  assert.eq(quick-sort(unsorted).result, (1, 2, 3, 4))
  assert.eq(bubble-sort(unsorted).result, (1, 2, 3, 4))
  assert.eq(insertion-sort(unsorted).result, (1, 2, 3, 4))
  assert.eq(selection-sort(unsorted).result, (1, 2, 3, 4))
}
#let _ = array-view().diagram
#let _ = matrix(((1, 2), (3, 4)), row-labels: ([r],)).diagram
#let _ = matrix(((1, 2), (3, 4)), column-labels: ([a], [b])).diagram
#let _ = tree(node("a", left: node("b"), right: subtree("T")))
#let _ = min-heap(5, 5, 3).diagram
#let _ = stack(1, 2).diagram
#let _ = queue(1, 2, enqueue: 3).diagram
#let _ = quick-sort((3, 1, 2)).result
#let _ = transition("bst", (50, 30), tree-search(99))

#set page(width: auto, height: auto, margin: 4pt)
All invariant checks passed.

// Graph edges retain endpoint identity through routing and normalization.
#import "../src/graph/model.typ": _collect-graph-edges
#import "../src/graph/render.typ": _resolve-graph-edge-routing
#import "../src/graph/layout.typ": _calculate-graph-loop-geometry
#let reciprocal-edges = _collect-graph-edges(("A": (("B", 4),), "B": (("A", 7),)), true)
#assert(reciprocal-edges.len() == 2)
#assert(_resolve-graph-edge-routing(reciprocal-edges, "A", "B", true, "auto", none).bend == "left")
#assert(_resolve-graph-edge-routing(reciprocal-edges, "B", "A", true, "auto", none).bend == "left")
#assert(_resolve-graph-edge-routing(reciprocal-edges, "A", "B", true, "manual", none) == (:))
#assert(_resolve-graph-edge-routing(reciprocal-edges, "A", "B", false, "auto", none) == (:))
#assert(_resolve-graph-edge-routing(reciprocal-edges, "A", "B", true, "auto", (bend: false)).bend == false)
#assert(_resolve-graph-edge-routing(reciprocal-edges, "A", "B", true, "auto", (bend: "right", color: red)) == (bend: "right", color: red))
#assert(_collect-graph-edges(("A": (("B", 4),), "B": (("A", 4),)), false).len() == 1)
#assert(_collect-graph-edges(("A": ("A",)), false).len() == 1)
#let loop-shapes = ("circle", "square", "rounded", "capsule", "diamond", "hexagon")
#for shape in loop-shapes {
  let upper = _calculate-graph-loop-geometry((2, 3), (shape, 0.6))
  let lower = _calculate-graph-loop-geometry((2, 3), (shape, 0.6), bend: "right")
  let attachment-x = upper.start.at(0) - 2
  let attachment-y = upper.start.at(1) - 3
  if shape == "circle" {
    assert(calc.abs(attachment-x * attachment-x + attachment-y * attachment-y - 0.36) < 0.000001)
  } else if shape == "diamond" {
    assert(calc.abs(attachment-x + attachment-y - 0.6) < 0.000001)
  } else {
    let boundary-height = if shape == "hexagon" { 0.86 * 0.6 } else { 0.6 }
    assert(calc.abs(attachment-y - boundary-height) < 0.000001)
  }
  assert(upper.start != upper.end)
  assert(upper.start.at(1) > 3 and upper.label.at(1) > upper.start.at(1))
  assert(calc.abs(upper.label.at(1) + lower.label.at(1) - 6) < 0.000001)
  let _ = graph(("A": (("A", [repeat]),)), style: (node-shape: shape)).diagram
}
#let _ = graph(("A": ("A",)), directed: false).diagram
#let _ = graph(("A": (("B", [same]),), "B": (("A", [same]),)), directed: false).diagram
#let _ = graph(("A": ("B",), "B": ("A",)), edge-routing: "auto").diagram
#let _ = graph(("A": (), "B": ()), positions: ("A": (0, 0), "B": (0, 0))).diagram
#let _ = graph(("A": ("A",)), edge-customizations: (("A", "A", (bend: "right", label: (content: [loop], color: red))),)).diagram
#let _ = graph(("A": ("A",)), style: (edge-pattern: "wavy"), edge-customizations: (("A", "A", (pattern: "solid", wave: false)),)).diagram
#let loop-traversal-adjacency = ("A": (("A", 0), ("B", 4)), "B": (("A", 7),))
#assert(bfs(loop-traversal-adjacency, "A", edge-routing: "auto").result.order == ("A", "B"))
#assert(dfs(loop-traversal-adjacency, "A", edge-routing: "auto").result.order == ("A", "B"))
#assert(dijkstra(loop-traversal-adjacency, "A", edge-routing: "auto").result.distances.at("B") == 4)

#assert(_calculate-graph-loop-geometry((0, 0), ("circle", 0.4), bend: true).side == -1)
#assert(_resolve-graph-edge-routing((("A", "B", none),), "A", "B", true, "auto", none) == (:))
#let _ = graph(("A": ("A",)), edge-customizations: (("A", "A", (label: (body: [repeat], size: 12pt))),)).diagram

#let _ = graph(("A": ("A",)), layout: "force").diagram

// Tidy tree layout accepts binary, multiway, and triangle trees.
#let _ = bst(5, 3, 8, 1, 4, 9, style: (tree-layout: "tidy")).diagram
#let _ = tree(
  node("r", children: (node("a"), subtree("T"), node("c", children: (node("d"),)))),
  style: (tree-layout: "tidy"),
)
#let _ = ((bst(20, 10, 30, style: (tree-layout: "tidy")).insert)(40)).diagram

// Distance labels take their default look from distance-text. label-text does
// not reach them, and an explicit color is folded into fill.
#import "../src/graph/layout.typ": _calculate-node-boundary-radius, _default-node-half-width, _fitted-node-half-width
#let _is-close(actual, expected) = calc.abs(actual - expected) < 0.000001
#assert(resolve((:)).distance-text.fill == rgb("#7048E8"))
#assert(resolve((:)).distance-text.weight == "bold")
#assert(resolve((label-text: (fill: blue))).distance-text.fill == rgb("#7048E8"))
#assert(resolve((distance-text: (color: red))).distance-text.fill == red)
#assert(resolve((distance-text: (color: red))).distance-text.at("color", default: none) == none)
#assert(resolve((:)).edge-arrow-symbol == ">")
#assert(resolve((edge-arrow-symbol: "stealth")).edge-arrow-symbol == "stealth")

// Default boundaries: squares and rounded boxes exit through their corner on
// diagonals, and capsules are 1.4r half-wide.
#assert(_is-close(_default-node-half-width("capsule", 0.34), 0.476))
#assert(_is-close(_calculate-node-boundary-radius("square", 0.4, 0.6, 0.8), 0.5))
#assert(_is-close(_calculate-node-boundary-radius("capsule", 0.4, 1, 0), 0.56))
#assert(_is-close(_calculate-node-boundary-radius("capsule", 0.4, 0, 1), 0.4))

// A widened box leaves through its flat side for shallow rays and through its
// corner for steep ones, so the exit distance follows the measured half-width.
#assert(_is-close(_calculate-node-boundary-radius("rounded", 0.4, 1, 0, half-width: 0.8), 0.8))
#assert(_is-close(_calculate-node-boundary-radius("square", 0.4, 0.6, 0.8, half-width: 1.0), 0.5))

// A widened capsule: the flat top covers rays within the straight part, and
// the end cap takes over beyond it. Both branches agree at the boundary.
#assert(_is-close(_calculate-node-boundary-radius("capsule", 0.4, 0.6, 0.8, half-width: 1.0), 0.5))
#assert(_is-close(_calculate-node-boundary-radius("capsule", 0.4, 1, 0, half-width: 1.0), 1.0))
#assert(_is-close(_calculate-node-boundary-radius("capsule", 0.4, 0.6, 0.8, half-width: 1.35), 0.5))
#assert(_is-close(_calculate-node-boundary-radius("capsule", 1, 0.6, 0.8, half-width: 1.75), 1.25))
#assert(_is-close(_calculate-node-boundary-radius("capsule", 1, 0.6, 0.8, half-width: 1.35), 1.17))

// node-fit never shrinks a node below its default width, and pads a long label
// on each side: a rectangle by half a radius, a capsule by a full radius.
#assert(_is-close(_fitted-node-half-width(0.2, "square", 0.34), 0.34))
#assert(_is-close(_fitted-node-half-width(1.0, "rounded", 0.34), 0.67))
#assert(_is-close(_fitted-node-half-width(1.0, "capsule", 0.34), 0.84))

// Fitted graphs compile through the measured render path.
#let _ = graph(("Harbor": ("Campus",), "Campus": ()), layout: "linear", style: (node-shape: "capsule", node-fit: true)).diagram
#let _ = graph(("A": (("B", [long label]),), "B": ()), style: (node-shape: "rounded", node-fit: true)).diagram
#let _ = dijkstra(("A": (("B", 2),), "B": ()), "A", style: (node-shape: "rounded", node-fit: true, distance-text: (fill: red))).diagram

// Empty adjacency is a valid empty graph in every automatic layout.
#let _ = graph((:)).diagram
#let _ = graph((:), layout: "layered").diagram
#let _ = graph((:), layout: "linear").diagram
#let _ = bfs(("A": ("B",), "B": ()), "A", style: (algorithm-label-text: (rotation: 12deg))).diagram
#let _ = graph(("A": ("B",), "B": ()), node-labels: ("A": [note]), style: (node-labels: (enabled: false))).diagram
#let _ = bst(2, 1, 3, node-labels: ((2, [note]),), style: (node-labels: (enabled: false))).diagram
#let _ = bfs(
  ("A": ("B",), "B": ()), "A",
  style: (
    visited-style: rgb("#C8E6C9"), current-style: rgb("#90CAF9"),
    queued-style: rgb("#FFE082"), active-edge-style: rgb("#1971C2"),
  ),
).diagram
#let _ = dijkstra(
  ("S": (("A", 4),), "A": ()), "S",
  node-labels: ("A": (color: green)),
).steps.last().diagram
#let _ = graph(("A": ("B",), "B": ()), style: (node-radius: 0.8)).diagram
#let _ = graph(
  ("A": ("B",), "B": ()), layout: "linear",
  node-customizations: (("A", (node-radius: 2.0)),),
).diagram
#let _ = graph(
  ("A": ("B",), "B": ()), layout: "force",
  node-customizations: (("A", (node-radius: 2.0)), ("B", (node-radius: 2.0))),
).diagram

// Width fitting accepts its default, an explicit percentage, and a length.
#let _ = fit-to-width(bst(5, 3, 8).diagram)
#let _ = fit-to-width(
  std.stack(dir: ltr, bst(5, 3, 8).diagram, graph(("A": ())).diagram),
  width: 80%,
)
#let _ = fit-to-width(dijkstra(("A": ()), "A").steps.last().diagram, width: 12cm)
#context {
  let fitted-absolute-body = measure(fit-to-width(box(width: 4cm, height: 1cm), width: 2cm))
  assert(fitted-absolute-body.width <= 2cm)
  let fitted-percentage-body = measure(
    fit-to-width(box(width: 4cm, height: 1cm), width: 75%),
    width: 4cm,
  )
  assert(fitted-percentage-body.width <= 3cm)
  let unchanged-small-body = measure(fit-to-width(box(width: 1cm, height: 1cm), width: 2cm))
  assert(unchanged-small-body.width == 1cm)
}

#import "../src/graph/model.typ": _collect-graph-edges
#let _canonical-undirected-edges-forward = _collect-graph-edges(("A": ("B",), "B": ("A",)), false)
#let _canonical-undirected-edges-reverse = _collect-graph-edges(("B": ("A",), "A": ("B",)), false)
#assert(_canonical-undirected-edges-forward == _canonical-undirected-edges-reverse)

#assert(_is-close(_calculate-node-boundary-radius("hexagon", 0.5, 0.8660254, 0.5), 0.432256))

#assert(not is-height-balanced(_build-search-tree("bst", (1, 2, 3, 4))), message: "balance checks use actual subtree heights")

#import "../src/shared/label-placement.typ": select-external-label-candidate

// Candidate boxes expose the position selected by the shared geometric scorer.
#let _label-placement-candidate(position, center) = (
  position: position,
  center: center,
  half-width: 0.15,
  half-height: 0.15,
)

#let _diagonal-placement-candidates = (
  _label-placement-candidate("right", (1, 0)),
  _label-placement-candidate("left", (-1, 0)),
  _label-placement-candidate("top", (0, 1)),
  _label-placement-candidate("bottom", (0, -1)),
  _label-placement-candidate("top-right", (0.707, 0.707)),
  _label-placement-candidate("top-left", (-0.707, 0.707)),
  _label-placement-candidate("bottom-right", (0.707, -0.707)),
  _label-placement-candidate("bottom-left", (-0.707, -0.707)),
)
#let _cardinal-label-obstacles = (
  (1, 0, 0.15, 0.15),
  (-1, 0, 0.15, 0.15),
  (0, 1, 0.15, 0.15),
  (0, -1, 0.15, 0.15),
)
#let _selected-diagonal-label = select-external-label-candidate(
  _diagonal-placement-candidates,
  (),
  (),
  label-obstacles: _cardinal-label-obstacles,
)
#assert.eq(_selected-diagonal-label.position, "top-right")

// Earlier external labels reserve their measured rectangles during placement.
#let _label-obstacle-candidates = (
  _label-placement-candidate("right", (1, 0)),
  _label-placement-candidate("left", (-1, 0)),
)
#let _selected-clear-side = select-external-label-candidate(
  _label-obstacle-candidates,
  (),
  (),
  label-obstacles: ((1, 0, 0.15, 0.15),),
)
#assert.eq(_selected-clear-side.position, "left")

// Long graph edges are checked across their full segment, not only near nodes.
#let _edge-routing-candidates = (
  _label-placement-candidate("right", (1, 0)),
  _label-placement-candidate("top", (0, 1)),
)
#let _selected-edge-clear-side = select-external-label-candidate(
  _edge-routing-candidates,
  (),
  (((-100, 0), (100, 0), 0.05),),
)
#assert.eq(_selected-edge-clear-side.position, "top")

// Automatic label placement accepts every named side in tree and graph APIs.
#let label-positions = (
  "auto", "right", "left", "top", "bottom",
  "top-right", "top-left", "bottom-right", "bottom-left",
)
#for label-position in label-positions {
  let _ = bst(
    2, 1, 3,
    node-labels: ((2, (content: [root], position: label-position)),),
  ).diagram
  let _ = graph(
    ("A": ("B",), "B": ()),
    node-labels: ("A": (content: [source], position: label-position)),
  ).diagram
  let _ = bfs(
    ("A": ("B",), "B": ()), "A",
    node-labels: ("B": (content: [parent: A], position: label-position)),
  ).steps.last().diagram
  let _ = dfs(
    ("A": ("B",), "B": ()), "A",
    node-labels: ("B": (content: [depth: 1], position: label-position)),
  ).steps.last().diagram
  let _ = dijkstra(
    ("A": (("B", 2),), "B": ()), "A",
    node-labels: ("B": (content: [predecessor: A], position: label-position)),
  ).steps.last().diagram
}

// Omitted positions and the shared style default both select automatic placement.
#let _ = bst(2, 1, 3, node-labels: ((2, [root]),)).diagram
#let _ = graph(("A": ("B",), "B": ()), node-labels: ("A": [source])).diagram
#let _ = bst(2, 1, 3, node-labels: ((2, [root]),), style: (node-labels: (position: "auto"))).diagram
#let _ = graph(("A": ("B",), "B": ()), node-labels: ("A": [source]), style: (node-labels: (position: "auto",))).diagram

// Graph teaching traces share the same automatic and fixed placement contract.
#let _ = bfs(
  ("A": ("B",), "B": ("C",), "C": ()), "A",
  node-labels: ("B": (content: [parent: A], position: "auto")),
).steps.last().diagram
#let _ = dfs(
  ("A": ("B",), "B": ("C",), "C": ()), "A",
  node-labels: ("B": (content: [depth: 1], position: "top-right")),
).steps.last().diagram
#let _ = dijkstra(
  ("A": (("B", 2),), "B": (("C", 3),), "C": ()), "A",
  node-labels: ("B": (content: [predecessor: A], position: "bottom-left")),
).steps.last().diagram

// Bent graph paths keep the wavy pattern for manual and automatic routing.
#let _ = graph(
  ("A": ("B",), "B": ()),
  layout: "manual", positions: ("A": (0, 0), "B": (3, 0)),
  style: (edge-pattern: "wavy"),
  edge-customizations: (("A", "B", (bend: "left")),),
).diagram
#let _ = graph(
  ("A": (("B", [ab]),), "B": (("A", [ba]),)),
  layout: "manual", positions: ("A": (0, 0), "B": (3, 0)),
  edge-routing: "auto", style: (edge-pattern: "wavy"),
  edge-customizations: (("A", "B", (bend: true)),),
).diagram
#let _ = graph(
  ("A": ("B", "C"), "C": (), "B": ()),
  layout: "linear", gap: 1.4, edge-routing: "auto",
  style: (edge-pattern: "wavy"),
).diagram

// Explicit tree spacing remains a minimum and expands for rendered shapes.
#import "../src/tree/render.typ": _calculate-tree-layout-style
#import "../src/tree/layout.typ": _calculate-tree-layout, _place-tidy-subtree, _calculate-column-half-width
#let wide-node-root = node(1, left: node(2), right: node(3))
#let wide-node-layout-style = _calculate-tree-layout-style(
  wide-node-root,
  resolve((node-radius: 0.6, x-gap: 0.4)),
  ((3, (node-radius: 1.1)),),
  (node-radius: 0.6, x-gap: 0.4),
)
#assert(wide-node-layout-style.x-gap >= 2 * 1.1 + 0.24)
#let wide-triangle-root = node(
  1,
  left: subtree("left", scale: 1.8),
  right: subtree("right", scale: 1.2),
)
#let wide-triangle-layout-style = _calculate-tree-layout-style(
  wide-triangle-root,
  resolve((node-radius: 0.3, tri-w: 1.4, x-gap: 0.4)),
  (),
  (node-radius: 0.3, tri-w: 1.4, x-gap: 0.4),
)
#assert(wide-triangle-layout-style.x-gap >= 2 * 1.4 * 1.8 / 2 + 0.24)

// Lone children lean symmetrically and tidy triangle contours keep a margin.
#let lone-left-layout = _calculate-tree-layout(node("p", left: node("l")), 0, 0).first()
#let lone-right-layout = _calculate-tree-layout(node("p", right: node("r")), 0, 0).first()
#assert.eq(lone-left-layout.left._col - lone-left-layout._col, -0.5)
#assert.eq(lone-right-layout.right._col - lone-right-layout._col, 0.5)
#let tidy-triangle-style = resolve((tree-layout: "tidy", tri-w: 1.4, node-radius: 0.3, x-gap: 1.05))
#let tidy-triangle-layout = _place-tidy-subtree(
  node("p", left: subtree("L", scale: 1.8), right: subtree("R", scale: 1.2)),
  tidy-triangle-style,
).first()
#let triangle-sibling-clearance = (
  tidy-triangle-layout.right._col - tidy-triangle-layout.left._col
) * tidy-triangle-style.x-gap - tidy-triangle-style.tri-w * (1.8 + 1.2) / 2
#assert(triangle-sibling-clearance >= 0.24 - 0.000001)

#import "../src/graph/render.typ": _resolve-graph-edge-routing
#let straight-partner-route = _resolve-graph-edge-routing(
  (("A", "B", none), ("B", "A", none)), "B", "A", true, "auto", none,
  reciprocal-custom: (bend: true, angle: 0deg),
)
#assert.eq(straight-partner-route.bend, "right")
#assert.eq(straight-partner-route.angle, 25deg)
#let signed-partner-route = _resolve-graph-edge-routing(
  (("A", "B", none), ("B", "A", none)), "B", "A", true, "auto", none,
  reciprocal-custom: (bend: true, angle: -25deg),
)
#assert.eq(signed-partner-route.bend, "right")
#assert.eq(signed-partner-route.angle, -25deg)
