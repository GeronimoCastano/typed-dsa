// Invariant checks for the tree operations. Compiling this file runs them;
// any broken invariant aborts compilation with a failed assert.
//   typst compile --root . tests/check.typ /dev/null

#import "../src/tree.typ": _build, _bf, _bst-delete, _bst-insert, _avl-insert, _avl-delete

#let inorder(n) = if n == none { () } else { inorder(n.left) + (n.key,) + inorder(n.right) }

#let sorted(a) = {
  for i in range(1, a.len()) { if a.at(i - 1) >= a.at(i) { return false } }
  true
}

#let balanced(n) = {
  if n == none { return true }
  calc.abs(_bf(n)) <= 1 and balanced(n.left) and balanced(n.right)
}

// A BST keeps its in-order traversal sorted.
#assert(sorted(inorder(_build("bst", (50, 30, 70, 20, 40, 60, 80)))))

// An AVL tree stays sorted and height-balanced under many inserts.
#let t = _build("avl", (10, 20, 30, 40, 50, 25, 5, 1, 99, 3, 33, 7))
#assert(sorted(inorder(t)), message: "AVL not sorted")
#assert(balanced(t), message: "AVL not height-balanced")

// Deleting a two-child node removes the key and keeps the tree sorted.
#let d = _bst-delete(_build("bst", (50, 30, 70, 20, 40, 60, 80)), 30)
#assert(not inorder(d).contains(30), message: "deleted key still present")
#assert(sorted(inorder(d)), message: "delete broke ordering")

// AVL delete rebalances after removal.
#let (ad, dr) = _avl-delete(_build("avl", (30, 20, 40, 10, 25)), 40)
#assert(not inorder(ad).contains(40), message: "AVL deleted key still present")
#assert(sorted(inorder(ad)), message: "AVL delete broke ordering")
#assert(balanced(ad), message: "AVL delete left tree unbalanced")
#assert(dr.len() > 0, message: "AVL delete should rotate here")

// Duplicate inserts are ignored.
#assert(inorder(_bst-insert(_build("bst", (5, 3, 8)), 3)).len() == 3)

#set page(width: auto, height: auto, margin: 4pt)
All invariant checks passed.
