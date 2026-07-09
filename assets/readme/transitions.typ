// typst compile --root . --ppi 300 assets/readme/transitions.typ assets/readme/transitions.png
#import "../../src/lib.typ": *
#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#std.stack(
  dir: ttb,
  spacing: 1.6em,
  std.stack(spacing: 0.5em, align(left)[*BST insert* — search path, then the new node],
    {
      let b = bst(50, 30, 70, 20, 40)
      let step = (b.insert)(45)
      step.diagram
    }),
  std.stack(spacing: 0.5em, align(left)[*AVL double rotation* — unbalanced, inner rotation, outer rotation],
    {
      let a = avl(30, 10)
      let step = (a.insert)(20, rebalance: (enabled: true, all-steps: true))
      step.diagram
    }),
)
