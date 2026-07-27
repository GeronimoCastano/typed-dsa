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

#set page(width: auto, height: auto, margin: 4pt)
All invariant checks passed.
