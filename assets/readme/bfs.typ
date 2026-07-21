// typst compile --root . --ppi 300 assets/readme/bfs.typ assets/readme/bfs.png
#import "../../src/lib.typ": *
#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#bfs(
  (
    "S": ("A", "B"),
    "A": ("T",),
    "B": ("T",),
    "T": (),
  ),
  "S",
  target: "T",
  columns: 3,
  style: graph-style(scale: 0.65),
).diagram
