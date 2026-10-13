#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: 0.45cm)
#set text(size: 9pt)

= D01 · Bent tree edge
#bst(5, 3, edge-customizations: ((5, 3, (bend: "left")),)).diagram

#pagebreak()
= D02 · Layered shortcut edge
#graph(("S": ("A", "B"), "A": ("B",), "B": ()), layout: "layered").diagram

#pagebreak()
= D10 · Wide tree labels
#bst(50, 30, 70, node-labels: ((50, [WWWW]), (30, [mm]))).diagram

#pagebreak()
= D11 · Large tree nodes and tight graph layout
#tree(node(1, left: node(2), right: node(3, left: node(4), right: node(5))), style: (node-radius: 0.6))
#graph(("A": ("B",), "B": ()), layout: "linear", style: (node-radius: 0.8)).diagram
#graph(("A": ("B",), "B": ()), layout: "linear", node-customizations: (("A", (node-radius: 2.0)),)).diagram
#graph(("A": ("B",), "B": ()), layout: "layered", style: (node-radius: 0.8)).diagram
#graph(("A": (), "B": ()), layout: "force", node-customizations: (("A", (node-radius: 2.0)), ("B", (node-radius: 2.0)))).diagram

#pagebreak()
= D12 · Subtree height bracket
#tree(node(0, left: node(2), right: subtree("T", height: [h])))
#tree(node(0, left: node(2), right: subtree("T", height: [a very wide height label])))

#pagebreak()
= D13 · Dark-theme subtree labels
#block(fill: rgb("#111827"), inset: 0.45cm)[
  #tree(node(1, left: subtree("TA", height: [h]), right: node(3)), style: theme-preset("dark"))
]

#pagebreak()
= D16 · Inserted node during AVL rotation
#transition("avl", (20, 10, 30, 40), tree-insert(50))

#pagebreak()
= D17 · Reciprocal edges use opposite physical sides
#graph(("A": (("B", [ab]),), "B": (("A", [ba]),)), layout: "manual", positions: ("A": (0, 0), "B": (3, 0)), edge-routing: "auto", edge-customizations: (("A", "B", (bend: "right", angle: 30deg)),)).diagram
#graph(("A": (("B", [weight]),), "B": ()), layout: "manual", positions: ("A": (0, 0), "B": (3, 0)), edge-customizations: (("A", "B", (bend: true)),)).diagram

#pagebreak()
= D18 · Enlarged graph node and edge label
#graph(("A": (("B", [weight]),), "B": ()), layout: "linear", node-customizations: (("A", (node-radius: 2.0)),)).diagram

#pagebreak()
= D19 · Layered layout with absolute override
#graph(("S": ("A", "M"), "A": ("T",), "M": ("T",), "T": ()), layout: "layered", positions: ("M": (3, 1))).diagram

#pagebreak()
= D20 · Empty graph
#graph((:)).diagram

#pagebreak()
= D22 · Dijkstra with a supplied node label
#dijkstra(("S": (("A", 4), ("B", 1)), "B": (("A", 2),), "A": ()), "S", node-labels: ("A": [note])).steps.last().diagram

#pagebreak()
= D23 · Dijkstra distance and edge labels
#dijkstra(("S": (("A", 4), ("B", 1)), "B": (("A", 2),), "A": ()), "S").steps.last().diagram

#pagebreak()
= D24 · Iterative depth-first search visitation
#dfs(("S": ("A", "C"), "A": ("C", "D"), "C": (), "D": ()), "S").diagram

#pagebreak()
= D40 · Tree child-array validation
#tree(node("A", children: (node("B"), node("C"))))

#pagebreak()
= D41 · Hexagon boundary trimming
#graph(("A": ("B",), "B": ()), layout: "manual", positions: ("A": (0, 0), "B": (3, 1)), style: (node-shape: "hexagon", node-radius: 0.5)).diagram

#pagebreak()
= D45 · Tree slant and height label clearance
#tree(node("0", left: subtree("L"), right: node("1", left: node("2"), right: subtree("R", height: [h]))))

#pagebreak()
= D48 · Targeted Dijkstra early stop
#dijkstra(("S": (("T", 1), ("Y", 50), ("X", 100)), "Y": (("X", 10),), "T": (), "X": ()), "S", target: "T").steps.last().diagram

#pagebreak()
= D21 · Bare-color traversal state styles
#bfs(("A": ("B",), "B": ()), "A", style: (visited-style: rgb("#C8E6C9"))).steps.last().diagram
