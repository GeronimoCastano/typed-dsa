// typed-dsa documentation
//
// Compile with:
//   typst compile --root . docs/documentation.typ docs/documentation.pdf

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "../src/lib.typ": *

#let version = "0.1.0"
#let accent = rgb("#1565C0")
#let accent-soft = rgb("#E3F2FD")

// ── Theme ────────────────────────────────────────────────────────────────────

#set document(title: "typed-dsa User Guide", author: "Geronimo Castaño")
#set text(font: "New Computer Modern", size: 10.5pt, lang: "en")
#set par(justify: true, leading: 0.62em, spacing: 1.1em)
#set heading(numbering: "1.1")
#show link: set text(fill: accent)
#show ref: set text(fill: accent)

// Code blocks never split across a page.
#show raw.where(block: true): set block(breakable: false)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(width: 100%, breakable: false, sticky: true, {
    set text(fill: accent, size: 18pt, weight: "bold")
    if it.numbering != none [#counter(heading).display() #h(0.5em)]
    it.body
    v(-0.2em)
    line(length: 100%, stroke: 0.6pt + accent)
  })
}
#show heading.where(level: 2): it => block(above: 1.3em, below: 0.7em, sticky: true, {
  set text(fill: accent.darken(8%), size: 13pt, weight: "bold")
  if it.numbering != none [#counter(heading).display() #h(0.4em)]
  it.body
})
#show heading.where(level: 3): it => block(above: 1.1em, below: 0.6em, sticky: true, {
  set text(fill: accent.darken(18%), size: 11pt, weight: "bold")
  it.body
})

// ── codly ────────────────────────────────────────────────────────────────────

#show: codly-init.with()
#codly(
  languages: codly-languages,
  zebra-fill: none,
  inset: (x: 0.5em, y: 0.32em),
  radius: 0pt,
  stroke: none,
)

// ── Example helper: source on the left, live render on the right ─────────────

#let pkg-scope = (
  bst: bst, avl: avl, min-heap: min-heap, max-heap: max-heap,
  linked-list: linked-list, doubly-linked-list: doubly-linked-list, stack: stack, queue: queue,
  array-view: array-view, matrix: matrix, graph: graph,
  tree: tree, node: node, subtree: subtree,
  transition: transition,
  tree-insert: tree-insert, tree-delete: tree-delete, tree-search: tree-search,
  heap-insert: heap-insert, heap-extract: heap-extract,
  sequence: sequence, op-arrow: op-arrow, std: std,
)

#let example(body, side: true) = block(
  width: 100%,
  stroke: 0.6pt + luma(210),
  radius: 5pt,
  clip: true,
  breakable: false,
  {
    let rendered = block(
      width: 100%, fill: white, inset: (x: 12pt, y: 14pt),
      align(center + horizon, eval(body.text, mode: "markup", scope: pkg-scope)),
    )
    if side {
      grid(
        columns: (1.05fr, 0.95fr), column-gutter: 0pt,
        block(width: 100%, fill: luma(248), inset: (y: 4pt), body),
        block(width: 100%, stroke: (left: 0.6pt + luma(220)), rendered),
      )
    } else {
      block(width: 100%, fill: luma(248), inset: (y: 4pt), body)
      block(width: 100%, stroke: (top: 0.6pt + luma(220)), rendered)
    }
  },
)

// Keep a subsection's prose and example together on one page.
#let demo(body) = block(breakable: false, width: 100%, body)

#let callout(clr, label, body) = block(
  width: 100%, fill: clr.lighten(90%), stroke: (left: 2.5pt + clr),
  radius: (right: 4pt), inset: (x: 12pt, y: 9pt), above: 1.1em, below: 1.1em,
  { text(fill: clr, weight: "bold")[#label.#h(0.5em)]; body },
)
#let note(body) = callout(accent, "Note", body)
#let warn(body) = callout(rgb("#b54708"), "Note", body)

#let c(it) = {
  let code-breaks = (".", "[", "]", "-", "_", "/", ":", ",", "(", ")", "+", " ")
  text(font: "DejaVu Sans Mono", size: 0.7em, fill: rgb("#0B4F9C"))[
    #for ch in it.clusters() {
      ch
      if ch in code-breaks {
        sym.zws
      }
    }
  ]
}

// Argument-reference table shared by every function section.
#let argtable(..rows) = table(
  columns: (22%, 14%, 24%, 40%), inset: 5.4pt,
  align: (x, y) => if y == 0 { center + horizon } else { left + horizon },
  fill: (_, y) => if y == 0 { accent-soft }, stroke: 0.5pt + luma(210),
  [*Argument*], [*Type*], [*Default*], [*Description*],
  ..rows,
)

// Nested argument-reference table for dictionaries such as `style:` and
// `edge-customizations[].options`.
#let subargtable(title, ..rows) = block(width: 100%, above: 0.7em, below: 1.0em, {
  text(fill: accent.darken(18%), weight: "bold")[#title]
  v(0.35em)
  table(
    columns: (31%, 16%, 18%, 35%), inset: 5.2pt,
    align: (x, y) => if y == 0 { center + horizon } else { left + horizon },
    fill: (x, y) => if y == 0 { accent-soft } else if x == 0 { luma(248) } else { none },
    stroke: 0.5pt + luma(215),
    [*Path*], [*Type*], [*Default*], [*Description*],
    ..rows,
  )
})

