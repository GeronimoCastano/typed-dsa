// typst compile --root . --ppi 300 assets/readme/heaps.typ assets/readme/heaps.png
#import "../../src/lib.typ": *
#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#table(
  columns: (auto, auto),
  column-gutter: 2em,
  align: center + horizon,
  stroke: none,
  [*Min heap*], [*Max heap*],
  min-heap(50, 30, 70, 20, 40, 60, 80).diagram,
  max-heap(50, 30, 70, 20, 40, 60, 80).diagram,
)
