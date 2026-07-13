// typed-dsa visual showcase
//
// Compile with:
//   typst compile --root . docs/showcase.typ docs/showcase.pdf

#import "../src/lib.typ": *
#import "@preview/algo:0.3.6": algo, i, d

#let ink = rgb("#263238")
#let muted = rgb("#607D8B")
#let blue = rgb("#1565C0")
#let blue-soft = rgb("#E3F2FD")
#let green = rgb("#2E7D32")
#let green-soft = rgb("#E8F5E9")
#let amber = rgb("#F9A825")
#let amber-soft = rgb("#FFF8E1")
#let red = rgb("#C62828")
#let red-soft = rgb("#FFEBEE")
#let purple = rgb("#7B3FA1")
#let purple-soft = rgb("#F3E5F5")
#let rust = rgb("#C75B12")

#set page(paper: "a4", margin: (x: 1.6cm, y: 1.55cm))
#set text(font: "New Computer Modern", size: 10pt, fill: ink)
#set par(leading: 0.62em, spacing: 0.75em)

#let panel(title, body) = block(
  width: 100%,
  fill: white,
  stroke: 0.6pt + luma(220),
  radius: 7pt,
  inset: 12pt,
  breakable: false,
  {
    text(size: 11.5pt, weight: "bold", fill: blue)[#title]
    v(0.7em)
    align(center, body)
  },
)

#let example-card(src, body) = grid(
  columns: (0.34fr, 0.66fr),
  column-gutter: 12pt,
  align: horizon,
  block(
    width: 100%,
    fill: luma(248),
    stroke: 0.5pt + luma(225),
    radius: 4pt,
    inset: 8pt,
    {
      set text(size: 7.2pt)
      src
    },
  ),
  align(center + horizon, scale(82%, reflow: true, body)),
)

#let algorithm-card(pseudocode, body) = grid(
  columns: (0.34fr, 0.66fr),
  column-gutter: 0pt,
  align: horizon,
  align(center + horizon, pseudocode),
  align(center + horizon, scale(82%, reflow: true, body)),
)

#let pseudocode(title, body) = algo(
  title: title,
  line-numbers: true,
  indent-size: 10pt,
  row-gutter: 10pt,
  column-gutter: 10pt,
  inset: 6pt,
  fill: luma(248),
  stroke: 2pt + luma(225),
  radius: 4pt,
  block-align: none,
  main-text-styles: (size: 11pt),
  line-number-styles: (size: 6.5pt, fill: muted),
)[#body]

#let step-trace(steps, columns: 2, column-gutter: -120pt, frame-scale: 100%) = {
  let frames = ()
  for (index, step) in steps.enumerate() {
    frames.push(scale(frame-scale, reflow: true, align(center)[
      #text(size: 6.4pt, fill: muted, weight: "bold")[Step #(index + 1)]
      #v(0.12em)
      #step.diagram
    ]))
  }
  grid(
    columns: columns,
    column-gutter: column-gutter,
    row-gutter: 3em,
    ..frames,
  )
}

#let diagram-row(..items) = grid(
  columns: items.pos().map(_ => 1fr),
  column-gutter: 12pt,
  row-gutter: 12pt,
  ..items,
)

#let tree-style = (
  node-shape: "square",
  node-radius: 0.34,
  x-gap: 1.08,
  y-gap: 1.5,
  node-fill: blue-soft,
  node-stroke: 0.9pt + blue,
  node-text: (size: 9pt, color: rgb("#0D47A1"), weight: "bold"),
  edge-stroke: 0.85pt + rgb("#37474F"),
  edge-pattern: "normal",
  edge-wave-amplitude: 0.055,
  edge-wave-step: 0.14,
  scale: 0.4,
  new-style: (shape: "square", fill: green-soft, stroke: 1.2pt + green, text: (color: green, weight: "bold")),
  path-style: (fill: rgb("#FFE082"), stroke: 1.1pt + amber, text: (color: rgb("#6D4C00"), weight: "bold")),
  remove-style: (fill: red-soft, stroke: 1.1pt + red, text: (color: red, weight: "bold")),
  rotate-style: (fill: purple-soft, stroke: 1.2pt + purple, node-radius: 0.38, text: (color: purple, weight: "bold")),
)

#let tree-style2 = tree-style + (scale : 0.96, node-shape : "circle")


