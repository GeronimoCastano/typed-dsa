// Shared visual defaults for every diagram in the package.
//
// One dict so node sizing, palette, and strokes stay consistent across trees
// and linear structures. Every builder takes a `style:` dict that is merged
// over these defaults with `resolve`, so colors, size, and shape can be
// overridden per call or, via `.with(style: ...)`, document-wide.

#let theme = (
  // Trees
  node-radius: 0.34,
  node-shape: "circle", // circle, square, rounded, capsule, diamond, or hexagon
  x-gap: 1.05,
  y-gap: 1.2,
  node-stroke: 0.6pt + rgb("#333333"),
  node-fill: white,
  edge-stroke: 0.6pt + rgb("#333333"),
  edge-arrow: none, // edge arrowheads: none/false, "end" (or true), "start", "both"
  edge-arrow-fill: none, // graph() directed arrowheads: none (open) or a fill color (solid)
  edge-pattern: "normal", // "normal", "dashed", "dotted", or "wavy"
  edge-wave-amplitude: 0.07,
  edge-wave-step: 0.14,

  // Subtree triangles
  tri-w: 1.2,
  tri-h: 1.4,

  // Linear structures
  box-w: 0.95,
  box-h: 0.7,
  box-shape: "square", // square, rounded, or capsule
  box-gap: 0.55,
  box-stroke: 0.6pt + rgb("#333333"),
  box-fill: white,
  ptr-fill: rgb("#D7ECC9"), // next-pointer cell in the linked-list pointer style
  prev-ptr-fill: rgb("#D7ECC9"), // previous-pointer cell in doubly-linked-list(pointer: true)
  next-ptr-fill: rgb("#D7ECC9"), // next-pointer cell in doubly-linked-list(pointer: true)

  // Shared
  node-text: (size: 9pt),
  value-text: (:), // inherits node-text
  label-text: (color: rgb("#555555")), // annotations: head, front/rear, addresses; inherits size from node-text
  index-text: (size: 7.5pt), // inherits label-text
  pointer-text: (:), // inherits label-text
  operation-text: (size: 8pt), // transition arrow captions
  edge-label-text: (:), // inherits label-text
  algorithm-label-text: (size: 8pt), // sorting and graph trace captions
  scale: 1.0, // uniform scale applied to the whole rendered diagram
  diff-colors: true, // false keeps operation marks but uses the normal fill

  // Diff highlight styles, used by operation transitions. Each is a plain
  // color (shorthand for `(fill: color)`) or a dict of `fill:`, `shape:`,
  // `stroke:`, `node-radius:`, and `text:` overrides for a marked node/cell.
  new-style: rgb("#C8E6C9"),     // node added by the operation
  path-style: rgb("#FFE9A8"),    // nodes on the traversal path
  remove-style: rgb("#FFCDD2"),  // node removed by the operation
  rotate-style: rgb("#BBDEFB"),  // pivot of an AVL rotation

  // Graph-algorithm state roles.
  visited-style: (fill: rgb("#C8E6C9"), stroke: 1pt + rgb("#2E7D32")),
  current-style: (fill: rgb("#BBDEFB"), stroke: 1pt + rgb("#1565C0")),
  queued-style: (fill: rgb("#FFE9A8"), stroke: 1pt + rgb("#F08C00")),
  active-edge-style: (stroke: 2pt + rgb("#1971C2")),
)

