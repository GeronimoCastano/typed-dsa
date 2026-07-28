// Invariant checks for the tree operations. Compiling this file runs them;
// any broken invariant aborts compilation with a failed assert.
//   typst compile --root . tests/check.typ /dev/null

#import "../src/tree.typ": _build-search-tree, _calculate-balance-factor, _remove-bst-node, _insert-bst-node, _remove-avl-node

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
  array-view, bfs, bst, dijkstra, doubly-linked-list, graph, hash-table,
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