#let heap-style = tree-style + (
  node-fill: rgb("#FFFDF7"),
  node-stroke: 0.9pt + rust,
  node-text: (size: 9pt, color: rgb("#5D2F00"), weight: "bold"),
  edge-stroke: 0.85pt + rgb("#6D4C41"),
  scale: 0.93,
  path-style: (fill: blue-soft, stroke: 1.2pt + blue, text: (color: blue, weight: "bold")),
  new-style: (shape: "square", fill: green-soft, stroke: 1.2pt + green, text: (color: green, weight: "bold")),
  remove-style: (fill: red-soft, stroke: 1.2pt + red, text: (color: red, weight: "bold")),
)

#let linear-style = (
  box-w: 0.92,
  box-h: 0.62,
  box-gap: 0.42,
  box-fill: rgb("#FAFCFF"),
  box-stroke: 0.85pt + rgb("#455A64"),
  ptr-fill: green-soft,
  prev-ptr-fill: red-soft,
  next-ptr-fill: green-soft,
  node-text: (size: 8.5pt, color: ink, weight: "bold"),
  label-text: (size: 7.2pt, color: muted, weight: "bold"),
  scale: 1.03,
  new-style: (fill: green-soft, stroke: 1pt + green, text: (color: green, weight: "bold")),
  path-style: (fill: amber-soft, stroke: 1pt + amber, text: (color: rgb("#6D4C00"), weight: "bold")),
  remove-style: (fill: red-soft, stroke: 1pt + red, text: (color: red, weight: "bold")),
)

#let graph-style = (
  node-shape: "square",
  node-radius: 0.31,
  node-fill: rgb("#FAFCFF"),
  node-stroke: 0.85pt + rgb("#37474F"),
  node-text: (size: 8.5pt, color: ink, weight: "bold"),
  edge-stroke: 0.75pt + rgb("#455A64"),
  edge-arrow: "end",
  edge-arrow-fill: rgb("#455A64"),
  label-text: (size: 7.2pt, color: muted, weight: "bold"),
  scale: 1.05,
)

#let btree-style = (
  node-shape: "square",
  node-radius: 0.56,
  x-gap: 1.55,
  y-gap: 1.5,
  node-fill: amber-soft,
  node-stroke: 0.95pt + amber,
  node-text: (size: 8.8pt, color: rgb("#4E342E"), weight: "bold"),
  edge-stroke: 0.75pt + rgb("#546E7A"),
  label-text: (size: 7.3pt, color: muted, weight: "bold"),
  scale: 0.78,
)

#let grid-style = (
  box-w: 0.72,
  box-h: 0.58,
  box-gap: 0.06,
  box-fill: rgb("#F8FBFF"),
  box-stroke: 0.72pt + blue,
  node-text: (size: 8.1pt, color: rgb("#0D47A1"), weight: "bold"),
  label-text: (size: 7.2pt, color: muted, weight: "bold"),
  scale: 1.08,
)

#align(center)[
  #text(size: 27pt, weight: "bold", fill: blue)[typed-dsa showcase]
  #v(0.25em)
  #text(size: 11pt, fill: muted)[A deliberately over-styled pass through the package's main diagram families.]
]

#v(1em)

#panel([Trees and AVL transitions],
  {
    let a = avl(
      50, 30, 70, 20, 40,
      style: tree-style,
      edge-customizations: (
        (30, 10, (pattern: "dashed", color: purple)),
        (10, 20, (pattern: "wavy", color: blue)),
      ),
    )
    let b = bst(
      50, 30, 70, 20, 40, 60, 80,
      style: tree-style2,
      edge-customizations: (
      ),
    )
    let c = bst(
      50, 30, 70, 20, 40, 60, 80,
      style: tree-style2 + (
        path-style: (fill: rgb("#FFE082"), stroke: 1.4pt + amber, text: (color: rgb("#6D4C00"), weight: "bold")),
      ),
      edge-customizations: (
        (30, 40, (pattern: "wavy", color: purple)),
      ),
    )
    std.stack(spacing: 4em,
      example-card(
        ```typ
        #let a = avl(50, 30, 70, 20, 40,
          style: your-style)
        #(a.insert)(35, rebalance: (enabled: true, all-steps: true)).diagram
        ```,
        (a.insert)(35, rebalance: (enabled: true, all-steps: true)).diagram,
      ),
      example-card(
        ```typ
        #let b = bst(50, 30, 70, 20, 40, 60, 80,
          style: your-style)
        #(b.delete)(30).diagram
        ```,
        (b.delete)(30).diagram,
      ),
      example-card(
        ```typ
        #let c = bst(50, 30, 70, 20, 40, 60, 80,
          style: your-style)
        #(c.search)(60).diagram
        ```,
        (c.search)(60).diagram,
      ),
    )
  }
)