// Sparse presets are passed through `style:` and keep the default sizing and
// layout. `theme` remains the default dictionary for backwards compatibility.
#let themes = (
  "default": (:),
  "dark": (
    node-fill: rgb("#20242B"), node-stroke: 0.8pt + rgb("#E9ECEF"),
    edge-stroke: 0.8pt + rgb("#CED4DA"), box-fill: rgb("#20242B"),
    box-stroke: 0.8pt + rgb("#E9ECEF"), ptr-fill: rgb("#364152"),
    prev-ptr-fill: rgb("#364152"), next-ptr-fill: rgb("#364152"),
    node-text: (fill: rgb("#F8F9FA")), label-text: (fill: rgb("#CED4DA")),
  ),
  "print": (
    node-fill: white, node-stroke: 0.9pt + black, edge-stroke: 0.9pt + black,
    box-fill: white, box-stroke: 0.9pt + black, ptr-fill: luma(225),
    prev-ptr-fill: luma(225), next-ptr-fill: luma(225),
    label-text: (fill: black), diff-colors: false,
  ),
  "colorblind": (
    new-style: rgb("#009E73"), path-style: rgb("#F0E442"),
    remove-style: rgb("#D55E00"), rotate-style: rgb("#56B4E9"),
    visited-style: (fill: rgb("#009E73").lighten(65%), stroke: 1pt + rgb("#007A5A")),
    current-style: (fill: rgb("#56B4E9").lighten(55%), stroke: 1pt + rgb("#0072B2")),
    queued-style: (fill: rgb("#F0E442").lighten(45%), stroke: 1pt + rgb("#B28B00")),
    active-edge-style: (stroke: 2pt + rgb("#CC79A7")),
  ),
  "chalkboard": (
    node-fill: rgb("#254B3C"), node-stroke: 1pt + rgb("#173C30"),
    edge-stroke: 1pt + rgb("#254B3C"), box-fill: rgb("#254B3C"),
    box-stroke: 1pt + rgb("#173C30"), ptr-fill: rgb("#315F4D"),
    prev-ptr-fill: rgb("#315F4D"), next-ptr-fill: rgb("#315F4D"),
    node-text: (fill: white), label-text: (fill: rgb("#254B3C")),
  ),
)

#let theme-preset(name) = {
  assert(name in themes, message: "unknown typed-dsa theme: " + name)
  themes.at(name)
}

// Named-argument style builders provide editor completion while returning the
// same sparse dictionaries accepted by every public `style:` argument.
#let text-style(
  size: auto,
  color: auto,
  fill: auto,
  font: auto,
  weight: auto,
  rotation: auto,
) = {
  let result = (:)
  if size != auto { result.size = size }
  if color != auto { result.color = color }
  if fill != auto { result.fill = fill }
  if font != auto { result.font = font }
  if weight != auto { result.weight = weight }
  if rotation != auto { result.rotation = rotation }
  result
}

#let label-style(
  size: auto,
  color: auto,
  fill: auto,
  font: auto,
  weight: auto,
  rotation: auto,
) = text-style(
  size: size,
  color: color,
  fill: fill,
  font: font,
  weight: weight,
  rotation: rotation,
)

#let node-mark-style(
  fill: auto,
  shape: auto,
  stroke: auto,
  node-radius: auto,
  text: auto,
) = {
  let result = (:)
  if fill != auto { result.fill = fill }
  if shape != auto { result.shape = shape }
  if stroke != auto { result.stroke = stroke }
  if node-radius != auto { result.node-radius = node-radius }
  if text != auto { result.text = text }
  result
}

#let cell-mark-style(
  fill: auto,
  stroke: auto,
  text: auto,
) = {
  let result = (:)
  if fill != auto { result.fill = fill }
  if stroke != auto { result.stroke = stroke }
  if text != auto { result.text = text }
  result
}

#let node-label-style(
  position: auto,
  offset: auto,
  gap: auto,
  size: auto,
  color: auto,
  font: auto,
  weight: auto,
  rotation: auto,
) = {
  let result = label-style(size: size, color: color, font: font, weight: weight, rotation: rotation)
  if position != auto { result.position = position }
  if offset != auto { result.offset = offset }
  if gap != auto { result.gap = gap }
  result
}

#let indices-style(
  enabled: auto,
  labels: none,
  offset: auto,
  size: auto,
  color: auto,
  font: auto,
  weight: auto,
) = {
  let result = label-style(size: size, color: color, font: font, weight: weight)
  if enabled != auto { result.enabled = enabled }
  if labels != none { result.labels = labels }
  if offset != auto { result.offset = offset }
  result
}

