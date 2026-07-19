// typst compile --root . --ppi 300 assets/readme/graphs.typ assets/readme/graphs.png
#import "../../src/lib.typ": *
#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#table(
  columns: (auto, auto, auto),
  column-gutter: 2em,
  align: center + horizon,
  stroke: none,
  [*Automatic circle layout*], [*Linear layout*], [*Manual layout*],
  graph(("v1": ("v2", "v3"), "v2": ("v3",), "v3": ())).diagram,
  graph(
    ("v1": ("v2",), "v2": ("v3",), "v3": ("v4",), "v4": ()),
    layout: "linear",
  ).diagram,
  graph(
    ("v1": ("v2", "v3"), "v2": ("v4",), "v3": ("v4",), "v4": ()),
    layout: "manual",
    positions: (
      "v1": (0, 0),
      "v2": (rel: "v1", offset: (1.4, 0.8)),
      "v3": (rel: "v1", offset: (1.4, -0.8)),
      "v4": (rel: "v2", offset: (1.4, -0.8)),
    ),
  ).diagram,
)