#v(0.8em)

#panel([Multiway trees and table-like structures],
  {
    let btree = tree(
      node([20 | 40], children: (
        node([5 | 10], children: (
          node([2]),
          node([7]),
          node([15]),
        )),
        node([25 | 30], children: (
          node([22]),
          node([27]),
          node([35]),
        )),
        node([50 | 60], children: (
          node([45]),
          node([55]),
          node([70]),
        )),
      )),
      style: btree-style,
    )
    let btree2 = tree(
      node([35], children: (
        node([12 | 18], children: (
          node([4 | 9]),
          node([14 | 16]),
          node([22 | 28]),
        )),
        node([55 | 72], children: (
          node([41 | 48]),
          node([60 | 67]),
          node([80 | 91]),
        )),
      )),
      style: btree-style + (
        node-fill: rgb("#F3FAF5"),
        node-stroke: 0.95pt + green,
        node-text: (color: green, weight: "bold"),
        edge-stroke: 0.75pt + rgb("#455A64"),
      ),
    )
    std.stack(spacing: 2.8em,
      example-card(
        ```typ
        #tree(
          node([20 | 40], children: (
            node([5 | 10], children: (...)),
            node([25 | 30], children: (...)),
            node([50 | 60], children: (...)),
          )),
          style: your-style,
        )
        ```,
        btree,
      ),
      example-card(
        ```typ
        #tree(
          node([35], children: (
            node([12 | 18], children: (...)),
            node([55 | 72], children: (...)),
          )),
          style: your-style,
        )
        ```,
        btree2,
      ),
    )
  },
)

#v(0.8em)

#panel([Arrays and matrices],
  {
    let arr = array-view(
      8, 13, 21, 34, 55, 89, 144, 233, 377,
      style: grid-style + (
        box-w: 0.68,
        box-fill: rgb("#F8FBFF"),
        box-stroke: 0.75pt + blue,
        indices: (enabled: true, size: 6.8pt, color: muted, weight: "bold"),
      ),
      cell-customizations: (
        (4, (fill: amber-soft, stroke: 1.15pt + amber, text: (color: rgb("#6D4C00")))),
        (5, (fill: amber-soft, stroke: 1.15pt + amber, text: (color: rgb("#6D4C00")))),
      ),
    )
    let mat = matrix(
      (
        (0, 4, 8, 12, 16),
        (3, 0, 5, 9, 13),
        (7, 2, 0, 6, 10),
        (11, 6, 1, 0, 4),
        (15, 10, 5, 2, 0),
      ),
      row-labels: ([A], [B], [C], [D], [E]),
      column-labels: ([A], [B], [C], [D], [E]),
      style: grid-style + (
        box-fill: rgb("#FFFDF7"),
        box-stroke: 0.65pt + rgb("#6D4C41"),
        node-text: (color: rgb("#4E342E"), weight: "bold"),
        scale: 0.96,
      ),
      cell-customizations: (
        ((0, 0), (fill: green-soft, stroke: 1pt + green, text: (color: green))),
        ((1, 1), (fill: green-soft, stroke: 1pt + green, text: (color: green))),
        ((2, 2), (fill: green-soft, stroke: 1pt + green, text: (color: green))),
        ((3, 3), (fill: green-soft, stroke: 1pt + green, text: (color: green))),
        ((4, 4), (fill: green-soft, stroke: 1pt + green, text: (color: green))),
      ),
    )
    std.stack(spacing: 2.6em,
      example-card(
        ```typ
        #array-view(
          8, 13, 21, 34, 55, 89, 144, 233, 377,
          style: your-style + (indices: (enabled: true)),
          cell-customizations: ((4, pivot-style), (5, pivot-style)),
        )
        ```,
        arr.diagram,
      ),
      example-card(
        ```typ
        #matrix(
          ((0, 4, 8, 12, 16), ...),
          row-labels: ([A], [B], [C], [D], [E]),
          column-labels: ([A], [B], [C], [D], [E]),
          style: your-style,
        )
        ```,
        mat.diagram,
      ),
    )
  },
)