#let _build-style-dictionary(
  node-radius: auto,
  node-shape: auto,
  x-gap: auto,
  y-gap: auto,
  node-stroke: auto,
  node-fill: auto,
  edge-stroke: auto,
  edge-arrow: auto,
  edge-arrow-fill: auto,
  edge-pattern: auto,
  edge-wave-amplitude: auto,
  edge-wave-step: auto,
  tri-w: auto,
  tri-h: auto,
  box-w: auto,
  box-h: auto,
  box-shape: auto,
  box-gap: auto,
  box-stroke: auto,
  box-fill: auto,
  ptr-fill: auto,
  prev-ptr-fill: auto,
  next-ptr-fill: auto,
  node-text: auto,
  value-text: auto,
  label-text: auto,
  index-text: auto,
  pointer-text: auto,
  operation-text: auto,
  edge-label-text: auto,
  algorithm-label-text: auto,
  node-labels: auto,
  indices: auto,
  scale: auto,
  diff-colors: auto,
  new-style: auto,
  path-style: auto,
  remove-style: auto,
  rotate-style: auto,
  visited-style: auto,
  current-style: auto,
  queued-style: auto,
  active-edge-style: auto,
) = {
  let result = (:)
  if node-radius != auto { result.node-radius = node-radius }
  if node-shape != auto { result.node-shape = node-shape }
  if x-gap != auto { result.x-gap = x-gap }
  if y-gap != auto { result.y-gap = y-gap }
  if node-stroke != auto { result.node-stroke = node-stroke }
  if node-fill != auto { result.node-fill = node-fill }
  if edge-stroke != auto { result.edge-stroke = edge-stroke }
  if edge-arrow != auto { result.edge-arrow = edge-arrow }
  if edge-arrow-fill != auto { result.edge-arrow-fill = edge-arrow-fill }
  if edge-pattern != auto { result.edge-pattern = edge-pattern }
  if edge-wave-amplitude != auto { result.edge-wave-amplitude = edge-wave-amplitude }
  if edge-wave-step != auto { result.edge-wave-step = edge-wave-step }
  if tri-w != auto { result.tri-w = tri-w }
  if tri-h != auto { result.tri-h = tri-h }
  if box-w != auto { result.box-w = box-w }
  if box-h != auto { result.box-h = box-h }
  if box-shape != auto { result.box-shape = box-shape }
  if box-gap != auto { result.box-gap = box-gap }
  if box-stroke != auto { result.box-stroke = box-stroke }
  if box-fill != auto { result.box-fill = box-fill }
  if ptr-fill != auto { result.ptr-fill = ptr-fill }
  if prev-ptr-fill != auto { result.prev-ptr-fill = prev-ptr-fill }
  if next-ptr-fill != auto { result.next-ptr-fill = next-ptr-fill }
  if node-text != auto { result.node-text = node-text }
  if value-text != auto { result.value-text = value-text }
  if label-text != auto { result.label-text = label-text }
  if index-text != auto { result.index-text = index-text }
  if pointer-text != auto { result.pointer-text = pointer-text }
  if operation-text != auto { result.operation-text = operation-text }
  if edge-label-text != auto { result.edge-label-text = edge-label-text }
  if algorithm-label-text != auto { result.algorithm-label-text = algorithm-label-text }
  if node-labels != auto { result.node-labels = node-labels }
  if indices != auto { result.indices = indices }
  if scale != auto { result.scale = scale }
  if diff-colors != auto { result.diff-colors = diff-colors }
  if new-style != auto { result.new-style = new-style }
  if path-style != auto { result.path-style = path-style }
  if remove-style != auto { result.remove-style = remove-style }
  if rotate-style != auto { result.rotate-style = rotate-style }
  if visited-style != auto { result.visited-style = visited-style }
  if current-style != auto { result.current-style = current-style }
  if queued-style != auto { result.queued-style = queued-style }
  if active-edge-style != auto { result.active-edge-style = active-edge-style }
  result
}

