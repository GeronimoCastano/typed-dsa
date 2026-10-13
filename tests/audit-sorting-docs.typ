#import "../src/lib.typ": *

#set page(width: 16cm, height: auto, margin: 8pt)
#set text(font: "New Computer Modern", size: 10pt)

#let repro(title, body) = block(below: 1em)[
  #strong(title)
  #v(0.4em)
  #body
]

= Sorting and grid audit examples

#repro("D08 — source indices stay global across merge-sort subarrays", merge-sort((38, 27, 43, 3, 9)).diagram)

#pagebreak()
#repro("D08 — quick-sort partition rows preserve source positions", quick-sort((38, 27, 43, 3, 9), pivot: "last").diagram)

#pagebreak()
#repro("D25 — the supported last-pivot variant renders cursor arrows", partition-step((7, 2, 9, 3, 6), pivot: "last", pointers: true).diagram)

#pagebreak()
#repro("D27 — explicit true enables default indices; false hides them", grid(
  columns: 2, column-gutter: 1em,
  array-view(4, 1, 7, style: (indices: true)).diagram,
  array-view(4, 1, 7, style: (indices: false)).diagram,
))

#pagebreak()
#repro("D30 — rotated operation captions render in the sequence", {
  let tree = bst(5, 3, 8)
  let inserted = (tree.insert)(6)
  sequence(inserted, mode: "after", style: (operation-text: (rotation: 12deg)))
})

#pagebreak()
#repro("D33 — compact modes show one state per operation", {
  let initial = bst(50, 30, 70, 20, 40)
  let inserted = (initial.insert)(60)
  let deleted = (inserted.result.delete)(30)
  grid(
    columns: 1,
    sequence(inserted, deleted, mode: "before", columns: 3),
    sequence(inserted, deleted, mode: "after", columns: 3),
    sequence(inserted, deleted, mode: "result", columns: 3),
  )
})

#pagebreak()
#repro("D36 — merge-operation adapts to a 16 cm page without merging cells", merge-operation((1, 4, 6, 9, 12, 15), (2, 3, 7, 8, 10)).diagram)

#pagebreak()
#repro("D42 — stripes stay within rounded and capsule cell outlines", grid(
  columns: 2, column-gutter: 1em,
  array-view(4, 1, 7, style: (box-shape: "rounded"), cell-customizations: ((0, (stripe-fill: rgb("#C4B5FD"))),)).diagram,
  array-view(4, 1, 7, style: (box-shape: "capsule"), cell-customizations: ((0, (stripe-fill: rgb("#C4B5FD"))),)).diagram,
))

#pagebreak()
#repro("D48 — merge-operation keeps each input's own array style", merge-operation(
  array-view(1, 4, 7, style: (box-fill: rgb("#DDEBFF"), node-text: (fill: blue))),
  array-view(2, 3, 8, style: (box-fill: rgb("#FCE1EA"), node-text: (fill: red))),
).diagram)

#pagebreak()
#repro("D49 — nonempty matrices render; empty rows have a targeted diagnostic", matrix(((1, 2), (3, 4))).diagram)