#v(0.8em)

#align(left)[
  #text(size: 16pt, weight: "bold", fill: blue)[Sorting algorithms: pseudocode and traces]
  #v(0.25em)
  #text(fill: muted)[Each trace uses a small array and shows every generated step.]
]

#v(0.7em)

#panel([Bubble sort], algorithm-card(
  pseudocode("Bubble sort")[
    for $p <- 0$ to $n - 2$:#i\
    for $j <- 0$ to $n - p - 2$:#i\
    if $A_j > A_(j + 1)$:#i\
    swap $A_j$ and $A_(j + 1)$#d#d#d
  ],
  step-trace(bubble-sort((3, 1, 2), pointers: true).steps),
))

#v(0.7em)

#panel([Insertion sort], algorithm-card(
  pseudocode("Insertion sort")[
    for $i <- 1$ to $n - 1$:#i\
    $k <- A[i]$\
    $j <- i$\
    while $j > 0$ and $A[j] < A[j - 1]$:#i\
    swap $A[j]$ and $A[j - 1]$\
    $j <- j - 1$#d#d
  ],
  step-trace(insertion-sort((3, 1, 2), pointers: true).steps),
))

#v(0.7em)

#panel([Selection sort], algorithm-card(
  pseudocode("Selection sort")[
    for $i <- 0$ to $n - 1$:#i\
    $m <- i$\
    for $j <- i + 1$ to $n - 1$:#i\
    if $A[j] < A[m]$:#i\
    $m <- j$#d#d\
    swap $A[i]$ and $A[m]$#d
  ],
  step-trace(selection-sort((3, 1, 2), pointers: true).steps),
))

#v(0.7em)

#panel([Merge operation], algorithm-card(
  pseudocode("Merge")[
    $i <- 0$; $j <- 0$; $M <- ()$\
    while $i < |L|$ and $j < |R|$:#i\
    if $L_i <= R_j$:#i\
    append $L_i$ to $M$; $i <- i + 1$#d\
    else:#i\
    append $R_j$ to $M$; $j <- j + 1$#d#d\
    append remaining $L$ and $R$ to $M$\
    return $M$
  ],
  {
    let trace = merge-operation((1,), (2,), pointers: true)
    step-trace(trace.steps, columns: 1)
  },
))

#v(0.7em)

#panel([Quick sort: last-pivot partition], {
  let trace = partition-step((5, 1, 4, 2, 3), pivot: "last", pointers: true)
  std.stack(
    dir: ttb,
    spacing: 0.45em,
    align(center)[
      #pseudocode("Last-pivot partition")[
        $p <- A_(n - 1)$\
        $i <- 0$\
        for $j <- 0$ to $n - 2$:#i\
        if $A_j <= p$:#i\
        swap $A_i$ and $A_j$\
        $i <- i + 1$#d#d\
        swap $A_i$ and $A_(n - 1)$
      ]
    ],
    step-trace(trace.steps, columns: 3, column-gutter: 16pt, frame-scale: 80%),
  )
})

#v(0.8em)

#panel([Heaps with sift paths],
  {
    let h1 = min-heap(10, 20, 15, 40, 50, 30, style: heap-style)
    let h2 = max-heap(50, 30, 70, 20, 40, 60, 80, style: heap-style + (diff-colors: true, edge-pattern: "dotted"))
    std.stack(spacing: 3em,
      example-card(
        ```typ
        #let h = min-heap(10, 20, 15, 40, 50, 30,
          style: your-style)
        #(h.insert)(5).diagram
        ```,
        (h1.insert)(5).diagram,
      ),
      example-card(
        ```typ
        #let h = max-heap(50, 30, 70, 20, 40, 60, 80,
          style: your-style)
        #(h.extract)().diagram
        ```,
        (h2.extract)().diagram,
      ),
    )
  }
)

#v(0.8em)