#let tree-style(
  node-radius: auto, node-shape: auto, x-gap: auto, y-gap: auto,
  node-stroke: auto, node-fill: auto, edge-stroke: auto,
  edge-arrow: auto, edge-arrow-fill: auto, edge-pattern: auto,
  edge-wave-amplitude: auto, edge-wave-step: auto,
  tri-w: auto, tri-h: auto, node-text: auto, value-text: auto, label-text: auto,
  index-text: auto, pointer-text: auto, operation-text: auto,
  edge-label-text: auto, algorithm-label-text: auto,
  node-labels: auto, scale: auto, diff-colors: auto,
  new-style: auto, path-style: auto, remove-style: auto, rotate-style: auto,
  visited-style: auto, current-style: auto, queued-style: auto, active-edge-style: auto,
) = _build-style-dictionary(
  node-radius: node-radius, node-shape: node-shape, x-gap: x-gap, y-gap: y-gap,
  node-stroke: node-stroke, node-fill: node-fill, edge-stroke: edge-stroke,
  edge-arrow: edge-arrow, edge-arrow-fill: edge-arrow-fill, edge-pattern: edge-pattern,
  edge-wave-amplitude: edge-wave-amplitude, edge-wave-step: edge-wave-step,
  tri-w: tri-w, tri-h: tri-h, node-text: node-text, value-text: value-text, label-text: label-text,
  index-text: index-text, pointer-text: pointer-text, operation-text: operation-text,
  edge-label-text: edge-label-text, algorithm-label-text: algorithm-label-text,
  node-labels: node-labels, scale: scale, diff-colors: diff-colors,
  new-style: new-style, path-style: path-style,
  remove-style: remove-style, rotate-style: rotate-style,
  visited-style: visited-style, current-style: current-style,
  queued-style: queued-style, active-edge-style: active-edge-style,
)

#let heap-style(
  node-radius: auto, node-shape: auto, x-gap: auto, y-gap: auto,
  node-stroke: auto, node-fill: auto, edge-stroke: auto,
  edge-arrow: auto, edge-arrow-fill: auto, edge-pattern: auto,
  edge-wave-amplitude: auto, edge-wave-step: auto,
  node-text: auto, value-text: auto, label-text: auto, operation-text: auto,
  edge-label-text: auto, scale: auto, diff-colors: auto,
  new-style: auto, path-style: auto, remove-style: auto,
) = _build-style-dictionary(
  node-radius: node-radius, node-shape: node-shape, x-gap: x-gap, y-gap: y-gap,
  node-stroke: node-stroke, node-fill: node-fill, edge-stroke: edge-stroke,
  edge-arrow: edge-arrow, edge-arrow-fill: edge-arrow-fill, edge-pattern: edge-pattern,
  edge-wave-amplitude: edge-wave-amplitude, edge-wave-step: edge-wave-step,
  node-text: node-text, value-text: value-text, label-text: label-text,
  operation-text: operation-text, edge-label-text: edge-label-text,
  scale: scale, diff-colors: diff-colors,
  new-style: new-style, path-style: path-style, remove-style: remove-style,
)

#let graph-style(
  node-radius: auto, node-shape: auto, node-stroke: auto, node-fill: auto,
  edge-stroke: auto, edge-arrow: auto, edge-arrow-fill: auto, edge-pattern: auto,
  edge-wave-amplitude: auto, edge-wave-step: auto,
  node-text: auto, value-text: auto, label-text: auto, edge-label-text: auto,
  algorithm-label-text: auto, node-labels: auto, scale: auto,
  visited-style: auto, current-style: auto, queued-style: auto, active-edge-style: auto,
) = _build-style-dictionary(
  node-radius: node-radius, node-shape: node-shape,
  node-stroke: node-stroke, node-fill: node-fill, edge-stroke: edge-stroke,
  edge-arrow: edge-arrow, edge-arrow-fill: edge-arrow-fill, edge-pattern: edge-pattern,
  edge-wave-amplitude: edge-wave-amplitude, edge-wave-step: edge-wave-step,
  node-text: node-text, value-text: value-text, label-text: label-text,
  edge-label-text: edge-label-text, algorithm-label-text: algorithm-label-text,
  node-labels: node-labels, scale: scale,
  visited-style: visited-style, current-style: current-style,
  queued-style: queued-style, active-edge-style: active-edge-style,
)

