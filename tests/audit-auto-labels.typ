#import "../src/lib.typ": *

#set page(width: 18cm, height: auto, margin: 14pt)
#set text(size: 10pt)

= Automatic external label placement

The first panel reproduces audit finding D23 with the original graph and call.
The second requests the automatic position explicitly. The fixed-position panel
shows that caller-selected sides and angles remain available.

#grid(
  columns: 2,
  column-gutter: 2em,
  [*D23 reproduction: default Dijkstra distances*\
  #dijkstra(("S": (("A", 4), ("B", 1)), "B": (("A", 2),), "A": ()), "S").steps.last().diagram],
  [*Explicit automatic distance placement*\
  #dijkstra(
    ("S": (("A", 4), ("B", 1)), "B": (("A", 2),), "A": ()), "S",
    style: (node-labels: (position: "auto")),
  ).steps.last().diagram],
)

#pagebreak()

== Crowded center node and explicit diagonals

Four nearby nodes occupy the center node's cardinal label rectangles. Automatic
placement has to choose a diagonal around those actual graph nodes.

#align(center)[
  #graph(
    ("A": (), "N": (), "E": (), "S": (), "W": ()),
    layout: "manual",
    positions: (
      "A": (0, 0), "N": (0, 0.72), "E": (0.72, 0),
      "S": (0, -0.72), "W": (-0.72, 0),
    ),
    node-labels: ("A": (content: [$d=3$], position: "auto")),
    style: (node-radius: 0.25, node-labels: (gap: 0.15)),
  ).diagram
]

All four diagonal names are available for fixed placement:

#grid(
  columns: 2,
  column-gutter: 2em,
  row-gutter: 0.8em,
  [#graph(("A": ()), node-labels: ("A": (content: [top-right], position: "top-right"))).diagram],
  [#graph(("A": ()), node-labels: ("A": (content: [top-left], position: "top-left"))).diagram],
  [#graph(("A": ()), node-labels: ("A": (content: [bottom-right], position: "bottom-right"))).diagram],
  [#graph(("A": ()), node-labels: ("A": (content: [bottom-left], position: "bottom-left"))).diagram],
)

#pagebreak()

#v(1em)
#grid(
  columns: 2,
  column-gutter: 2em,
  [*Tree annotations: automatic by default*\
  #bst(
    50, 30, 70, 20, 40, 60, 80,
    node-labels: (
      (50, [root]), (30, [left]), (70, [right]),
      (20, [leaf]), (60, [inner]),
    ),
    style: (x-gap: 1.25, y-gap: 1.3),
  ).diagram],
  [*Caller-controlled placements*\
  #graph(
    ("A": ("B",), "B": ()),
    layout: "manual", positions: ("A": (0, 0), "B": (2, 0)),
    node-labels: (
      "A": (content: [fixed angle], position: 45deg),
      "B": (content: [fixed side], position: "bottom"),
    ),
  ).diagram],
)

#v(1em)
#grid(
  columns: 2,
  column-gutter: 2em,
  [*BFS external annotations*\
  #bfs(
    ("S": ("A", "B"), "A": ("C",), "B": ("C",), "C": ()), "S",
    node-labels: ("A": [parent: S], "B": [parent: S], "C": [distance: 2]),
  ).steps.last().diagram],
  [*DFS external annotations*\
  #dfs(
    ("S": ("A", "B"), "A": ("C",), "B": ("C",), "C": ()), "S",
    node-labels: ("A": [depth: 1], "B": [depth: 1], "C": [depth: 2]),
  ).steps.last().diagram],
)