#panel([Linked structures],
  {
    let l = linked-list(
      [A], [B], [C], [D],
      pointer: true,
      head: true,
      addresses: ("0x10", "0x18", "0x20", "0x28"),
      style: linear-style + (scale: 0.98),
    )
    let d = doubly-linked-list(
      15, 3, 17, 90,
      pointer: true,
      head: true,
      addresses: ("3200", "3600", "4000", "4400"),
      style: linear-style + (
        box-fill: rgb("#FFFDF7"),
        box-stroke: 0.85pt + rgb("#6D4C41"),
        label-text: (size: 7pt, color: rgb("#6D4C41"), weight: "bold"),
        scale: 0.92,
      ),
    )
    std.stack(spacing: 3em, l.diagram, d.diagram)
  }
)

#v(0.8em)

#panel([Stack and queue workflows],
  diagram-row(
    {
      let s = stack([top], [mid], [base], style: linear-style + (box-w: 1.12, box-gap: 0.12))
      std.stack(spacing: 0.8em, s.diagram, (s.push)([new]).diagram)
    },
    {
      let q = queue(
        3, 4, 5,
        enqueue: 6,
        dequeue: 2,
        front-label: text(fill: blue)[*Front*],
        rear-label: text(fill: rust)[*Rear*],
        style: linear-style + (box-w: 0.78, box-gap: 0.3),
      )
      std.stack(spacing: 0.8em, q.diagram, (q.enqueue)(7).diagram)
    },
  )
)

#v(0.8em)

#panel([Weighted graph with custom edge labels],
  {
    let g = graph(
      (
        "S": (("A", [7]), ("B", [2])),
        "A": (("C", [3]),),
        "B": (("A", [1]), ("D", [5])),
        "C": (("T", [4]),),
        "D": (("C", [2]), ("T", [6])),
        "T": (),
      ),
      directed: true,
      layout: "manual",
      labels: (
        "S": text(fill: green)[*S*],
        "A": $a_1$,
        "B": $b_1$,
        "C": $c_1$,
        "D": text(fill: purple)[*D*],
        "T": text(fill: red)[*T*],
      ),
      positions: (
        "S": (0, 0),
        "A": (rel: "S", offset: (2.25, 1.35)),
        "B": (rel: "S", offset: (2.25, -1.35)),
        "C": (rel: "A", offset: (2.55, 0.0)),
        "D": (rel: "B", offset: (2.55, 0.0)),
        "T": (rel: "S", offset: (7.2, 0.0)),
      ),
      edge-customizations: (
        ("S", "A", (stroke: 1.2pt + green, label: (color: green, weight: "bold"))),
        ("S", "B", (stroke: 1.2pt + blue, label: (rotation: "edge", color: blue))),
        ("B", "A", (bend: "right", angle: 35deg, pattern: "dashed", color: purple, label: (size: 8pt, color: purple))),
        ("D", "T", (stroke: 1.2pt + red, arrow: "both", label: (color: red, weight: "bold"))),
      ),
      style: graph-style,
    )
    g.diagram
  },
)

#v(0.8em)

#panel([Hand-composed rotation schematic],
  {
    let blue2 = rgb("#1E73BE")
    let purple2 = rgb("#7B3FA1")
    let green2 = rgb("#2E7D32")
    let rot-style = tree-style + (
      node-fill: white,
      node-stroke: 0.85pt + ink,
      edge-arrow: none,
      tri-w: 1.1,
      tri-h: 1.2,
      scale: 1.05,
    )
    let ta = subtree($T_A$, fill: blue2, scale: 1.02)
    let tb = subtree($T_B$, fill: purple2)
    let tc = subtree($T_C$, fill: green2)
    let before = tree(
      node(text(fill: rust)[$x$], left: node(text(fill: red)[$y$], left: ta, right: tb), right: tc),
      style: rot-style,
    )
    let after = tree(
      node(text(fill: red)[$y$], left: ta, right: node(text(fill: rust)[$x$], left: tb, right: tc)),
      style: rot-style,
    )
    std.stack(dir: ltr, spacing: 1.5em,
      before,
      align(horizon, std.stack(spacing: 0.55em,
        text(size: 10.5pt, weight: "bold")[rotate $x$ right],
        text(size: 22pt)[$arrow.r.long$],
        text(size: 22pt)[$arrow.l.long$],
        text(size: 10.5pt, weight: "bold")[rotate $y$ left],
      )),
      after,
    )
  },
)