#let list-style(
  box-w: auto, box-h: auto, box-shape: auto, box-gap: auto, box-stroke: auto, box-fill: auto,
  ptr-fill: auto, prev-ptr-fill: auto, next-ptr-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, pointer-text: auto,
  operation-text: auto, scale: auto, diff-colors: auto,
  new-style: auto, path-style: auto, remove-style: auto,
) = _build-style-dictionary(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-gap: box-gap,
  box-stroke: box-stroke, box-fill: box-fill,
  ptr-fill: ptr-fill, prev-ptr-fill: prev-ptr-fill, next-ptr-fill: next-ptr-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  pointer-text: pointer-text, operation-text: operation-text,
  scale: scale, diff-colors: diff-colors,
  new-style: new-style, path-style: path-style, remove-style: remove-style,
)

#let stack-style(
  box-w: auto, box-h: auto, box-shape: auto, box-gap: auto, box-stroke: auto, box-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, pointer-text: auto,
  operation-text: auto, scale: auto, diff-colors: auto,
  new-style: auto, remove-style: auto,
) = _build-style-dictionary(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-gap: box-gap,
  box-stroke: box-stroke, box-fill: box-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  pointer-text: pointer-text, operation-text: operation-text,
  scale: scale, diff-colors: diff-colors,
  new-style: new-style, remove-style: remove-style,
)

#let queue-style(
  box-w: auto, box-h: auto, box-shape: auto, box-gap: auto, box-stroke: auto, box-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, pointer-text: auto,
  operation-text: auto, scale: auto, diff-colors: auto,
  new-style: auto, remove-style: auto,
) = stack-style(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-gap: box-gap,
  box-stroke: box-stroke, box-fill: box-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  pointer-text: pointer-text, operation-text: operation-text,
  scale: scale, diff-colors: diff-colors,
  new-style: new-style, remove-style: remove-style,
)

#let array-style(
  box-w: auto, box-h: auto, box-shape: auto, box-stroke: auto, box-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, index-text: auto,
  pointer-text: auto, algorithm-label-text: auto, indices: auto, scale: auto,
) = _build-style-dictionary(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-stroke: box-stroke, box-fill: box-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  index-text: index-text, pointer-text: pointer-text,
  algorithm-label-text: algorithm-label-text, indices: indices, scale: scale,
)

#let matrix-style(
  box-w: auto, box-h: auto, box-shape: auto, box-stroke: auto, box-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, index-text: auto, scale: auto,
) = _build-style-dictionary(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-stroke: box-stroke, box-fill: box-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  index-text: index-text, scale: scale,
)

// Merge a per-call override dict over the defaults.
#let resolve(style) = {
  let resolved-style = theme + style
  if "node-text" in style {
    resolved-style.node-text = theme.node-text + style.node-text
  }

  let label-defaults = theme.label-text
  let label-size-is-unspecified = "size" not in label-defaults and (
    "label-text" not in style or "size" not in style.label-text
  )
  // Annotation text scales from node text unless the theme or caller supplies
  // an explicit label size.
  if label-size-is-unspecified {
    label-defaults.size = (
      resolved-style.node-text.at("size", default: 9pt) * 0.85
    )
  }

  if "label-text" in style {
    resolved-style.label-text = label-defaults + style.label-text
  } else {
    resolved-style.label-text = label-defaults
  }

  resolved-style.value-text = (
    resolved-style.node-text
      + theme.value-text
      + style.at("value-text", default: (:))
  )
  let label-text-roles = (
    "index-text",
    "pointer-text",
    "operation-text",
    "edge-label-text",
    "algorithm-label-text",
  )
  for text-role in label-text-roles {
    resolved-style.insert(
      text-role,
      resolved-style.label-text
        + theme.at(text-role)
        + style.at(text-role, default: (:)),
    )
  }

  if "color" in resolved-style.node-text {
    resolved-style.node-text.fill = resolved-style.node-text.color
    let _ = resolved-style.node-text.remove("color")
  }

  if "color" in resolved-style.label-text {
    resolved-style.label-text.fill = resolved-style.label-text.color
    let _ = resolved-style.label-text.remove("color")
  }
  for text-role in ("value-text",) + label-text-roles {
    let role-style = resolved-style.at(text-role)
    if "color" in role-style {
      role-style.fill = role-style.color
      let _ = role-style.remove("color")
      resolved-style.insert(text-role, role-style)
    }
  }

  resolved-style
}

