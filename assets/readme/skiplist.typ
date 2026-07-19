// typst compile --root . --ppi 300 assets/readme/skiplist.typ assets/readme/skiplist.png
#import "../../src/lib.typ": *
#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#let l = skip-list(1, 2, 3, 4, 5, 6)

#std.stack(
  dir: ttb,
  spacing: 1.2em,
  std.stack(spacing: 0.5em, align(left)[*Search* highlights the top-down path],
    (l.search)(4).diagram),
  std.stack(spacing: 0.5em, align(left)[*Insert* only marks the new node (green)],
    (l.insert)(7).diagram),
)