#let text-style-reference(prefix, label: [Text styling]) = subargtable(label,
  [#c(prefix + ".size")], [`length`], [inherits], [Text size.],
  [#c(prefix + ".color")], [`color`], [inherits], [Text color.],
  [#c(prefix + ".rotation")], [`angle`], [`0deg`], [Text rotation applied by the diagram renderer.],
  [#c(prefix + ".font")], [`str` / `array`], [inherits], [Typst text font selection.],
  [#c(prefix + ".weight")], [`str` / `int`], [inherits], [Typst text weight.],
)

#let label-style-reference(prefix) = subargtable([Nested keys for #c(prefix)],
  [#c(prefix + ".size")], [`length`], [85% of #c("style.node-text.size")], [Label text size.],
  [#c(prefix + ".color")], [`color`], [#c("rgb(\"#555555\")")], [Label text color.],
  [#c(prefix + ".rotation")], [`angle` / `str`], [`0deg`], [Label rotation. Tree and graph edge labels also accept #c("\"edge\"") to follow the edge angle.],
  [#c(prefix + ".font")], [`str` / `array`], [inherits], [Typst text font selection.],
  [#c(prefix + ".weight")], [`str` / `int`], [inherits], [Typst text weight.],
)

#let mark-style-reference() = subargtable([Nested keys for diff-highlight dictionaries],
  [#c("style.new-style")], [`color` / `dictionary`], [#c("rgb(\"#C8E6C9\")")], [Node/cell added by an operation. A color is shorthand for #c("(fill: color)").],
  [#c("style.path-style")], [`color` / `dictionary`], [#c("rgb(\"#FFE9A8\")")], [Traversal or sift path.],
  [#c("style.remove-style")], [`color` / `dictionary`], [#c("rgb(\"#FFCDD2\")")], [Node/cell removed by an operation.],
  [#c("style.rotate-style")], [`color` / `dictionary`], [#c("rgb(\"#BBDEFB\")")], [AVL rotation nodes and visible subtree roots.],
  [#c("style.*-style.fill")], [`color`], [mark default], [Fill for the marked node/cell.],
  [#c("style.*-style.shape")], [`str`], [#c("style.node-shape")], [Marked tree/heap node shape: #c("\"circle\""), #c("\"square\""), #c("\"diamond\""), or #c("\"hexagon\"").],
  [#c("style.*-style.stroke")], [`stroke`], [normal stroke], [Marked node/cell outline.],
  [#c("style.*-style.node-radius")], [`float`], [#c("style.node-radius")], [Marked tree/heap node radius.],
  [#c("style.*-style.text")], [`dictionary`], [#c("style.node-text")], [Marked node/cell text overrides. Accepts #c("size"), #c("color"), #c("font"), and #c("weight").],
)

#let tree-style-reference(extra-subtree: false) = {
  subargtable([Nested keys for #c("style")],
    [#c("style.node-radius")], [`float`], [`0.34`], [Circle radius, or half the square/diamond/hexagon size, in canvas units.],
    [#c("style.node-shape")], [`str`], [`"circle"`], [#c("\"circle\""), #c("\"square\""), #c("\"diamond\""), or #c("\"hexagon\"").],
    [#c("style.x-gap")], [`float`], [`1.05`], [Horizontal spacing between in-order columns.],
    [#c("style.y-gap")], [`float`], [`1.2`], [Vertical spacing between depths.],
    [#c("style.node-stroke")], [`stroke`], [#c("0.6pt + rgb(\"#333333\")")], [Node outline.],
    [#c("style.node-fill")], [`color`], [`white`], [Default node fill.],
    [#c("style.edge-stroke")], [`stroke`], [#c("0.6pt + rgb(\"#333333\")")], [Parent-child edge stroke.],
    [#c("style.edge-arrow")], [`none` / `bool` / `str`], [`none`], [Edge arrowheads: #c("none")/#c("false"), #c("\"end\"") or #c("true"), #c("\"start\""), or #c("\"both\"").],
    [#c("style.edge-pattern")], [`str`], [`"normal"`], [#c("\"normal\""), #c("\"dashed\""), #c("\"dotted\""), or #c("\"wavy\"").],
    [#c("style.edge-wave-amplitude")], [`float`], [`0.07`], [Wave height in canvas units.],
    [#c("style.edge-wave-step")], [`float`], [`0.14`], [Approximate wavelength in canvas units.],
    [#c("style.node-text")], [`dictionary`], [#c("(size: 9pt)")], [Node text dictionary. See nested keys below.],
    [#c("style.label-text")], [`dictionary`], [#c("(fill: rgb(\"#555555\"))")], [Annotation text dictionary. See nested keys below.],
    [#c("style.scale")], [`float`], [`1.0`], [Uniform scale on #c(".diagram"), #c(".before"), and #c(".after").],
    [#c("style.diff-colors")], [`bool`], [`true`], [#c("false") keeps operation marks but uses normal fills.],
  )
  text-style-reference("style.node-text", label: [Nested keys for #c("style.node-text")])
  label-style-reference("style.label-text")
  if extra-subtree {
    subargtable([Nested subtree style keys],
      [#c("style.tri-w")], [`float`], [`1.2`], [Triangle base width before #c("subtree(scale:)").],
      [#c("style.tri-h")], [`float`], [`1.4`], [Triangle height before #c("subtree(scale:)").],
    )
  }
  mark-style-reference()
}

#let heap-style-reference() = tree-style-reference()

#let linear-style-reference(kind) = {
  subargtable([Nested keys for #c("style")],
    [#c("style.box-w")], [`float`], [`0.95`], [Cell width.],
    [#c("style.box-h")], [`float`], [`0.7`], [Cell height.],
    [#c("style.box-gap")], [`float`], [`0.55`], [Gap between cells or list nodes.],
    [#c("style.box-stroke")], [`stroke`], [#c("0.6pt + rgb(\"#333333\")")], [Cell outline.],
    [#c("style.box-fill")], [`color`], [`white`], [Default cell fill.],
    [#c("style.ptr-fill")], [`color`], [#c("rgb(\"#D7ECC9\")")], [Next-pointer cell fill for #c("linked-list(pointer: true)").],
    [#c("style.prev-ptr-fill")], [`color`], [#c("rgb(\"#D7ECC9\")")], [Previous-pointer cell fill for #c("doubly-linked-list(pointer: true)").],
    [#c("style.next-ptr-fill")], [`color`], [#c("rgb(\"#D7ECC9\")")], [Next-pointer cell fill for #c("doubly-linked-list(pointer: true)").],
    [#c("style.node-text")], [`dictionary`], [#c("(size: 9pt)")], [Cell text dictionary. See nested keys below.],
    [#c("style.label-text")], [`dictionary`], [#c("(fill: rgb(\"#555555\"))")], [Head, address, front, and rear label text dictionary. See nested keys below.],
    [#c("style.scale")], [`float`], [`1.0`], [Uniform scale on #c(".diagram"), #c(".before"), and #c(".after").],
    [#c("style.diff-colors")], [`bool`], [`true`], [#c("false") keeps operation marks but uses normal fills.],
  )
  text-style-reference("style.node-text", label: [Nested keys for #c("style.node-text")])
  label-style-reference("style.label-text")
  mark-style-reference()
}

#let graph-style-reference() = {
  subargtable([Nested keys for #c("style")],
    [#c("style.node-radius")], [`float`], [`0.34`], [Circle radius, or half the square/diamond/hexagon size, in canvas units.],
    [#c("style.node-shape")], [`str`], [`"circle"`], [#c("\"circle\""), #c("\"square\""), #c("\"diamond\""), or #c("\"hexagon\"").],
    [#c("style.node-stroke")], [`stroke`], [#c("0.6pt + rgb(\"#333333\")")], [Node outline.],
    [#c("style.node-fill")], [`color`], [`white`], [Default node fill.],
    [#c("style.edge-stroke")], [`stroke`], [#c("0.6pt + rgb(\"#333333\")")], [Default edge stroke.],
    [#c("style.edge-arrow")], [`none` / `bool` / `str`], [`none`], [Global arrowhead override: #c("none")/#c("false"), #c("\"end\"") or #c("true"), #c("\"start\""), or #c("\"both\""). #c("directed: true") uses #c("\"end\"") unless this overrides it.],
    [#c("style.edge-arrow-fill")], [`none` / `color`], [`none`], [#c("none") gives open arrowheads; a color fills arrowheads solid.],
    [#c("style.edge-pattern")], [`str`], [`"normal"`], [#c("\"normal\""), #c("\"dashed\""), #c("\"dotted\""), or #c("\"wavy\"").],
    [#c("style.edge-wave-amplitude")], [`float`], [`0.07`], [Wave height in canvas units.],
    [#c("style.edge-wave-step")], [`float`], [`0.14`], [Approximate wavelength in canvas units.],
    [#c("style.node-text")], [`dictionary`], [#c("(size: 9pt)")], [Node text dictionary. See nested keys below.],
    [#c("style.label-text")], [`dictionary`], [#c("(fill: rgb(\"#555555\"))")], [Edge label text dictionary. See nested keys below.],
    [#c("style.scale")], [`float`], [`1.0`], [Uniform scale on the rendered graph.],
  )
  text-style-reference("style.node-text", label: [Nested keys for #c("style.node-text")])
  label-style-reference("style.label-text")
}

#let edge-customizations-reference(label-options: false) = {
  subargtable([Nested keys for #c("edge-customizations")],
    [#c("edge-customizations[]")], [`tuple`], [n/a], [One #c("(from, to, options)") tuple. For trees, #c("from")/#c("to") are parent and child values; for graphs, node labels.],
    [#c("edge-customizations[].from")], [`content`], [required], [Source node identity.],
    [#c("edge-customizations[].to")], [`content`], [required], [Target node identity.],
    [#c("edge-customizations[].options")], [`dictionary`], [required], [Per-edge options.],
    [#c("edge-customizations[].options.stroke")], [`stroke`], [none], [Full stroke override. Wins over #c("color") if both are set.],
    [#c("edge-customizations[].options.color")], [`color`], [none], [Paint only, at the default thickness.],
    [#c("edge-customizations[].options.pattern")], [`str`], [`"normal"`], [#c("\"normal\""), #c("\"dashed\""), #c("\"dotted\""), or #c("\"wavy\"").],
    [#c("edge-customizations[].options.arrow")], [`none` / `bool` / `str`], [none], [Per-edge arrowheads: #c("none"), #c("\"end\"")/#c("true"), #c("\"start\""), or #c("\"both\"").],
    [#c("edge-customizations[].options.bend")], [`str` / `bool`], [`false`], [#c("\"left\"") or #c("\"right\"") curves the edge relative to its travel direction. #c("false") keeps it straight.],
    [#c("edge-customizations[].options.angle")], [`angle`], [`25deg`], [How sharply a bent edge curves. Ignored when #c("bend") is #c("false").],
    [#c("edge-customizations[].options.label")], [`content` / `dictionary`], [none], [Tree edge label content, or graph edge-label text overrides. A dictionary can include #c("content") for trees.],
  )
  if label-options {
    subargtable([Nested keys for #c("edge-customizations[].options.label")],
      [#c("edge-customizations[].options.label.size")], [`length`], [#c("style.label-text.size")], [Edge-label size.],
      [#c("edge-customizations[].options.label.content")], [`content`], [tree only], [Tree edge label content. Graph edge labels come from adjacency entries such as #c("(\"B\", [4])").],
      [#c("edge-customizations[].options.label.color")], [`color`], [#c("style.label-text.color")], [Edge-label text color.],
      [#c("edge-customizations[].options.label.rotation")], [`angle` / `str`], [#c("style.label-text.rotation")], [An angle, or #c("\"edge\"") to follow the tree/graph edge angle.],
      [#c("edge-customizations[].options.label.font")], [`str` / `array`], [#c("style.label-text.font")], [Typst text font selection.],
      [#c("edge-customizations[].options.label.weight")], [`str` / `int`], [#c("style.label-text.weight")], [Typst text weight.],
    )
  }
}

#let node-customizations-reference(key-desc: [Node identity.]) = {
  subargtable([Nested keys for #c("node-customizations")],
    [#c("node-customizations[]")], [`tuple`], [n/a], [One #c("(node, options)") tuple.],
    [#c("node-customizations[].node")], [`content`], [required], [#key-desc],
    [#c("node-customizations[].options")], [`dictionary`], [required], [Per-node drawing options.],
    [#c("node-customizations[].options.fill")], [`color`], [normal fill], [Node fill.],
    [#c("node-customizations[].options.stroke")], [`stroke`], [normal stroke], [Node outline.],
    [#c("node-customizations[].options.shape")], [`str`], [#c("style.node-shape")], [Trees/graphs only: #c("\"circle\""), #c("\"square\""), #c("\"diamond\""), or #c("\"hexagon\"").],
    [#c("node-customizations[].options.node-radius")], [`float`], [#c("style.node-radius")], [Trees/graphs only. Shape size.],
    [#c("node-customizations[].options.text")], [`dictionary`], [#c("style.node-text")], [Text style merged into the node text.],
  )
}

#let cell-customizations-reference(key-desc: [Cell identity.]) = {
  subargtable([Nested keys for #c("cell-customizations")],
    [#c("cell-customizations[]")], [`tuple`], [n/a], [One #c("(cell, options)") tuple.],
    [#c("cell-customizations[].cell")], [`content`], [required], [#key-desc],
    [#c("cell-customizations[].options")], [`dictionary`], [required], [Per-cell drawing options.],
    [#c("cell-customizations[].options.fill")], [`color`], [normal fill], [Cell fill.],
    [#c("cell-customizations[].options.stroke")], [`stroke`], [normal stroke], [Cell outline.],
    [#c("cell-customizations[].options.text")], [`dictionary`], [#c("style.node-text")], [Text style merged into the cell text.],
  )
}

#let node-labels-reference(key-desc: [Node identity.]) = {
  subargtable([Nested keys for #c("node-labels")],
    [#c("node-labels[]")], [`tuple`], [n/a], [One #c("(node, label)") tuple.],
    [#c("node-labels[].node")], [`content`], [required], [#key-desc],
    [#c("node-labels[].label")], [`content` / `dictionary`], [required], [Bare content for quick labels, or a dictionary with #c("content") plus style and placement keys.],
    [#c("node-labels[].label.content")], [`content`], [required for dict labels], [Label body. #c("body") is also accepted.],
    [#c("node-labels[].label.position")], [`str` / `angle`], [`"right"`], [#c("\"right\""), #c("\"left\""), #c("\"top\""), #c("\"bottom\""), or an angle.],
    [#c("node-labels[].label.offset")], [`point`], [`(0, 0)`], [Extra #c("(dx, dy)") shift after the position is applied.],
    [#c("node-labels[].label.size")], [`length`], [#c("style.label-text.size")], [Node-label size.],
    [#c("node-labels[].label.color")], [`color`], [#c("style.label-text.color")], [Node-label text color.],
    [#c("node-labels[].label.rotation")], [`angle`], [#c("style.label-text.rotation")], [Rotation of the label text itself.],
    [#c("node-labels[].label.font")], [`str` / `array`], [#c("style.label-text.font")], [Typst text font selection.],
    [#c("node-labels[].label.weight")], [`str` / `int`], [#c("style.label-text.weight")], [Typst text weight.],
  )
  subargtable([Nested keys for #c("style.node-labels")],
    [#c("style.node-labels.position")], [`str` / `angle`], [`"right"`], [Default position for all node labels in this diagram.],
    [#c("style.node-labels.offset")], [`point`], [`(0, 0)`], [Default extra #c("(dx, dy)") shift for all node labels.],
    [#c("style.node-labels.gap")], [`float`], [`0.22`], [Default distance from the node boundary in canvas units.],
    [#c("style.node-labels.size")], [`length`], [#c("style.label-text.size")], [Default node-label text size.],
    [#c("style.node-labels.color")], [`color`], [#c("style.label-text.color")], [Default node-label text color.],
    [#c("style.node-labels.font")], [`str` / `array`], [inherits], [Typst text font selection.],
    [#c("style.node-labels.weight")], [`str` / `int`], [inherits], [Typst text weight.],
    [#c("style.node-labels.rotation")], [`angle`], [#c("style.label-text.rotation")], [Default rotation of the label text itself.],
  )
}

// Object-methods table shared by every structure section.
#let methodtable(..rows) = table(
  columns: (auto, auto, 1fr), inset: 6.5pt,
  align: (x, y) => if y == 0 { center + horizon } else { left + horizon },
  fill: (_, y) => if y == 0 { accent-soft }, stroke: 0.5pt + luma(210),
  [*Field*], [*Call*], [*Effect*],
  ..rows,
)

#let rotation-portrait = {
  let blue = rgb("#1E73BE")
  let purple = rgb("#7B3FA1")
  let green = rgb("#2E7D32")
  let rust = rgb("#C75B12")
  let red = rgb("#B71C1C")
  let rot-style = (
    node-radius: 0.3,
    x-gap: 1.05,
    y-gap: 1.0,
    node-fill: white,
    node-stroke: 0.8pt + rgb("#222222"),
    node-text: (size: 11pt, weight: "bold"),
    edge-stroke: 0.8pt + rgb("#111111"),
    tri-w: 1.1,
    tri-h: 1.2,
    scale: 1.15,
  )
  let ta = subtree($T_A$, fill: blue, scale: 1.02)
  let tb = subtree($T_B$, fill: purple)
  let tc = subtree($T_C$, fill: green)
  let before = tree(
    node(
      text(fill: rust)[$x$],
      left: node(text(fill: red)[$y$], left: ta, right: tb),
      right: tc,
    ),
    style: rot-style,
  )
  let after = tree(
    node(
      text(fill: red)[$y$],
      left: ta,
      right: node(text(fill: rust)[$x$], left: tb, right: tc),
    ),
    style: rot-style,
  )
  block(width: 100%, fill: white, stroke: 0.6pt + luma(215), radius: 8pt, inset: 20pt, {
    align(center)[
      #std.stack(dir: ltr, spacing: 1.6em,
        align(horizon, before),
        align(horizon, std.stack(spacing: 0.55em,
          text(size: 12pt, weight: "bold")[rotate $x$ right],
          text(size: 24pt)[$arrow.r.long$],
          text(size: 24pt)[$arrow.l.long$],
          text(size: 12pt, weight: "bold")[rotate $y$ left],
        )),
        align(horizon, after),
      )
    ]
  })
}

// ── Cover ────────────────────────────────────────────────────────────────────

#set page(paper: "a4", margin: (x: 2.2cm, top: 2.6cm, bottom: 2.4cm), header: none, footer: none)

#v(1.2fr)
#align(center)[
  #text(size: 40pt, weight: "bold", fill: accent)[typed-dsa]
  #v(0.2em)
  #text(size: 15pt, fill: luma(90))[Declarative data-structure diagrams for Typst]
  #v(0.4em)
  #text(size: 12pt, weight: "bold")[User Guide]
  #v(1.6em)
  #rotation-portrait
  #v(1.4em)
  #text(size: 11pt)[Version #version]
]
#v(1.6fr)

// ── Header / footer for the body ─────────────────────────────────────────────

#set page(
  header: context {
    set text(size: 8.5pt, fill: luma(130))
    grid(columns: (1fr, auto),
      align(left)[typed-dsa · User Guide],
      align(right)[v#version])
    v(-0.6em)
    line(length: 100%, stroke: 0.4pt + luma(210))
  },
  footer: context {
    set text(size: 8.5pt, fill: luma(130))
    align(center, counter(page).display("1"))
  },
)
#counter(page).update(1)

#pagebreak()
#outline(title: [Contents], indent: 1.2em, depth: 2)

// ═════════════════════════════════════════════════════════════════════════════
= Introduction
// ═════════════════════════════════════════════════════════════════════════════

#demo[
  typed-dsa renders data-structure diagrams from a declarative description
  inside Typst documents. It is built on top of
  #link("https://typst.app/universe/package/cetz")[CeTZ]. The package targets
  CS coursework: lecture notes, problem sets, exam
  solutions, where you need to show how an *operation* changes a structure,
  not just draw it once.

  This guide covers every builder, argument, and operation, each with a
  runnable example: source on the left, rendered output on the right.

  #example(```typ
  #bst(50, 30, 70, 20, 40).diagram
  ```)
]

// ═════════════════════════════════════════════════════════════════════════════
= Getting started
// ═════════════════════════════════════════════════════════════════════════════

== Installation and import

Import the package from the Typst preview namespace. A wildcard import gives
you every public symbol:

```typ
#import "@preview/typed-dsa:0.1.0": *
```

Or import only what you need:

```typ
#import "@preview/typed-dsa:0.1.0": bst, avl, min-heap, max-heap
```

#warn[A wildcard import shadows Typst's built-in #c("stack") function. Use
#c("std.stack") for layout, or import #c("typed-dsa") selectively to avoid the
name clash.]

The package exports these symbols:

#table(
  columns: (auto, 1fr), inset: 7pt,
  align: (x, y) => if y == 0 { center + horizon } else { left + horizon },
  fill: (_, y) => if y == 0 { accent-soft }, stroke: 0.5pt + luma(210),
  [*Symbol*], [*Purpose*],
  [#c("bst"), #c("avl")], [Binary search tree / AVL tree builders.],
  [#c("min-heap"), #c("max-heap")], [Binary heap builders.],
  [#c("linked-list"), #c("doubly-linked-list"), #c("stack"), #c("queue")], [Linear-structure builders.],
  [#c("array-view"), #c("matrix")], [Static array and matrix/grid builders.],
  [#c("graph")], [Graph builder, from an adjacency dict.],
  [#c("tree"), #c("node"), #c("subtree")], [Hand-composed abstract trees.],
  [#c("transition")], [One-shot before → after operation diagrams for trees and heaps.],
  [#c("tree-insert"), #c("tree-delete"), #c("tree-search")], [Tree operation constructors, for #c("transition").],
  [#c("heap-insert"), #c("heap-extract")], [Heap operation constructors, for #c("transition").],
  [#c("sequence")], [Wrapped layout for operation-step sequences.],
  [#c("op-arrow")], [Reusable labeled arrow, for custom operation layouts.],
  [#c("theme"), #c("resolve")], [The default style dictionary and its merge helper.],
)

== Your first diagram

#demo[
  Every builder takes keys and returns an object; #c(".diagram") is its
  drawing.

  #example(```typ
  #bst(50, 30, 70, 20, 40).diagram
  ```)
]

// ═════════════════════════════════════════════════════════════════════════════
= Structures <structures>
// ═════════════════════════════════════════════════════════════════════════════

Every structure builder returns a *unified object*: a dictionary that is both
the drawing (#c(".diagram")) and the thing you operate on. Calling an
operation field returns a *step*; @objects covers that model in full.

This section documents each builder's own arguments and methods. @objects
covers the step shape they share.

== #raw("bst()") and #raw("avl()")

#demo[
  Full signatures:

  ```typ
  #bst(..keys, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:))
  #avl(..keys, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:))
  ```

  Both build a binary tree by inserting `keys` one at a time, in the order
  given. #c("bst") is a plain binary search tree; #c("avl") additionally
  rebalances after every insertion and deletion, so the tree stays
  height-balanced.
]

#argtable(
  [#c("..keys")], [`int` / `content`], [(required)], [Keys inserted into the tree in order, one BST/AVL insert per key. Duplicate keys are ignored.],
  [#c("style")], [`dictionary`], [`(:)`], [Per-call style override merged over the defaults. See @styling.],
  [#c("edge-customizations")], [`array`], [`()`], [#c("(parent, child, options)") tuples restyling individual tree edges by node value. See @edge-customizations.],
  [#c("node-customizations")], [`array`], [`()`], [#c("(node, options)") tuples restyling individual tree nodes by value.],
  [#c("node-labels")], [`array` / `dictionary`], [`(:)`], [Labels drawn outside individual tree nodes.],
)

#tree-style-reference()
#edge-customizations-reference(label-options: true)
#node-customizations-reference(key-desc: [For #c("bst")/#c("avl"), the inserted key.])
#node-labels-reference(key-desc: [For #c("bst")/#c("avl"), the inserted key.])

#methodtable(
  [#c(".diagram")], [n/a], [The rendered tree.],
  [#c(".insert")], [#c("(obj.insert)(key)")], [Insert #c("key"). Returns a step (@objects).],
  [#c(".delete")], [#c("(obj.delete)(key)")], [Delete #c("key"). AVL deletes rebalance when removal makes a subtree too heavy. Returns a step.],
  [#c(".search")], [#c("(obj.search)(key)")], [Highlight the traversal path to #c("key"). Returns a step.],
)

#demo[
  #example(```typ
  #bst(50, 30, 70, 20, 40, 60, 80).diagram
  #avl(10, 20, 30, 40, 50, 25).diagram

  #bst(
    50, 30, 70, 20, 40,
    node-labels: (
      (50, (content: [$d=0$], position: "top")),
      (30, [$d=2$]),
      (70, (content: [$d=3$], color: rgb("#C92A2A"))),
    ),
    style: (node-labels: (position: "left", color: rgb("#1971C2"))),
  ).diagram
  ```, side: false)
]

#demo[
  Argument coverage: this example combines tree-level styling, nested
  #c("node-text"), edge arrows/patterns, per-edge customizations, and
  diff-highlight dictionaries.

  #example(```typ
  #std.stack(spacing: 1em,
    bst(
      50, 30, 70, 20, 40, 60, 80,
      style: (
        node-shape: "square",
        node-radius: 0.38,
        node-fill: rgb("#E3F2FD"),
        node-stroke: 1pt + rgb("#1565C0"),
        node-text: (size: 10pt, weight: "bold", color: rgb("#0D47A1")),
        edge-arrow: "end",
        edge-pattern: "dashed",
        scale: 0.92,
        y-gap : 1.5,
      ),
      edge-customizations: (
        (50, 30, (pattern: "wavy", color: rgb("#8E24AA"))),
        (70, 80, (stroke: 1.4pt + rgb("#2E7D32"), arrow: "both")),
      ),
    ).diagram,
    transition(
      "avl",
      (20, 10, 30, 40),
      tree-insert(50),
      style: (
        new-style: (shape: "square", stroke: 1.5pt + rgb("#2E7D32")),
        path-style: (stroke: 1.2pt + rgb("#F9A825")),
        rotate-style: (node-radius: 0.44),
      ),
    ),
  )
  ```, side: false)
]

== #raw("min-heap()") and #raw("max-heap()")

#demo[
  Full signatures:

  ```typ
  #min-heap(..keys, style: (:))
  #max-heap(..keys, style: (:))
  ```

  A heap is an array underneath. Index `i`'s children live at `2i+1` and
  `2i+2`. Each key sifts up as it's inserted, and the diagram draws the
  complete binary tree that array shape forms. #c("min-heap") keeps the
  smallest key at the root; #c("max-heap") keeps the largest.
]

#argtable(
  [#c("..keys")], [`int` / `content`], [(required)], [Keys inserted into the heap in order, one sift-up per key.],
  [#c("style")], [`dictionary`], [`(:)`], [Per-call style override merged over the defaults. See @styling.],
)

#heap-style-reference()

#methodtable(
  [#c(".diagram")], [n/a], [The rendered heap.],
  [#c(".insert")], [#c("(obj.insert)(key)")], [Append #c("key") and sift it up. Returns a step.],
  [#c(".extract")], [#c("(obj.extract)()")], [Remove the root (no key), move the last leaf up, and sift it down. Returns a step.],
)

#demo[
  #example(```typ
  #min-heap(50, 30, 70, 20, 40, 60, 80).diagram
  #max-heap(50, 30, 70, 20, 40, 60, 80).diagram
  ```, side: false)
]

#demo[
  Argument coverage: heaps reuse tree styling, and heap operations use the
  same diff-highlight dictionaries.

  #example(```typ
  #std.stack(spacing: 1em,
    max-heap(
      50, 30, 70, 20, 40, 60, 80,
      style: (
        node-shape: "square",
        node-radius: 0.36,
        y-gap: 1.5,
        node-fill: rgb("#FFF3D6"),
        node-stroke: 1pt + rgb("#C75B12"),
        node-text: (size: 10pt, color: rgb("#5D2F00"), weight: "bold"),
        edge-pattern: "dotted",
        scale: 0.95,
      ),
    ).diagram,
    transition(
      "min-heap",
      (10, 20, 15, 40, 50, 30),
      heap-insert(5),
      style: (
        diff-colors: false,
        new-style: (shape: "square", stroke: 1.4pt + rgb("#2E7D32")),
        path-style: (stroke: 1.2pt + rgb("#F9A825")),
      ),
    ),
  )
  ```, side: false)
]

#note[A binary heap supports inserting and pulling out the root efficiently.
It has no key-based #c("delete") or #c("search") the way #c("bst")/#c("avl")
do: that's not a gap in typed-dsa, it's what a heap is.]

== #raw("linked-list()")

#demo[
  Full signature:

  ```typ
  #linked-list(
    ..vals,
    style: (:),
    pointer: false,
    addresses: none,
    head: false,
  )
  ```
]

#argtable(
  [#c("..vals")], [`int` / `content`], [(required)], [Values in the list, head first.],
  [#c("style")], [`dictionary`], [`(:)`], [Per-call style override merged over the defaults. See @styling.],
  [#c("pointer")], [`bool`], [`false`], [Draw each node as a #c("data | next") cell pair instead of a single value cell.],
  [#c("addresses")], [`none` / `array`], [`none`], [With #c("pointer: true"), one address label drawn under each node, in order.],
  [#c("head")], [`bool`], [`false`], [Draw a "Head" arrow pointing at the first node.],
)

#linear-style-reference("linked-list")

#methodtable(
  [#c(".diagram")], [n/a], [The rendered list.],
  [#c(".insert")], [#c("(obj.insert)(v)")], [Append #c("v") at the tail. Returns a step.],
  [#c(".delete")], [#c("(obj.delete)(v)")], [Remove the first node equal to #c("v"). Returns a step.],
)

#demo[
  #example(```typ
  #linked-list(3, 1, 4, 1, 5, head: true).diagram
  ```, side: false)
]

#demo[
  #example(```typ
  #linked-list(15, 3, 17, 90, pointer: true, head: true,
    addresses: ("3200", "3600", "4000", "4400")).diagram
  ```, side: false)
]

#demo[
  Argument coverage: #c("pointer"), #c("addresses"), #c("head"), label text,
  pointer-cell fills, scaling, and operation mark styling.

  #example(```typ
  #let xs = linked-list(
    [A], [B], [C],
    pointer: true,
    head: true,
    addresses: ("0x10", "0x18", "0x20"),
    style: (
      box-w: 0.9,
      box-h: 0.62,
      box-gap: 0.45,
      box-fill: rgb("#F8FBFF"),
      box-stroke: 0.8pt + rgb("#1565C0"),
      ptr-fill: rgb("#D7ECC9"),
      node-text: (size: 9pt, color: rgb("#0D47A1")),
      label-text: (size: 7.5pt, color: rgb("#455A64"), weight: "bold"),
      scale: 1.05,
      new-style: (fill: rgb("#C8E6C9"), stroke: 1pt + rgb("#2E7D32")),
      remove-style: (fill: rgb("#FFCDD2"), stroke: 1pt + rgb("#C62828")),
    ),
  )
  #xs.diagram
  ```, side: false)
]

== #raw("doubly-linked-list()")

#demo[
  Full signature:

  ```typ
  #doubly-linked-list(
    ..vals,
    style: (:),
    pointer: false,
    addresses: none,
    head: false,
  )
  ```
]

#argtable(
  [#c("..vals")], [`int` / `content`], [(required)], [Values in the list, head first.],
  [#c("style")], [`dictionary`], [`(:)`], [Per-call style override merged over the defaults. See @styling.],
  [#c("pointer")], [`bool`], [`false`], [When #c("false"), draw one value cell per node with a forward arrow above and a backward arrow below. When #c("true"), draw #c("prev | data | next") cells.],
  [#c("addresses")], [`none` / `array`], [`none`], [With #c("pointer: true"), one address label drawn under each node, in order.],
  [#c("head")], [`bool`], [`false`], [Draw a "Head" arrow pointing at the first node.],
)

#linear-style-reference("doubly-linked-list")

#methodtable(
  [#c(".diagram")], [n/a], [The rendered list.],
  [#c(".insert")], [#c("(obj.insert)(v)")], [Append #c("v") at the tail. Returns a step.],
  [#c(".delete")], [#c("(obj.delete)(v)")], [Remove the first node equal to #c("v"). Returns a step.],
)

#demo[
  #example(```typ
  #doubly-linked-list(3, 1, 4, head: true).diagram
  ```)
]

#demo[
  #example(```typ
  #doubly-linked-list(15, 3, 17, 90, pointer: true, head: true,
    addresses: ("3200", "3600", "4000", "4400"),
    style: (
      prev-ptr-fill: rgb("#FDE2E4"),
      next-ptr-fill: rgb("#D7ECC9"),
    )).diagram
  ```, side: false)
]

#demo[
  Argument coverage: doubly linked pointer cells have separate previous and
  next pointer fills, plus the same address, head, label, and mark styling as
  #c("linked-list").

  #example(```typ
  #let xs = doubly-linked-list(
    15, 3, 17,
    pointer: true,
    head: true,
    addresses: ("3200", "3600", "4000"),
    style: (
      box-w: 0.82,
      box-h: 0.62,
      box-gap: 0.5,
      box-fill: rgb("#FFFDF7"),
      box-stroke: 0.8pt + rgb("#6D4C41"),
      prev-ptr-fill: rgb("#FDE2E4"),
      next-ptr-fill: rgb("#D7ECC9"),
      node-text: (size: 8.5pt, weight: "bold"),
      label-text: (size: 7pt, color: rgb("#6D4C41")),
      path-style: (fill: rgb("#FFE9A8"), stroke: 1pt + rgb("#F9A825")),
      remove-style: (fill: rgb("#FFCDD2"), stroke: 1pt + rgb("#C62828")),
      scale : 0.8,
    ),
  )
  #(xs.delete)(3).diagram
  ```, side: false)
]

== #raw("stack()")

#demo[
  Full signature:

  ```typ
  #stack(..vals, style: (:))
  ```
]

#argtable(
  [#c("..vals")], [`int` / `content`], [(required)], [Values in the stack; the *first* argument is the top.],
  [#c("style")], [`dictionary`], [`(:)`], [Per-call style override merged over the defaults. See @styling.],
)

#linear-style-reference("stack")

#methodtable(
  [#c(".diagram")], [n/a], [The rendered stack.],
  [#c(".push")], [#c("(obj.push)(v)")], [Push #c("v") onto the top. Returns a step.],
  [#c(".pop")], [#c("(obj.pop)()")], [Pop the top value (no argument). Returns a step.],
)

#demo[
  #example(```typ
  #stack(9, 7, 2).diagram
  ```)
]

#demo[
  Argument coverage: stacks use the linear #c("style") keys and operation
  marks for #c(".push")/#c(".pop").

  #example(```typ
  #let s = stack(
    [top], [mid], [base],
    style: (
      box-w: 1.25,
      box-h: 0.58,
      box-gap: 0,
      box-fill: rgb("#F3F7FA"),
      box-stroke: 0.8pt + rgb("#37474F"),
      node-text: (size: 9pt, color: rgb("#263238"), weight: "bold"),
      scale: 1.08,
      new-style: (fill: rgb("#C8E6C9"), stroke: 1pt + rgb("#2E7D32")),
      remove-style: (fill: rgb("#FFCDD2"), stroke: 1pt + rgb("#C62828")),
    ),
  )
  #std.stack(spacing: 1em, s.diagram, (s.push)([new]).diagram, (s.pop)().diagram)
  ```, side: false)
]

== #raw("queue()")

#demo[
  Full signature:

  ```typ
  #queue(
    ..vals,
    style: (:),
    enqueue: none,
    dequeue: none,
    front-label: [Front],
    rear-label: [Rear],
  )
  ```
]

#argtable(
  [#c("..vals")], [`int` / `content`], [(required)], [Values in the queue; the *first* argument is the front.],
  [#c("style")], [`dictionary`], [`(:)`], [Per-call style override merged over the defaults. See @styling.],
  [#c("enqueue")], [`none` / `int` / `content`], [`none`], [Draw one extra element entering at the rear, with an arrow, in the same frame.],
  [#c("dequeue")], [`none` / `int` / `content`], [`none`], [Draw the front element leaving to the left, with an arrow, in the same frame.],
  [#c("front-label")], [`content`], [`[Front]`], [Label over the front cell. Combined with #c("rear-label") for a one-cell queue.],
  [#c("rear-label")], [`content`], [`[Rear]`], [Label over the rear cell. Combined with #c("front-label") for a one-cell queue.],
)

#linear-style-reference("queue")

#methodtable(
  [#c(".diagram")], [n/a], [The rendered queue.],
  [#c(".enqueue")], [#c("(obj.enqueue)(v)")], [Enqueue #c("v") at the rear. Returns a step.],
  [#c(".dequeue")], [#c("(obj.dequeue)()")], [Dequeue the front value (no argument). Returns a step.],
)

#demo[
  #example(```typ
  #queue(3, 8, 5, 1).diagram
  ```)
]

#demo[
  #c("enqueue")/#c("dequeue") draw a single-frame arrow, independent of the
  object's own #c(".enqueue")/#c(".dequeue") methods:

  #example(```typ
  #queue(3, 4, 5, 6, 7, 8, enqueue: 9, dequeue: 2,
    front-label: [Front / Head], rear-label: [Back / Tail / Rear]).diagram
  ```, side: false)
]

#demo[
  Argument coverage: queue examples can combine the single-frame
  #c("enqueue")/#c("dequeue") arrows, custom front/rear labels, label text
  styling, and operation mark styles.

  #example(```typ
  #let q = queue(
    3, 4, 5,
    enqueue: 6,
    dequeue: 2,
    front-label: text(fill: rgb("#1565C0"))[*Front*],
    rear-label: text(fill: rgb("#C75B12"))[*Rear*],
    style: (
      box-w: 0.82,
      box-h: 0.62,
      box-gap: 0.35,
      box-fill: rgb("#F8FBFF"),
      box-stroke: 0.8pt + rgb("#1565C0"),
      node-text: (size: 9pt, weight: "bold"),
      label-text: (size: 7.5pt, color: rgb("#455A64"), weight: "bold"),
      scale: 1.05,
      new-style: (fill: rgb("#C8E6C9"), stroke: 1pt + rgb("#2E7D32")),
      remove-style: (fill: rgb("#FFCDD2"), stroke: 1pt + rgb("#C62828")),
    ),
  )
  #std.stack(spacing: 1em, q.diagram, (q.enqueue)(7).diagram)
  ```, side: false)
]

== #raw("array-view()") and #raw("matrix()")

#demo[
  Full signatures:

  ```typ
  #array-view(..vals, style: (:), cell-customizations: ())
  #matrix(rows, style: (:), cell-customizations: (), row-labels: none, column-labels: none)
  ```

  These builders draw compact cell diagrams. They do not have operations yet;
  #c("cell-customizations") restyles individual array cells by index or matrix
  cells by #c("(row, column)") coordinate.
  #c("style.indices: (enabled: true)") draws zero-based array indices under
  the cells.
]

#argtable(
  [#c("..vals")], [`content`], [(required for #c("array-view"))], [Array cells, left to right.],
  [#c("rows")], [`array`], [(required for #c("matrix"))], [Rows of cells, written as nested arrays such as #c("((1, 2), (3, 4))").],
  [#c("cell-customizations")], [`array` / `dictionary`], [`()`], [Cell overrides. For arrays, use #c("((index, options), ...)"). For matrices, use #c("(((row, col), options), ...)").],
  [#c("row-labels")], [`none` / `array`], [`none`], [Matrix only. Labels drawn to the left of rows.],
  [#c("column-labels")], [`none` / `array`], [`none`], [Matrix only. Labels drawn above columns.],
  [#c("style")], [`dictionary`], [`(:)`], [Cell style override. Uses #c("box-*"), #c("node-text"), #c("label-text"), and diff-highlight style keys.],
)

#linear-style-reference("array")
#subargtable([Nested keys for #c("style.indices")],
  [#c("style.indices.enabled")], [`bool`], [`false`], [Draw index labels below array cells.],
  [#c("style.indices.labels")], [`auto` / `array`], [`auto`], [#c("auto") draws zero-based numeric indices; an array supplies custom labels.],
  [#c("style.indices.offset")], [`tuple`], [#c("(0, -0.28)")], [Canvas offset from the bottom-center index position.],
  [#c("style.indices.size")], [`length`], [#c("style.label-text.size")], [Index text size.],
  [#c("style.indices.color")], [`color`], [#c("style.label-text.color")], [Index text color.],
  [#c("style.indices.font")], [`str` / `array`], [inherits], [Typst text font selection.],
  [#c("style.indices.weight")], [`str` / `int`], [inherits], [Typst text weight.],
)
#cell-customizations-reference(key-desc: [Array index, or matrix coordinate #c("(row, column)").])

#methodtable(
  [#c(".diagram")], [n/a], [The rendered array or matrix.],
)

#demo[
  #example(```typ
  #array-view(
    4, 1, 7, 3, 9,
    style: (
      indices: (
        enabled: true,
        color: rgb("#455A64"),
        weight: "bold",
      ),
    ),
    cell-customizations: (
      (1, (fill: rgb("#FFF3BF"), stroke: 1pt + rgb("#F59F00"))),
      (2, (fill: rgb("#D3F9D8"), stroke: 1pt + rgb("#2B8A3E"))),
    ),
  ).diagram

  #matrix(
    ((0, 1, 0), (1, 0, 1), (0, 1, 0)),
    row-labels: ([A], [B], [C]),
    column-labels: ([A], [B], [C]),
    cell-customizations: (
      ((0, 1), (fill: rgb("#E7F5FF"), stroke: 1pt + rgb("#1971C2"))),
      ((1, 2), (fill: rgb("#D3F9D8"), stroke: 1pt + rgb("#2B8A3E"))),
    ),
  ).diagram
  ```, side: false)
]

== #raw("graph()")

#demo[
  Full signature:

  ```typ
  #graph(
    adjacency,
    directed: true,
    labels: (:),
    positions: (:),
    layout: "auto",
    radius: auto,
    edge-customizations: (),
    node-customizations: (),
    node-labels: (:),
    style: (:),
  )
  ```

  #c("adjacency") maps each node label to an array of that node's neighbor
  labels. To label an edge, use #c("(neighbor, label)") instead of just
  #c("neighbor"). A node with no outgoing edges still needs its key present,
  with an empty array; a label that only ever shows up as someone else's
  neighbor gets added on its own.
]

#argtable(
  [#c("adjacency")], [`dictionary`], [(required)], [Node label #c("(str)") to array of neighbor labels or #c("(neighbor, edge-label)") pairs.],
  [#c("directed")], [`bool`], [`true`], [Draw an arrowhead on every declared pair. #c("false") drops arrowheads and collapses a reciprocal pair into the one edge it represents.],
  [#c("labels")], [`dictionary`], [`(:)`], [Node label to drawn content: math, styled text, an image, anything. A label left out keeps the plain key as its own content.],
  [#c("positions")], [`dictionary`], [`(:)`], [Node label to absolute #c("(x, y)") or #c("(rel:, offset:)") placement.],
  [#c("layout")], [`str`], [`"auto"`], [#c("\"auto\"") starts from the circular layout and applies #c("positions"). #c("\"manual\"") requires every node in #c("positions").],
  [#c("radius")], [`auto` / `float`], [`auto`], [Circle radius for #c("layout: \"auto\""). Passing a radius with #c("layout: \"manual\"") is an error.],
  [#c("edge-customizations")], [`array`], [`()`], [#c("(from, to, options)") tuples restyling one edge. See below.],
  [#c("node-customizations")], [`array`], [`()`], [#c("(node, options)") tuples restyling one node by graph identity.],
  [#c("node-labels")], [`array` / `dictionary`], [`(:)`], [Labels drawn outside individual graph nodes.],
  [#c("style")], [`dictionary`], [`(:)`], [Per-call style override merged over the defaults. See @styling.],
)

#subargtable([Nested keys for #c("adjacency")],
  [#c("adjacency.<node>")], [`array`], [required], [Outgoing neighbors for one node. Use an empty array to draw an isolated node.],
  [#c("adjacency.<node>[]")], [`content` / `tuple`], [required], [Either a neighbor label, or #c("(neighbor, edge-label)") to draw a label on that edge.],
  [#c("adjacency.<node>[].neighbor")], [`content`], [required], [Target node identity.],
  [#c("adjacency.<node>[].edge-label")], [`content`], [none], [Optional edge label, such as a weight.],
)

#subargtable([Nested keys for #c("labels")],
  [#c("labels.<node>")], [`content`], [node key], [Drawn content for one node. Identity still comes from the plain adjacency/position label.],
)

#subargtable([Nested keys for #c("positions")],
  [#c("positions.<node>")], [`point` / `dictionary`], [auto layout position], [Absolute #c("(x, y)") position or relative placement dictionary.],
  [#c("positions.<node>.rel")], [`content`], [required for relative placement], [Another node label to place from.],
  [#c("positions.<node>.offset")], [`point`], [required for relative placement], [#c("(dx, dy)") offset from #c("rel").],
)

#edge-customizations-reference(label-options: true)
#graph-style-reference()
#node-customizations-reference(key-desc: [Graph identity key, not the display label from #c("labels").])
#node-labels-reference(key-desc: [Graph identity key, not the display label from #c("labels").])

#methodtable(
  [#c(".diagram")], [n/a], [The rendered graph.],
)

#demo[
  #example(```typ
  #graph(("v1": ("v2", "v3"), "v2": ("v3",), "v3": ())).diagram
  ```)
]

#demo[
  Declaring both directions of an edge still draws it once.

  #example(```typ
  #graph(
    ("v1": ("v2", "v3"), "v2": ("v1", "v3"), "v3": ()),
    directed: false,
  ).diagram
  ```)
]

#demo[
  Use #c("(neighbor, label)") entries to draw edge labels, such as weights.

  #example(```typ
  #graph(
    (
      "A": (("B", [4]), ("C", [5])),
      "B": (("C", [11]), ("D", [9]), ("E", [7])),
      "C": (("E", [3]),),
      "D": (("E", [13]), ("F", [2])),
      "E": (("F", [6]),),
      "F": (),
    ),
    directed: false,
    layout: "manual",
    positions: (
      "A": (0, 0),
      "B": (rel: "A", offset: (1.5, 1.0)),
      "C": (rel: "A", offset: (1.5, -1.0)),
      "D": (rel: "B", offset: (2.0, 0.0)),
      "E": (rel: "C", offset: (2.0, 0.0)),
      "F": (rel: "D", offset: (1.5, -1.0)),
    ),
  ).diagram
  ```, side: false)
]

#demo[
  Use #c("node-labels") for annotations such as tentative distances,
  predecessor tags, ranks, or algorithm state. The node's identity and its
  drawn inside label stay unchanged.

  #example(```typ
  #graph(
    ("S": (("A", [7]), ("B", [2])), "A": (("C", [3]),), "B": (("C", [1]),), "C": ()),
    layout: "manual",
    positions: ("S": (0, 0), "A": (1.4, 0.8), "B": (1.4, -0.8), "C": (2.8, 0)),
    node-labels: (
      ("S", (content: [$0$], position: "top", color: rgb("#2B8A3E"))),
      ("A", [$7$]),
      ("B", (content: [$2$], position: "bottom", color: rgb("#7048E8"))),
      ("C", [$3$]),
    ),
    style: (
      edge-arrow: "end",
      node-labels: (position: "top", color: rgb("#1971C2")),
    ),
  ).diagram
  ```, side: false)
]

#demo[
  #c("layout: \"auto\"") is the default. Nodes are placed around a circle;
  the radius grows as the node count increases. Pass #c("radius:") to set the
  circle radius yourself.

  #example(```typ
  #let panel(body) = block(width: 6.2em, height: 6.2em, inset: 0.2em,
    stroke: 0.5pt + luma(210), radius: 3pt, clip: true,
    align(center + horizon, scale(55%, reflow: true, body)))
  #std.stack(dir: ltr, spacing: 0.4em,
    panel(graph(("1": (), "2": ())).diagram),
    panel(graph(("1": (), "2": (), "3": ())).diagram),
    panel(graph(("1": (), "2": (), "3": (), "4": ())).diagram),
    panel(graph(("1": (), "2": (), "3": (), "4": (), "5": ())).diagram),
    panel(graph(("1": (), "2": (), "3": (), "4": (), "5": (), "6": ())).diagram),
  )
  ```, side: false)
]

#demo[
  #c("radius") only applies to #c("layout: \"auto\""). In manual layout, every
  node already has an explicit position, so combining #c("radius") with
  #c("layout: \"manual\"") raises an error.
]

#demo[
  Argument coverage: this graph combines adjacency edge labels, node display
  labels, manual and relative positions, graph-wide style, per-edge options,
  and nested edge-label overrides.

  #example(```typ
  #graph(
    (
      "A": (("B", [4]), ("C", [5])),
      "B": (("D", [9]),),
      "C": (("D", [3]),),
      "D": (),
    ),
    directed: true,
    labels: (
      "A": $s$,
      "B": text(fill: rgb("#1565C0"))[*B*],
      "C": $c_1$,
      "D": text(weight: "bold")[t],
    ),
    layout: "manual",
    positions: (
      "A": (0, 0),
      "B": (rel: "A", offset: (1.6, 0.9)),
      "C": (rel: "A", offset: (1.6, -0.9)),
      "D": (rel: "B", offset: (1.8, -0.9)),
    ),
    edge-customizations: (
      ("A", "B", (stroke: 1.4pt + rgb("#1565C0"), label: (color: rgb("#1565C0"), weight: "bold"))),
      ("A", "C", (pattern: "dashed", arrow: "both", label: (rotation: "edge"))),
      ("C", "D", (bend: "right", angle: 35deg, color: rgb("#8E24AA"), label: (size: 8pt, color: rgb("#8E24AA")))),
    ),
    style: (
      node-shape: "square",
      node-radius: 0.34,
      node-fill: rgb("#F8FBFF"),
      node-stroke: 0.8pt + rgb("#37474F"),
      node-text: (size: 9pt, color: rgb("#263238")),
      edge-stroke: 0.7pt + rgb("#455A64"),
      edge-arrow: "end",
      edge-arrow-fill: rgb("#455A64"),
      edge-pattern: "normal",
      label-text: (size: 7.5pt, color: rgb("#555555")),
      scale: 0.7,
    ),
  ).diagram
  ```, side: false)
]

== #raw("labels") and #raw("positions")

#demo[
  #c("labels") swaps what's drawn inside a node for any content, keyed by the
  plain-string label that #c("adjacency")/#c("positions")/
  #c("edge-customizations") still use for identity. With the default
  #c("layout: \"auto\""), #c("positions") places a node at an absolute
  #c("(x, y)") point or at #c("(rel: other-label, offset: (dx, dy))") on top
  of the automatic circular layout.

  #example(```typ
  #graph(
    ("v1": ("v2", "v3"), "v2": ("v3",), "v3": (), "v4": ("v1",)),
    labels: ("v1": $v_1$, "v2": $v_2$, "v3": text(fill: purple)[*C*]),
    positions: ("v4": (rel: "v1", offset: (0, 1.5))),
  ).diagram
  ```, side: false)
]

#demo[
  Set #c("layout: \"manual\"") to skip the circular layout. Every node,
  including a neighbor-only node, must have a #c("positions") entry. At least
  one absolute #c("(x, y)") entry should act as an anchor for relative
  placements.

  #example(```typ
  #graph(
    ("v1": ("v2", "v3"), "v2": ("v4",), "v3": ("v4",), "v4": ()),
    layout: "manual",
    positions: (
      "v1": (0, 0),
      "v2": (rel: "v1", offset: (1.4, 0.8)),
      "v3": (rel: "v1", offset: (1.4, -0.8)),
      "v4": (rel: "v2", offset: (1.4, -0.8)),
    ),
  ).diagram
  ```, side: false)
]

== #raw("edge-customizations") <edge-customizations>

#demo[
  An array of #c("(from, to, options)") tuples, each restyling one edge.
  For #c("graph"), #c("from") and #c("to") are node labels. For generated
  trees, they are parent and child values. #c("options") is a dictionary.

  #edge-customizations-reference(label-options: true)

  #example(```typ
  #graph(
    ("v1": ("v2", "v3"), "v2": ("v3",), "v3": ()),
    edge-customizations: (
      ("v1", "v2", (stroke: 2pt + red)),
      ("v2", "v3", (color: rgb("#2E7D32"))),
      ("v1", "v3", (pattern: "wavy", arrow: "both")),
    ),
  ).diagram
  ```, side: false)
]

#demo[
  Tree edge customizations use the values in the parent and child nodes:

  #example(```typ
  #bst(
    30, 20, 40, 10,
    edge-customizations: (
      (30, 20, (pattern: "dashed", arrow: "both")),
      (20, 10, (pattern: "wavy", color: rgb("#1565C0"))),
    ),
  ).diagram
  ```, side: false)
]

#note[A mutual pair bent the same way on both directions
(#c("(\"v1\", \"v2\", (bend: \"left\"))") and
#c("(\"v2\", \"v1\", (bend: \"left\"))")) curves to opposite sides, since
#c("\"left\"") is relative to each edge's own direction of travel. The two
arrows read as two edges instead of one double-headed line.]

#note[Nodes default to a circle, in the order their labels first show up,
radius growing with the node count. Connected nodes don't cluster closer
together yet, and #c("graph") has no operations: no add-node, add-edge, or a
transition to match trees and heaps. See @limitations.]

// ═════════════════════════════════════════════════════════════════════════════
= Hand-composed trees
// ═════════════════════════════════════════════════════════════════════════════

#demo[
  For abstract diagrams, build a tree by hand with #c("node(...)") and
  #c("subtree(...)") instead of inserting real keys. Draw a node over two
  elided subtrees, the way you'd draw an AVL height invariant.

  ```typ
  #tree(root, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:))
  #node(label, left: none, right: none, children: none, fill: none)
  #subtree(label, fill: none, height: none, scale: 1)
  ```
]

#argtable(
  [#c("root")], [result of #c("node()")], [(required)], [The tree to render.],
  [#c("style")], [`dictionary`], [`(:)`], [Per-call style override merged over the defaults. See @styling.],
  [#c("edge-customizations")], [`array`], [`()`], [#c("(parent, child, options)") tuples restyling individual tree edges by node label. See @edge-customizations.],
  [#c("node-customizations")], [`array`], [`()`], [#c("(node, options)") tuples restyling individual nodes by label.],
  [#c("node-labels")], [`array` / `dictionary`], [`(:)`], [Labels drawn outside individual nodes.],
)

#tree-style-reference(extra-subtree: true)
#edge-customizations-reference(label-options: true)
#node-customizations-reference(key-desc: [Hand-composed node label.])
#node-labels-reference(key-desc: [Hand-composed node label.])

#demo[
  #c("node(label, left:, right:, children:, fill:)"): a node with any content
  label. Use #c("left")/#c("right") for binary trees, or #c("children") for a
  multiway tree such as a B-tree schematic.

  #argtable(
    [#c("label")], [`content`], [(required)], [The node's label; any content, not just a key.],
    [#c("left")], [`none` / #c("node()") / #c("subtree()")], [`none`], [Left child.],
    [#c("right")], [`none` / #c("node()") / #c("subtree()")], [`none`], [Right child.],
    [#c("children")], [`none` / `array`], [`none`], [Multiway children. When set, this replaces #c("left")/#c("right") for layout and rendering.],
    [#c("fill")], [`none` / `color`], [`none`], [Fill tint for this node.],
  )

  #subargtable([Nested keys for #c("node()") children],
    [#c("left.label")], [`content`], [required when #c("left") is #c("node()") or #c("subtree()")], [Label drawn inside the left child.],
    [#c("left.left")], [`none` / #c("node()") / #c("subtree()")], [`none`], [Nested left child.],
    [#c("left.right")], [`none` / #c("node()") / #c("subtree()")], [`none`], [Nested right child.],
    [#c("right.label")], [`content`], [required when #c("right") is #c("node()") or #c("subtree()")], [Label drawn inside the right child.],
    [#c("right.left")], [`none` / #c("node()") / #c("subtree()")], [`none`], [Nested left child.],
    [#c("right.right")], [`none` / #c("node()") / #c("subtree()")], [`none`], [Nested right child.],
    [#c("children[]")], [#c("node()") / #c("subtree()")], [n/a], [One child in a multiway tree, laid out left to right.],
  )
]

#demo[
  #c("subtree(label, fill:, height:, scale:)"): a triangle leaf standing in
  for an elided subtree.

  #argtable(
    [#c("label")], [`content`], [(required)], [Label drawn inside the triangle.],
    [#c("fill")], [`none` / `color`], [`none`], [Outline and label tint.],
    [#c("height")], [`none` / `content`], [`none`], [Optional side bracket labeling the subtree's height.],
    [#c("scale")], [`float`], [`1`], [Resizes the triangle relative to the theme's #c("tri-w")/#c("tri-h").],
  )

  #subargtable([Style keys used by #c("subtree()")],
    [#c("style.tri-w")], [`float`], [`1.2`], [Triangle base width before #c("subtree(scale:)").],
    [#c("style.tri-h")], [`float`], [`1.4`], [Triangle height before #c("subtree(scale:)").],
    [#c("style.node-text")], [`dictionary`], [#c("(size: 9pt)")], [Triangle label and height-bracket text styling.],
  )
]

#demo[
  #example(```typ
  #tree(
    node(
      text(fill: rgb("#C75B12"))[$v$],
      left: subtree($T_ell$, fill: rgb("#1F6FBF"), height: $h_ell$),
      right: subtree($T_r$, fill: rgb("#8E44AD"), height: $h_r$),
    ),
    style: (edge-arrow: true),
  )
  ```, side: false)
]

#demo[
  Nest #c("node(...)") calls to draw a full manual tree. The indentation below
  mirrors the tree shape: each child is written inside its parent's #c("left:")
  or #c("right:") argument.

  #example(```typ
  #tree(
    node(
      [8],
      left: node(
        [3],
        left: node([1]),
        right: node(
          [6],
          left: node([4]),
          right: node([7]),
        ),
      ),
      right: node(
        [10],
        right: node([14], left: node([13])),
      ),
    ),
  )
  ```, side: false)
]

#demo[
  Use #c("children: (...)") for B-tree-style or n-ary schematics.

  #example(```typ
  #tree(
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
    style: (
      node-shape: "square",
      node-radius: 0.55,
      node-fill: rgb("#FFF9DB"),
      node-stroke: 1pt + rgb("#F08C00"),
      x-gap: 1.4,
      y-gap: 2.0,
    ),
  )
  ```, side: false)
]

#demo[
  Argument coverage: hand-composed trees combine nested #c("node()") calls,
  #c("subtree()") leaves, per-node fills, subtree height labels, tree style,
  and edge customizations keyed by the visible node labels.

  #example(```typ
  #tree(
    node(
      [root],
      fill: rgb("#E3F2FD"),
      left: node(
        [L],
        fill: rgb("#FFF3D6"),
        left: subtree($T_1$, fill: rgb("#1F6FBF"), height: $h_1$, scale: 0.9),
        right: subtree($T_2$, fill: rgb("#8E44AD"), height: $h_2$, scale: 1.1),
      ),
      right: node(
        [R],
        right: subtree($T_3$, fill: rgb("#2E7D32"), height: $h_3$),
      ),
    ),
    style: (
      node-shape: "square",
      node-radius: 0.36,
      x-gap: 1.2,
      y-gap: 1.1,
      tri-w: 1.1,
      tri-h: 1.25,
      node-stroke: 0.8pt + rgb("#37474F"),
      node-text: (size: 9pt, color: rgb("#263238")),
      edge-stroke: 0.8pt + rgb("#455A64"),
      edge-arrow: "end",
      scale: 1.05,
    ),
    edge-customizations: (
      ([root], [L], (pattern: "dashed", color: rgb("#1565C0"), label: [left])),
      ([root], [R], (stroke: 1.2pt + rgb("#C75B12"), arrow: "both", label: (content: [right], color: rgb("#C75B12")))),
    ),
  )
  ```, side: false)
]

// ═════════════════════════════════════════════════════════════════════════════
= Operation transitions <operation-transitions>
// ═════════════════════════════════════════════════════════════════════════════

#demo[
  #c("transition") is one-shot: build the structure from `keys`, apply the
  operation, and render the before state, an arrow, and the derived after
  state with the diff highlighted, in one call, no variable required. To keep
  operating on a structure across several calls, use the object model in
  @objects instead.

  ```typ
  #transition(variant, keys, op, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:))
  ```
]

#argtable(
  [#c("variant")], [`str`], [(required)], [#c("\"bst\""), #c("\"avl\""), #c("\"min-heap\""), or #c("\"max-heap\"").],
  [#c("keys")], [`array`], [(required)], [Keys the structure is built from, inserted in order.],
  [#c("op")], [operation], [(required)], [#c("tree-insert(key)"), #c("tree-delete(key)"), or #c("tree-search(key)") for trees. #c("heap-insert(key)") or #c("heap-extract") for heaps.],
  [#c("style")], [`dictionary`], [`(:)`], [Per-call style override merged over the defaults. See @styling.],
  [#c("edge-customizations")], [`array`], [`()`], [Tree transition only. #c("(parent, child, options)") tuples restyling individual tree edges by value.],
  [#c("node-customizations")], [`array`], [`()`], [Tree transition only. #c("(node, options)") tuples restyling individual tree nodes by value.],
  [#c("node-labels")], [`array` / `dictionary`], [`(:)`], [Tree transition only. Labels drawn outside individual tree nodes.],
)

#tree-style-reference()
#edge-customizations-reference(label-options: true)
#node-customizations-reference(key-desc: [Tree node value.])
#node-labels-reference(key-desc: [Tree node value.])

The highlight colors are: yellow for the traversal path, green for an added
node, red for a removed node, and blue for the nodes and visible subtree roots
in an AVL rotation schematic.

== Tree operations: #raw("tree-insert()"), #raw("tree-delete()"), #raw("tree-search()")

#demo[
  Each is a constructor. Call it with a key and it returns the closure
  #c("transition") applies. These aren't object methods. @objects covers the
  #c(".insert")/#c(".delete")/#c(".search") fields on a #c("bst")/#c("avl")
  object, which wrap these same operations.

  #argtable(
    [#c("key")], [`int` / `content`], [(required)], [The key to insert, delete, or search for.],
    [#c("rebalance")], [`dictionary`], [`(:)`], [#c("tree-insert") only. #c("(enabled:, all-steps:)"), both #c("false") by default. See below.],
    [#c("step-label")], [`content`], [auto], [Overrides the arrow label for this operation step.],
  )

  #subargtable([Nested keys for #c("rebalance")],
    [#c("rebalance.enabled")], [`bool`], [`false`], [Show the unrotated AVL tree before a rotation.],
    [#c("rebalance.all-steps")], [`bool`], [`false`], [For double rotations, split the inner and outer rotations into separate panels.],
  )
]

A BST insert highlights the search path on the before state and the new node
on the after state.

#demo[
  #example(```typ
  #transition("bst", (50, 30, 70, 20, 40), tree-insert(45))
  ```, side: false)
]

An AVL insert that unbalances the tree triggers a rotation. Every node that
changed parent turns blue: the pivot *and* the child promoted above it, plus
any subtree that swapped from one to the other. The new node is green.

#demo[
  #example(```typ
  #transition("avl", (20, 10, 30, 40), tree-insert(50))
  ```, side: false)
]

#argtable(
  [#c("enabled")], [`bool`], [`false`], [Adds a panel for the tree right after the plain insert, before any rotation straightens it out, when the AVL fixup actually rotates. A BST insert, or an AVL insert that never unbalances the tree, ignores this and stays 2-panel.],
  [#c("all-steps")], [`bool`], [`false`], [A *double* rotation (left-right or right-left) normally collapses straight from the unbalanced tree to the final one. #c("true") splits it into its own inner-then-outer panels instead. No effect on a single rotation, since there's only one step either way.],
)

#c("rebalance: (enabled: true)") splits that same rotation into three panels:
the tree right after the plain insert (unbalanced, new node green), then the
rotation that fixes it (every reparented node blue).

#demo[
  #example(```typ
  #transition("avl", (20, 10, 30, 40), tree-insert(50, rebalance: (enabled: true)))
  ```, side: false)
]

A double rotation, left-right or right-left, needs two rotations to fix. By
default #c("enabled: true") still collapses it to 3 panels, marking every node
either rotation touched; #c("all-steps: true") shows the inner rotation as its
own step, for 4 panels total.

#demo[
  #example(```typ
  #transition("avl", (30, 10), tree-insert(20, rebalance: (enabled: true, all-steps: true)))
  ```, side: false)
]

A delete marks the search path on the before state and gives the removed node
the remove style. Two-child nodes are replaced by their in-order successor;
AVL deletes also rebalance when removal makes a subtree too heavy, marking
rotation nodes blue.

#demo[
  #example(```typ
  #transition("bst", (50, 30, 70, 20, 40, 60, 80), tree-delete(30))
  #transition("avl", (30, 20, 40, 10, 25), tree-delete(40))
  ```, side: false)
]

A search leaves the before state plain and highlights the traversal path on
the after state.

#demo[
  #example(```typ
  #transition("bst", (50, 30, 70, 20, 40, 60, 80), tree-search(40))
  ```, side: false)
]

== Heap operations: #raw("heap-insert()") and #raw("heap-extract")

#demo[
  #c("heap-insert") is a constructor, like #c("tree-insert"). #c("heap-extract") is
  different: it takes no key (a heap can only pull its root), so it *is* the
  operation directly, passed without calling it. Object methods such as
  #c("(heap.extract)(step-label: [...])") can still override a step label.

  #argtable(
    [#c("key")], [`int` / `content`], [(required)], [The key to insert, #c("heap-insert") only. #c("heap-extract") takes nothing.],
    [#c("step-label")], [`content`], [auto], [Overrides the arrow label. For #c("heap-extract"), use it on the object method: #c("(h.extract)(step-label: [...])").],
  )
]

#c("heap-insert") appends the key, marks the inserted value green, and
highlights the existing sift-up path in yellow:

#demo[
  #example(```typ
  #transition("min-heap", (10, 20, 15, 40, 50, 30), heap-insert(5))
  ```, side: false)
]

#c("heap-extract") removes the root (marked red), moves the last leaf into
its place, and highlights the sift-down path in yellow:

#demo[
  #example(```typ
  #transition("max-heap", (50, 30, 70, 20, 40, 60, 80), heap-extract)
  ```, side: false)
]

#note[Heap operation marks are keyed by array position while rendering, so
inserting a value already present in the heap can still highlight only the new
node. Tree operation marks remain value-keyed; see @limitations.]

// ═════════════════════════════════════════════════════════════════════════════
= Objects and operations <objects>
// ═════════════════════════════════════════════════════════════════════════════

== The object model

#demo[
  Every builder in @structures returns a dictionary that is both the drawing
  and the structure you operate on. #c(".diagram") holds the rendering. An
  operation field derives the next state: #c(".insert")/#c(".delete")/#c(".search")
  on trees, #c(".insert")/#c(".extract") on heaps, #c(".push")/#c(".pop") on
  stacks, #c(".enqueue")/#c(".dequeue") on queues, #c(".insert")/#c(".delete")
  on linked lists and doubly linked lists.

  Typst requires parentheses around a callable dictionary field, so calling an
  operation looks like #c("(obj.insert)(45)"), not #c("obj.insert(45)").

  #example(```typ
  #let b = bst(50, 30, 70, 20, 40)
  #(b.insert)(45).diagram
  ```, side: false)
]

Calling an operation field returns a *step*: a dictionary with five fields.

#table(
  columns: (52%, 48%), inset: 6.5pt,
  align: (x, y) => if y == 0 { center + horizon } else { left + horizon },
  fill: (_, y) => if y == 0 { accent-soft }, stroke: 0.5pt + luma(210),
  [*Field*], [*Description*],
  [#c(".label")], [The arrow's text, e.g. #c("\"insert 45\"") or #c("\"extract\"").],
  [#c(".before")], [Rendered picture of the state *before* the operation, with that side's highlight marks.],
  [#c(".after")], [Rendered picture of the state *after* the operation, with that side's highlight marks. A picture only: no #c(".insert")/#c(".push")/etc. of its own.],
  [#c(".diagram")], [The packaged #c(".before") → arrow → #c(".after") row, what you show by default.],
  [#c(".result")], [The *next live object*, same shape as what the builder returned: #c(".diagram") plus operation fields, ready for the next call.],
)

#warn[#c(".result") is fully displayable via #c("result.diagram"), but plain,
with no highlights. Once you have #c(".result"), it is a fresh object built
from the post-operation state, exactly as if you had called #c("bst(...)") (or
#c("min-heap(...)"), etc.) on those exact keys directly. The diff-marking
machinery belongs to the one step that produced it. It doesn't travel with
the resulting object, and it doesn't accumulate across a chain of
#c(".result") calls.]

== Chaining operations

#demo[
  Keep calling operations on #c(".result") to chain an arbitrary sequence,
  each with its own fresh highlight:

  #example(```typ
  #let b = bst(50, 30, 70, 20, 40)
  #let step = (b.insert)(45)
  #std.stack(spacing: 1em,
    step.diagram,
    ((step.result).delete)(30).diagram,
  )
  ```, side: false)
]

#demo[
  Every structure's natural operations chain the same way: heaps
  (#c(".insert")/#c(".extract")), stacks (#c(".push")/#c(".pop")), queues
  (#c(".enqueue")/#c(".dequeue")), linked lists (#c(".insert")/#c(".delete")):

  #example(```typ
  #let h = min-heap(10, 20, 15, 40, 50, 30)
  #let step = (h.insert)(5)
  #std.stack(spacing: 1em,
    step.diagram,
    ((step.result).extract)().diagram,
  )
  ```, side: false)
]

#demo[
  Pass #c("step-label:") to an operation method when a sequence needs a
  problem-specific arrow label:

  #example(```typ
  #let h = max-heap(2, 7, 4, 1, 8, 1)
  #let s1 = (h.extract)(step-label: [take 8])
  #let s2 = ((s1.result).extract)(step-label: [take 7])
  #let s3 = ((s2.result).insert)(1, step-label: [smash 8, 7 \ insert 1])

  #sequence(h, s1, s2, s3, mode: "after", columns: 7)
  ```, side: false)
]

== Wrapped operation sequences

#demo[
  #c("sequence(..., columns:, mode:)") lays out step objects in a grid. It accepts
  operation steps directly, so you do not need to write #c(".diagram") for
  each one. Use #c("columns: 1") for a vertical trace, or a larger number to
  wrap across rows. The default #c("mode: \"all\"") shows each full transition
  row. Compact modes keep operation arrows between states: #c("mode: \"after\"")
  shows highlighted after panels, while #c("mode: \"result\"") shows the plain
  live object after each step, without operation highlights. Put the starting
  object first when you want the trace to begin with the original structure.

  #argtable(
    [#c("..steps")], [step / content], [(required)], [Operation steps, live objects, or already-rendered content.],
    [#c("columns")], [`int`], [`1`], [Number of grid columns before wrapping. Compact modes count arrows as columns too.],
    [#c("gap")], [`length`], [`1em`], [Horizontal gap between columns.],
    [#c("row-gap")], [`length`], [`1em`], [Vertical gap between rows.],
    [#c("mode")], [`str`], [`"all"`], [#c("\"all\"")/#c("\"diagram\"") renders #c(".diagram"); compact modes #c("\"before\""), #c("\"after\""), and #c("\"result\"") render selected states with labeled arrows between operations.],
  )

  #example(```typ
  #let b = bst(50, 30, 70, 20, 40)
  #let s1 = (b.insert)(60)
  #let s2 = ((s1.result).search)(20)
  #let s3 = ((s2.result).delete)(30)

  #sequence(s1, s2, s3, columns: 1, row-gap: 1.2em)
  #sequence(b, s1, s2, s3, mode: "result", columns: 7)
  ```, side: false)
]

== Custom arrows with #raw("op-arrow()")

#demo[
  To compose the arrow yourself instead of using #c(".diagram"), combine the
  step's #c(".before")/#c(".after") with #c("op-arrow(label, symbol:)").

  #argtable(
    [#c("label")], [`content`], [(required)], [Text shown above the arrow.],
    [#c("symbol")], [`content`], [#c("$arrow.r$")], [The arrow glyph itself.],
  )

  #example(```typ
  #let step = (bst(50, 30, 70, 20, 40).insert)(45)
  #std.stack(dir: ltr, spacing: 1.2em,
    align(horizon, step.before),
    op-arrow[custom label],
    align(horizon, step.after),
  )
  ```, side: false)
]

// ═════════════════════════════════════════════════════════════════════════════
= Styling <styling>
// ═════════════════════════════════════════════════════════════════════════════

#demo[
  Every builder takes a #c("style:") dictionary that is merged over the
  package defaults, so colors, size, and shape can be overridden per call.
  #c("theme") is the default dictionary itself and #c("resolve(style)") is the
  merge helper (#c("theme + style")); both are exported if you want to build
  your own styling utilities on top.

  #example(```typ
  #bst(50, 30, 70, 20, style: (
    node-shape: "square", node-radius: 0.4, node-fill: rgb("#E3F2FD"),
    node-stroke: 1pt + rgb("#1565C0"), node-text: (size: 11pt),
  )).diagram
  ```)
]

#note[To set a document-wide default instead of repeating #c("style:") at
every call, rebind the builder once: #c("#let bst = bst.with(style: (..))").]

== Where keys are documented

The detailed key lists now live where the argument appears, including nested
dictionaries such as #c("style.node-text"), #c("style.label-text"), and
#c("edge-customizations[].options.label").

#table(
  columns: (auto, 1fr), inset: 6.5pt,
  align: (x, y) => if y == 0 { center + horizon } else { left + horizon },
  fill: (_, y) => if y == 0 { accent-soft }, stroke: 0.5pt + luma(210),
  [*Area*], [*Detailed reference*],
  [Trees], [#c("bst"), #c("avl"), #c("tree"), and #c("transition") list their full #c("style.*"), #c("edge-customizations.*"), #c("node-customizations.*"), and #c("node-labels.*") keys in their argument reference.],
  [Heaps], [#c("min-heap"), #c("max-heap"), and heap transitions list the tree-renderer #c("style.*") keys they use.],
  [Graphs], [#c("graph") lists #c("adjacency.*"), #c("labels.*"), #c("positions.*"), #c("edge-customizations.*"), #c("node-customizations.*"), #c("node-labels.*"), #c("edge-customizations[].options.label.*"), and #c("style.*").],
  [Linear structures], [#c("linked-list"), #c("doubly-linked-list"), #c("stack"), and #c("queue") list their cell, pointer, label, scale, and diff-highlight #c("style.*") keys.],
)

#demo[
  #example(```typ
  #std.stack(dir: ltr, spacing: 1.5em,
    bst(50, 30, 70, style: (scale: 0.7)).diagram,
    bst(50, 30, 70).diagram,
    bst(50, 30, 70, style: (scale: 1.4)).diagram,
  )
  ```, side: false)
]

== Diff-highlight styling

#demo[
  A plain color is shorthand for #c("(fill: color)"); every example so far
  used that shorthand. Pass a dictionary instead to also override
  #c("shape"), #c("stroke"), #c("node-radius"), or #c("text") on just the marked
  node/cell. Fields the dictionary leaves out fall back to the surrounding
  #c("node-shape")/#c("node-stroke")/#c("node-radius"), *except* #c("fill"),
  which falls back to the key's own default highlight color, not
  #c("node-fill"). #c("text") merges over #c("node-text"), so each mark kind
  can have its own label color, size, font, or weight.

  #example(```typ
  #transition("bst", (50, 30, 70, 20, 40), tree-insert(45), style: (
    // square instead of circle, thicker stroke; fill stays the default green
    new-style: (shape: "square", stroke: 2pt + rgb("#2E7D32"), text: (color: rgb("#2E7D32"))),
  ))
  ```, side: false)
]

#demo[
  Set #c("diff-colors: false") to remove highlight fill colors while keeping
  operation marks. Shape, stroke, and radius overrides still apply.

  #example(```typ
  #transition("bst", (50, 30, 70, 20, 40), tree-insert(45), style: (
    diff-colors: false,
    new-style: (shape: "square", stroke: 1.5pt + black, text: (weight: "bold")),
  ))
  ```, side: false)
]

#note[This applies to every structure that highlights marks: #c("bst")/#c("avl")
(node #c("shape")/#c("stroke")/#c("node-radius")), #c("min-heap")/#c("max-heap")
(same, since they reuse the tree renderer), and #c("stack")/#c("queue")/
#c("linked-list")/#c("doubly-linked-list") (cell #c("fill")/#c("stroke");
cells have no #c("shape") or #c("node-radius") to override).]

// ═════════════════════════════════════════════════════════════════════════════
= Worked example: Last Stone Weight
// ═════════════════════════════════════════════════════════════════════════════

#demo[
  A complete example pairing a real solution with the diagram it produces:
  #link("https://leetcode.com/problems/last-stone-weight/")[LeetCode 1046, Last
  Stone Weight] (Easy). Repeatedly smash the two heaviest stones together; if
  they're equal both are destroyed, otherwise the difference goes back in. A
  max-heap hands you the two heaviest in $O(log n)$ each round instead of a
  full rescan.
]

```python
import heapq

def lastStoneWeight(stones):
    heap = [-s for s in stones]
    heapq.heapify(heap)
    while len(heap) > 1:
        y, x = -heapq.heappop(heap), -heapq.heappop(heap)
        if y != x:
            heapq.heappush(heap, -(y - x))
    return -heap[0] if heap else 0
```

#v(0.4em)

The diagram below runs the *same* algorithm through #c("max-heap"), chained
with #c(".extract()")/#c(".insert()") and a custom #c("op-arrow") label per
round. The diagram comes from running the algorithm, not from hand-drawing
pictures to match the code:

#let heap-style = (
  node-fill: rgb("#FFF3D6"),
  node-stroke: 1pt + rgb("#C75B12"),
  edge-stroke: 1pt + rgb("#A84A0F"),
)

#let smash-round(h, y, x) = {
  let popped = ((h.extract)().result.extract)()
  let diff = y - x
  let after = if diff == 0 { popped.result } else { (popped.result.insert)(diff).result }
  let lbl = if diff == 0 [smash #y, #x \ → both destroyed] else [smash #y, #x \ insert #diff]
  (
    frame: std.stack(dir: ltr, spacing: 1.5em,
      align(horizon, h.diagram),
      op-arrow(lbl),
      align(horizon, after.diagram),
    ),
    result: after,
  )
}

#let h0 = max-heap(2, 7, 4, 1, 8, 1, style: heap-style)
#let r1 = smash-round(h0, 8, 7)
#let r2 = smash-round(r1.result, 4, 2)
#let r3 = smash-round(r2.result, 2, 1)
#let r4 = smash-round(r3.result, 1, 1)

#align(center, std.stack(spacing: 1.4em, r1.frame, r2.frame, r3.frame, r4.frame))

#v(0.4em)
One stone remains, weight *1*, matching
#c("lastStoneWeight([2, 7, 4, 1, 8, 1]) == 1").

// ═════════════════════════════════════════════════════════════════════════════
= Limitations <limitations>
// ═════════════════════════════════════════════════════════════════════════════

- Tree operation diff marks are keyed by node *value*, not position, so a tree
  with duplicate keys can highlight more nodes than actually moved. Heap
  operation marks are position-keyed. For static tree/graph diagrams, use
  #c("node-customizations") for explicit per-node control. For arrays and
  matrices, use #c("cell-customizations").
- #c("graph") lays nodes out on a circle. A layout that pulls connected nodes
  closer together isn't built yet.
- #c("graph") has no operations yet: no add-node, add-edge, or a transition
  to match trees and heaps.
- #c("sequence") wraps already-created operation steps, but it does not yet
  compute an operation chain from a declarative list by itself.
- Hash tables sit outside this release's scope.

// ═════════════════════════════════════════════════════════════════════════════
= Quick reference
// ═════════════════════════════════════════════════════════════════════════════

== Structure builders

#table(
  columns: (52%, 48%), inset: 6.5pt,
  align: (x, y) => if y == 0 { center + horizon } else { left + horizon },
  fill: (_, y) => if y == 0 { accent-soft }, stroke: 0.5pt + luma(210),
  [*Call*], [*Result*],
  [#c("bst(..keys, style:, edge-customizations:, node-customizations:, node-labels:)")], [Binary search tree built by inserting keys in order; ops #c("insert"), #c("delete"), #c("search")],
  [#c("avl(..keys, style:, edge-customizations:, node-customizations:, node-labels:)")], [AVL tree, rebalanced on every insertion and deletion; same ops as #c("bst")],
  [#c("min-heap(..keys, style:)")], [Array-backed complete binary tree, smallest key at the root; ops #c("insert"), #c("extract")],
  [#c("max-heap(..keys, style:)")], [Array-backed complete binary tree, largest key at the root; ops #c("insert"), #c("extract")],
  [#c("linked-list(..vals, style:, pointer:, addresses:, head:)")], [Linked list; #c("pointer") shows #c("data | next") cells; ops #c("insert"), #c("delete")],
  [#c("doubly-linked-list(..vals, style:, pointer:, addresses:, head:)")], [Doubly linked list; #c("pointer") shows #c("prev | data | next") cells; ops #c("insert"), #c("delete")],
  [#c("stack(..vals, style:)")], [Stack, first argument is the top; ops #c("push"), #c("pop")],
  [#c("queue(..vals, style:, enqueue:, dequeue:, front-label:, rear-label:)")], [Queue, first argument is the front; ops #c("enqueue"), #c("dequeue")],
  [#c("array-view(..vals, style:, cell-customizations:)")], [Static array cells with optional #c("style.indices") and per-cell overrides],
  [#c("matrix(rows, style:, cell-customizations:, row-labels:, column-labels:)")], [Static matrix/grid cells with optional row/column labels and per-cell overrides],
  [#c("graph(adjacency, directed:, labels:, positions:, layout:, radius:, edge-customizations:, node-customizations:, node-labels:, style:)")], [Graph from an adjacency dict; circular or manual layout, no ops yet],
)

== Hand-composed trees

#table(
  columns: (52%, 48%), inset: 6.5pt,
  align: (x, y) => if y == 0 { center + horizon } else { left + horizon },
  fill: (_, y) => if y == 0 { accent-soft }, stroke: 0.5pt + luma(210),
  [*Call*], [*Result*],
  [#c("tree(root, style:, edge-customizations:, node-customizations:, node-labels:)")], [Render a tree built from #c("node")/#c("subtree")],
  [#c("node(label, left:, right:, children:, fill:)")], [A binary or multiway node with any content label],
  [#c("subtree(label, fill:, height:, scale:)")], [Triangle leaf with an optional height bracket],
)

== Transitions and operations

#table(
  columns: (auto, 1fr), inset: 6.5pt,
  align: (x, y) => if y == 0 { center + horizon } else { left + horizon },
  fill: (_, y) => if y == 0 { accent-soft }, stroke: 0.5pt + luma(210),
  [*Call*], [*Result*],
  [#c("transition(variant, keys, op, style:, edge-customizations:, node-customizations:, node-labels:)")], [Before → arrow → derived after for #c("bst")/#c("avl")/#c("min-heap")/#c("max-heap"), diff highlighted],
  [#c("tree-insert(key, rebalance:, step-label:)")], [Operation: insert #c("key"). #c("rebalance: (enabled: true)") adds a panel for the unrotated tree, when AVL rotates; #c("all-steps: true") splits a double rotation into its own inner/outer steps],
  [#c("tree-delete(key, step-label:)")], [Operation: delete #c("key"); AVL rebalances when needed],
  [#c("tree-search(key, step-label:)")], [Operation: highlight the path to #c("key")],
  [#c("heap-insert(key, step-label:)")], [Operation: insert #c("key"), marks the inserted value and the sift-up path],
  [#c("heap-extract")], [Operation: remove the root, marks it and the sift-down path (no key)],
  [#c("sequence(..steps, columns:, gap:, row-gap:, mode:)")], [Wrap operation steps or diagrams into a grid; #c("mode") chooses full steps, before/after panels, or plain results],
  [#c("op-arrow(label, symbol:)")], [Reusable labeled arrow for custom operation layouts],
)

== Styling keys

#table(
  columns: (auto, auto, 1fr), inset: 6.5pt,
  align: (x, y) => if y == 0 { center + horizon } else { left + horizon },
  fill: (_, y) => if y == 0 { accent-soft }, stroke: 0.5pt + luma(210),
  [*Key*], [*Default*], [*Effect*],
  [#c("node-radius")], [`0.34`], [Circle radius / half shape size.],
  [#c("node-shape")], [`"circle"`], [#c("\"circle\""), #c("\"square\""), #c("\"diamond\""), or #c("\"hexagon\"").],
  [#c("x-gap")], [`1.05`], [Horizontal spacing between columns.],
  [#c("y-gap")], [`1.2`], [Vertical spacing between depths.],
  [#c("node-stroke")], [`0.6pt + #333`], [Node outline.],
  [#c("node-fill")], [`white`], [Default node fill.],
  [#c("edge-stroke")], [`0.6pt + #333`], [Edge stroke.],
  [#c("edge-arrow")], [`none`], [Edge arrowheads: #c("none"), #c("\"end\"")/#c("true"), #c("\"start\""), #c("\"both\"").],
  [#c("edge-arrow-fill")], [`none`], [#c("graph") arrowheads: #c("none") (open) or a color (solid).],
  [#c("edge-pattern")], [`"normal"`], [Global tree/#c("graph") edge pattern.],
  [#c("edge-wave-amplitude")], [`0.07`], [Wave height in canvas units.],
  [#c("edge-wave-step")], [`0.14`], [Approximate wavelength in canvas units.],
  [#c("tri-w")], [`1.2`], [Subtree triangle base width.],
  [#c("tri-h")], [`1.4`], [Subtree triangle height.],
  [#c("box-w")], [`0.95`], [Linear-structure cell width.],
  [#c("box-h")], [`0.7`], [Linear-structure cell height.],
  [#c("box-gap")], [`0.55`], [Gap between cells/rows.],
  [#c("box-stroke")], [`0.6pt + #333`], [Cell outline.],
  [#c("box-fill")], [`white`], [Default cell fill.],
  [#c("ptr-fill")], [`#D7ECC9`], [Linked-list pointer-cell fill.],
  [#c("prev-ptr-fill")], [`#D7ECC9`], [Doubly linked list previous-pointer fill.],
  [#c("next-ptr-fill")], [`#D7ECC9`], [Doubly linked list next-pointer fill.],
  [#c("node-text")], [`(size: 9pt)`], [Node/cell text styling.],
  [#c("label-text")], [`(fill: #555)`], [Annotation/edge text styling.],
  [#c("scale")], [`1.0`], [Uniform scale on the whole rendered diagram.],
  [#c("diff-colors")], [`true`], [Set #c("false") to keep mark shapes/strokes but use normal fills.],
  [#c("new-style")], [`#C8E6C9`], [Added node/cell; color or #c("(fill:, shape:, stroke:, node-radius:, text:)").],
  [#c("path-style")], [`#FFE9A8`], [Traversal / sift path; color or dict, as above.],
  [#c("remove-style")], [`#FFCDD2`], [Removed node/cell; color or dict, as above.],
  [#c("rotate-style")], [`#BBDEFB`], [AVL rotation nodes and visible subtree roots; color or dict, as above.],
)