// Wraps a rendered diagram in the theme's `scale` factor. `reflow: true` so
// surrounding layout (arrows, stacks, tables) sees the resized box instead of
// a visual-only transform that overlaps its neighbors.
#let scaled(th, body) = {
  let resolved-style = th
  if resolved-style.scale == 1.0 {
    body
  } else {
    scale(resolved-style.scale * 100%, reflow: true, body)
  }
}

#let edge-mark(spec, fill: none) = {
  let arrow-specification = spec
  if arrow-specification == "both" { (start: ">", end: ">", fill: fill) }
  else if arrow-specification == "start" { (start: ">", fill: fill) }
  else if arrow-specification == "end" or arrow-specification == true { (end: ">", fill: fill) }
  else { none }
}

#let _apply-dash-to-stroke(stroke, dash) = {
  if dash == none or dash == false { return stroke }
  if type(stroke) == dictionary { return stroke + (dash: dash) }
  if type(stroke) == color { return (paint: stroke, dash: dash) }
  (paint: stroke.paint, thickness: stroke.thickness, dash: dash)
}

#let _resolve-edge-pattern(resolved-style, customization) = {
  if customization != none and "pattern" in customization {
    return customization.pattern
  }
  if customization != none and customization.at("wave", default: false) {
    return "wavy"
  }
  let custom-dash = if customization == none {
    none
  } else {
    customization.at("dash", default: none)
  }
  if custom-dash not in (none, false) { return custom-dash }
  if resolved-style.at("edge-wave", default: false) { return "wavy" }
  let style-dash = resolved-style.at("edge-dash", default: none)
  if style-dash not in (none, false) { return style-dash }
  resolved-style.edge-pattern
}

#let _resolve-pattern-dash(pattern) = {
  if pattern in (none, false, "normal", "solid", "wavy", "wave") { return none }
  if pattern == "dash" { return "dashed" }
  if pattern in ("dot", "dots") { return "dotted" }
  pattern
}

#let edge-stroke(th, custom: none) = {
  let resolved-style = th
  let base-stroke = if custom != none and "stroke" in custom {
    custom.stroke
  } else if custom != none and "color" in custom {
    custom.color
  } else {
    resolved-style.edge-stroke
  }
  let edge-pattern = _resolve-edge-pattern(resolved-style, custom)
  _apply-dash-to-stroke(base-stroke, _resolve-pattern-dash(edge-pattern))
}

#let edge-arrow(th, directed, custom: none) = {
  let resolved-style = th
  let arrow-specification = if custom != none and "arrow" in custom {
    custom.arrow
  } else if resolved-style.edge-arrow not in (none, false) {
    resolved-style.edge-arrow
  } else if directed {
    "end"
  } else {
    none
  }
  edge-mark(arrow-specification, fill: resolved-style.edge-arrow-fill)
}

#let edge-wave(th, custom: none) = {
  let resolved-style = th
  _resolve-edge-pattern(resolved-style, custom) in ("wavy", "wave")
}

