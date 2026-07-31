// Invariant checks for the tree operations. Compiling this file runs them;
// any broken invariant aborts compilation with a failed assert.
//   typst compile --root . tests/check.typ /dev/null

#import "../src/tree.typ": _build-search-tree, _calculate-balance-factor, _remove-bst-node, _insert-bst-node, _remove-avl-node
#import "../src/graph-layout.typ": _project-point-to-graph-edge

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

#let is-height-balanced(tree-node) = {
  if tree-node == none { return true }
  (
    calc.abs(_calculate-balance-factor(tree-node)) <= 1
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
  array-view, bfs, bst, dfs, dijkstra, doubly-linked-list, graph, hash-table,
  linked-list, matrix, min-heap, skip-list, stack, theme-preset, transition,
  tree, node, subtree, queue, tree-search, quick-sort,
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

// A target the traversal cannot reach is a result, not an error.
#let unreachable = ("a": ("b",), "b": (), "c": ())
#assert(not bfs(unreachable, "a", target: "c").result.found)
#assert(bfs(unreachable, "a", target: "b").result.found)
#assert(not dijkstra(("a": (("b", 2),), "b": (), "c": ()), "a", target: "c").result.found)

// Optional and alternative spellings of style values stay accepted.
#let _ = bst(5, 3, style: (node-fill: none, edge-arrow: none, edge-pattern: none)).diagram
#let _ = bst(5, 3, style: theme-preset("dark")).diagram
#let _ = bst(5, 3, style: (node-text: (color: red), new-style: (fill: red, shape: "square"))).diagram
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
#let _ = array-view().diagram
#let _ = matrix(((1, 2), (3, 4)), row-labels: ([r],)).diagram
#let _ = tree(node("a", left: node("b"), right: subtree("T")))
#let _ = min-heap(5, 5, 3).diagram
#let _ = stack(1, 2).diagram
#let _ = queue(1, 2, enqueue: 3).diagram
#let _ = quick-sort((3, 1, 2)).result
#let _ = transition("bst", (50, 30), tree-search(99))

#set page(width: auto, height: auto, margin: 4pt)
All invariant checks passed.
