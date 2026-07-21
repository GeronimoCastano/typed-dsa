// typst compile --root . --ppi 300 assets/readme/hash-tables.typ assets/readme/hash-tables.png
#import "../../src/lib.typ": *
#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#table(
  columns: (auto, auto),
  column-gutter: 3em,
  align: center + horizon,
  stroke: none,
  [*Separate chaining*], [*Linear probing*],
  hash-table(1, 6, 11, size: 5, collision: "chaining").diagram,
  hash-table(1, 6, 11, size: 5, collision: "linear").diagram,
)