#let wavy-parts(p, q, th, start-tip: false, end-tip: false) = {
  let from-position = p
  let to-position = q
  let resolved-style = th
  let delta-x = to-position.at(0) - from-position.at(0)
  let delta-y = to-position.at(1) - from-position.at(1)
  let edge-length = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  if edge-length == 0 {
    return (
      points: (from-position, to-position),
      start-cap: from-position,
      end-cap: to-position,
    )
  }
  let unit-x = delta-x / edge-length
  let unit-y = delta-y / edge-length
  let node-cap-length = resolved-style.node-radius * 0.35
  let arrow-tip-cap-length = resolved-style.node-radius * 0.8
  let requested-start-cap = if start-tip {
    arrow-tip-cap-length
  } else {
    node-cap-length
  }
  let requested-end-cap = if end-tip {
    arrow-tip-cap-length
  } else {
    node-cap-length
  }
  let cap-scale = calc.min(
    1,
    edge-length * 0.7 / (requested-start-cap + requested-end-cap),
  )
  let start-cap-length = requested-start-cap * cap-scale
  let end-cap-length = requested-end-cap * cap-scale
  let start-ratio = start-cap-length / edge-length
  let end-ratio = 1 - end-cap-length / edge-length
  let usable-length = edge-length - start-cap-length - end-cap-length
  let wave-count = calc.max(
    1,
    calc.floor(usable-length / resolved-style.edge-wave-step + 0.5),
  )
  let sample-count = calc.max(8, calc.ceil(wave-count * 10))
  let start-cap-position = (
    from-position.at(0) + delta-x * start-ratio,
    from-position.at(1) + delta-y * start-ratio,
  )
  let end-cap-position = (
    from-position.at(0) + delta-x * end-ratio,
    from-position.at(1) + delta-y * end-ratio,
  )
  let points = if start-tip {
    (start-cap-position,)
  } else {
    (from-position, start-cap-position)
  }
  for sample-index in range(1, sample-count) {
    let sample-ratio = sample-index / sample-count
    let edge-ratio = (
      start-ratio + (end-ratio - start-ratio) * sample-ratio
    )
    let x = from-position.at(0) + delta-x * edge-ratio
    let y = from-position.at(1) + delta-y * edge-ratio
    let perpendicular-offset = (
      calc.sin(360deg * wave-count * sample-ratio)
        * resolved-style.edge-wave-amplitude
    )
    points.push((
      x - unit-y * perpendicular-offset,
      y + unit-x * perpendicular-offset,
    ))
  }
  points.push(end-cap-position)
  if not end-tip { points.push(to-position) }
  (
    points: points,
    start-cap: start-cap-position,
    end-cap: end-cap-position,
  )
}

#let wavy-points(p, q, th, start-tip: false, end-tip: false) = {
  wavy-parts(
    p,
    q,
    th,
    start-tip: start-tip,
    end-tip: end-tip,
  ).points
}

// Fallback highlight colors, used when a `<kind>-style` override dict omits
// `fill`. A marked node stays visually distinct even when you only override
// its shape or stroke, instead of quietly falling back to `node-fill`.
#let mark-defaults = (
  new: rgb("#C8E6C9"),
  path: rgb("#FFE9A8"),
  remove: rgb("#FFCDD2"),
  rotate: rgb("#BBDEFB"),
  visited: rgb("#C8E6C9"),
  current: rgb("#BBDEFB"),
  queued: rgb("#FFE9A8"),
)

// Resolves `resolved-style`'s `<kind>-style` value (a color, or a dict of `fill:`,
// `shape:`, `stroke:`, `node-radius:`, `text:`) into a complete per-node style. A
// plain color is shorthand for `(fill: color)`. With `diff-colors: false`,
// fills stay at `base-fill`, while shape/stroke/radius overrides still apply.
#let resolve-mark-style(th, kind, base-fill: auto) = {
  let resolved-style = th
  let mark-value = resolved-style.at(kind + "-style")
  let mark-overrides = if type(mark-value) == color {
    (fill: mark-value)
  } else {
    mark-value
  }
  let normal-fill = if base-fill == auto {
    resolved-style.node-fill
  } else {
    base-fill
  }
  let text-style = (
    resolved-style.value-text + mark-overrides.at("text", default: (:))
  )
  if "color" in text-style {
    text-style.fill = text-style.color
    let _ = text-style.remove("color")
  }
  (
    fill: if resolved-style.diff-colors {
      mark-overrides.at("fill", default: mark-defaults.at(kind))
    } else {
      normal-fill
    },
    shape: mark-overrides.at("shape", default: resolved-style.node-shape),
    stroke: mark-overrides.at("stroke", default: resolved-style.node-stroke),
    node-radius: mark-overrides.at(
      "node-radius",
      default: resolved-style.node-radius,
    ),
    text: text-style,
  )
}
