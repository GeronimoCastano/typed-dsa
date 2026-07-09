// typst compile --root . --ppi 300 assets/readme/trees.typ assets/readme/trees.png
#import "../../src/lib.typ": *
#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#table(
  columns: (auto, auto),
  column-gutter: 2em,
  align: center + horizon,
  stroke: none,
  [*Binary search tree*], [*AVL tree*],
  bst(50, 30, 70, 20, 40, 60, 80).diagram,
  avl(10, 20, 30, 40, 50, 25).diagram,
)
