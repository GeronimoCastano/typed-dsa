// CeTZ rendering for validated graph state and resolved graph layouts.

#import "@preview/cetz:0.5.2"
#import "../shared/style.typ": (
  theme, scaled, edge-stroke, edge-arrow, edge-wave, wavy-parts,
)
#import "../shared/label-placement.typ": (
  external-label-directions, external-label-direction, external-label-center,
  measure-external-label, select-external-label-candidate,
)
#import "../shared/edge-path.typ": calculate-cubic-edge-segments, calculate-through-edge-segments, wavy-path-parts
#import cetz.draw: line, circle, rect, content, bezier-through, bezier
#import "model.typ": (
  _collect-graph-edges, _collect-graph-node-ids, _edge-display-label,
  _normalize-undirected-edge-key,
)
#import "layout.typ": (
  _calculate-graph-edge-bend-point, _calculate-node-boundary-radius, _calculate-graph-loop-geometry,
  _default-node-half-width, _fitted-node-half-width,
  _resolve-graph-node-radius, _resolve-graph-node-shape, _trim-edge-to-node-boundary,
)

// Looks up an edge's customization dict. Order matters for a directed graph
// (from -> to is a specific edge) but not for an undirected one.
#let _resolve-graph-edge-customization(customizations, from-node-id, to-node-id, directed) = {
  let requested-edge-key = if directed {
    from-node-id + "\u{0}" + to-node-id
  } else {
    _normalize-undirected-edge-key(from-node-id, to-node-id)
  }
  for (custom-from-id, custom-to-id, options) in customizations {
    let customized-edge-key = if directed {
      custom-from-id + "\u{0}" + custom-to-id
    } else {
      _normalize-undirected-edge-key(custom-from-id, custom-to-id)
    }
    if customized-edge-key == requested-edge-key { return options }
  }
  none
}

#let _select-automatic-edge-bend(
  from-node-id,
  to-node-id,
  node-ids,
  node-positions,
  node-boundaries,
) = {
  let from-position = node-positions.at(from-node-id)
  let to-position = node-positions.at(to-node-id)
  let delta-x = to-position.at(0) - from-position.at(0)
  let delta-y = to-position.at(1) - from-position.at(1)
  let edge-length = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  if edge-length == 0 { return none }
  let closest-obstacle = none
  let closest-obstacle-distance = float.inf
  let required-clearance = 0.0
  for obstacle-node-id in node-ids {
    if obstacle-node-id == from-node-id or obstacle-node-id == to-node-id { continue }
    let obstacle-position = node-positions.at(obstacle-node-id)
    let projection = (
      (obstacle-position.at(0) - from-position.at(0)) * delta-x
        + (obstacle-position.at(1) - from-position.at(1)) * delta-y
    ) / (edge-length * edge-length)
    if projection <= 0.05 or projection >= 0.95 { continue }
    let projected-x = from-position.at(0) + projection * delta-x
    let projected-y = from-position.at(1) + projection * delta-y
    let distance-x = obstacle-position.at(0) - projected-x
    let distance-y = obstacle-position.at(1) - projected-y
    let distance = calc.sqrt(distance-x * distance-x + distance-y * distance-y)
    let boundary = node-boundaries.at(obstacle-node-id)
    let obstacle-radius = calc.max(boundary.at(1), boundary.at(2))
    if distance >= obstacle-radius + 0.15 { continue }
    if distance < closest-obstacle-distance {
      closest-obstacle = (obstacle-node-id, distance-x * delta-y - distance-y * delta-x)
      closest-obstacle-distance = distance
      required-clearance = obstacle-radius + 0.15
    }
  }
  if closest-obstacle == none { return none }
  let side-cross-product = closest-obstacle.at(1)
  let bend-direction = if side-cross-product > 0 { "left" } else { "right" }
  let required-sagitta = required-clearance - closest-obstacle-distance + 0.15
  let suggested-angle = calc.min(
    60deg,
    calc.atan(2 * required-sagitta / edge-length),
  )
  (bend: bend-direction, angle: suggested-angle)
}

#let _resolve-graph-edge-routing(
  graph-edges,
  from-node-id,
  to-node-id,
  directed,
  edge-routing,
  custom,
  reciprocal-custom: none,
  node-ids: (),
  node-positions: none,
  node-boundaries: none,
) = {
  let options = if custom == none { (:) } else { custom }
  let has-reciprocal-edge = graph-edges.any(edge => (
    edge.at(0) == to-node-id and edge.at(1) == from-node-id
  ))
  let should-route-reciprocal-edge = (
    edge-routing == "auto" and directed and from-node-id != to-node-id
      and has-reciprocal-edge and "bend" not in options
  )
  if should-route-reciprocal-edge {
    let reciprocal-bend = if reciprocal-custom != none {
      reciprocal-custom.at("bend", default: none)
    } else {
      none
    }
    options.bend = if reciprocal-bend == true {
      "right"
    } else if reciprocal-bend in ("left", "right") {
      reciprocal-bend
    } else {
      "left"
    }
    if reciprocal-bend not in (none, false) {
      let reciprocal-angle = reciprocal-custom.at("angle", default: 25deg)
      options.angle = if reciprocal-angle == 0deg { 25deg } else { reciprocal-angle }
    }
  }
  if "bend" not in options and node-positions != none {
    let automatic-bend = _select-automatic-edge-bend(
      from-node-id,
      to-node-id,
      node-ids,
      node-positions,
      node-boundaries,
    )
    if automatic-bend != none {
      options.bend = automatic-bend.bend
      options.angle = automatic-bend.angle
    }
  }
  options
}

#let _resolve-graph-node-customization(customizations, node-id) = {
  for (custom-node-id, options) in customizations {
    if custom-node-id == node-id { return options }
  }
  none
}

#let _normalize-graph-text-style(style) = {
  let normalized-style = style
  if "color" in normalized-style {
    normalized-style.fill = normalized-style.color
    let _ = normalized-style.remove("color")
  }
  normalized-style
}

#let _lookup-graph-node-value(values, node-id) = {
  if type(values) == dictionary {
    if type(node-id) == str or type(node-id) == int or type(node-id) == float {
      return values.at(str(node-id), default: none)
    }
    return none
  }
  for (candidate-node-id, value) in values {
    if candidate-node-id == node-id { return value }
  }
  none
}


#let _trim-edge-to-boundary(node-position, toward-position, boundary) = _trim-edge-to-node-boundary(
  node-position,
  toward-position,
  boundary.at(1),
  shape: boundary.at(0),
  half-width: boundary.at(2),
)


#let _calculate-edge-label-position(p, q, from-boundary, to-boundary, custom, resolved-style) = {
  let dx = q.at(0) - p.at(0)
  let dy = q.at(1) - p.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)

  let base = if len == 0 { p } else {
    let bend = if custom != none { custom.at("bend", default: false) } else { false }
    if bend == false or bend == none {
      let ux = dx / len
      let uy = dy / len
      let a = _trim-edge-to-boundary(p, q, from-boundary)
      let b = _trim-edge-to-boundary(q, p, to-boundary)
      ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
    } else {
      let angle = if custom != none { custom.at("angle", default: 25deg) } else { 25deg }
      _calculate-graph-edge-bend-point(p, q, bend, angle)
    }
  }

  if len == 0 { return base }

  let ux = dx / len
  let uy = dy / len

  let o1x = -uy
  let o1y = ux
  let o2x = uy
  let o2y = -ux

  let bend = if custom != none { custom.at("bend", default: false) } else { false }

  // Choose the orthogonal shift direction.
  let (ox, oy) = if bend == "left" {
    (-uy, ux) // Shift further outward in the direction of the left bend
  } else if bend == "right" or bend == true {
    (uy, -ux) // Shift further outward in the direction of the right bend
  } else {
    // For straight edges, we want the orthogonal vector that points "up" (negative y).
    // If both have the same y (i.e. the edge is vertical, uy = 0), we pick right.
    if o1y < o2y {
      (o1x, o1y)
    } else if o1y > o2y {
      (o2x, o2y)
    } else {
      if o1x > 0 { (o1x, o1y) } else { (o2x, o2y) }
    }
  }

  let size = resolved-style.edge-label-text.at("size", default: 9pt)
  // Gap is 10% of size. But since text is centered, we also need to shift by 50% of size
  // so the text's bounding box clears the line. Total shift = 60% of size.
  // Convert pt to CetZ coordinate units (1 unit = 1cm = 28.346pt).
  let shift-pt = if type(size) == length { (size.to-absolute() / 1pt) * 0.6 } else { 6.0 }
  let gap = shift-pt / 28.346

  let bend-sign = if bend not in (none, false) and custom.at("angle", default: 25deg) < 0deg { -1 } else { 1 }
  (base.at(0) + ox * gap * bend-sign, base.at(1) + oy * gap * bend-sign)
}

// A node boundary is `(shape, radius, half-width)`: `radius` is the half-height,
// and `half-width` is the measured width for node-fit nodes.

#let _render-graph-edge(p, q, from-boundary, to-boundary, directed, resolved-style, custom) = {
  let stroke = edge-stroke(resolved-style, custom: custom)
  let mark = edge-arrow(resolved-style, directed, custom: custom)
  let bend = if custom != none { custom.at("bend", default: false) } else { false }
  if bend == false or bend == none {
    let dx = q.at(0) - p.at(0)
    let dy = q.at(1) - p.at(1)
    let len = calc.sqrt(dx * dx + dy * dy)
    if len == 0 { return }
    let ux = dx / len
    let uy = dy / len
    let a = _trim-edge-to-boundary(p, q, from-boundary)
    let b = _trim-edge-to-boundary(q, p, to-boundary)
    if edge-wave(resolved-style, custom: custom) {
      let start-tip = mark != none and "start" in mark
      let end-tip = mark != none and "end" in mark
      let parts = wavy-parts(a, b, resolved-style, start-tip: start-tip, end-tip: end-tip)
      line(..parts.points, stroke: stroke)
      let fill = if mark == none { none } else { mark.at("fill", default: none) }
      if start-tip { line(a, parts.start-cap, stroke: stroke, mark: (start: ">", fill: fill)) }
      if end-tip { line(parts.end-cap, b, stroke: stroke, mark: (end: ">", fill: fill)) }
    } else {
      line(a, b, stroke: stroke, mark: mark)
    }
  } else {
    let angle = if custom != none { custom.at("angle", default: 25deg) } else { 25deg }
    let bp = _calculate-graph-edge-bend-point(p, q, bend, angle)
    let p2 = _trim-edge-to-boundary(p, bp, from-boundary)
    let q2 = _trim-edge-to-boundary(q, bp, to-boundary)
    if edge-wave(resolved-style, custom: custom) {
      let start-tip = mark != none and "start" in mark
      let end-tip = mark != none and "end" in mark
      let parts = wavy-path-parts(calculate-through-edge-segments(p2, bp, q2), resolved-style, start-tip: start-tip, end-tip: end-tip)
      line(..parts.points, stroke: stroke)
      let fill = if mark == none { none } else { mark.at("fill", default: none) }
      if start-tip { line(p2, parts.start-cap, stroke: stroke, mark: (start: ">", fill: fill)) }
      if end-tip { line(parts.end-cap, q2, stroke: stroke, mark: (end: ">", fill: fill)) }
    } else {
      bezier-through(p2, bp, q2, stroke: stroke, mark: mark)
    }
  }
}

#let _resolve-graph-edge-label(label, resolved-style, custom) = {
  let body = label
  let text-style = resolved-style.edge-label-text
  if custom != none and "label" in custom {
    let options = custom.label
    if type(options) == dictionary {
      body = options.at("content", default: options.at("body", default: label))
      let text-overrides = options
      for key in ("content", "body") {
        if key in text-overrides { let _ = text-overrides.remove(key) }
      }
      text-style += _normalize-graph-text-style(text-overrides)
    } else {
      body = options
    }
  }
  (body: body, style: text-style)
}

#let _render-graph-edge-label(label, p, q, from-boundary, to-boundary, resolved-style, custom) = {
  let resolved-label = _resolve-graph-edge-label(label, resolved-style, custom)
  if resolved-label.body == none { return }
  let position = _calculate-edge-label-position(p, q, from-boundary, to-boundary, custom, resolved-style)
  let text-style = resolved-label.style
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  if rotation == "edge" {
    let dx = q.at(0) - p.at(0)
    let dy = q.at(1) - p.at(1)
    rotation = calc.atan2(dx, dy)
    if dx < 0 { rotation += 180deg }
  }
  content(position, text(..text-style)[#resolved-label.body], angle: rotation)
}

#let _render-graph-self-loop(position, boundary, label, directed, resolved-style, custom) = {
  let geometry = _calculate-graph-loop-geometry(
    position, boundary, bend: custom.at("bend", default: false),
  )
  bezier(
    geometry.start, geometry.end, geometry.control-start, geometry.control-end,
    stroke: edge-stroke(resolved-style, custom: custom),
    mark: edge-arrow(resolved-style, directed, custom: custom),
  )
  let label-override = custom.at("label", default: (:))
  let label-size = if type(label-override) == dictionary {
    label-override.at("size", default: resolved-style.edge-label-text.at("size", default: 9pt))
  } else { resolved-style.edge-label-text.at("size", default: 9pt) }
  let label-gap = if type(label-size) == length {
    (label-size.to-absolute() / 1pt) * 0.6 / 28.346
  } else { 0.22 }
  let label-position = (geometry.label.at(0), geometry.label.at(1) + geometry.side * label-gap)
  _render-graph-edge-label(label, label-position, label-position, none, none, resolved-style, custom)
}

#let _resolve-graph-node-label(resolved-style, node-labels, id) = {
  let raw = _lookup-graph-node-value(node-labels, id)
  if raw == none { return none }
  let body = raw
  let style = resolved-style.label-text
  let defaults = resolved-style.at("node-labels", default: (:))
  if not defaults.at("enabled", default: true) { return none }
  let position = defaults.at("position", default: "auto")
  let offset = defaults.at("offset", default: (0, 0))
  let gap = defaults.at("gap", default: 0.22)
  let d0 = defaults
  for key in ("position", "offset", "gap", "enabled") {
    if key in d0 { let _ = d0.remove(key) }
  }
  if "color" in d0 {
    d0.fill = d0.color
    let _ = d0.remove("color")
  }
  style = style + d0
  if type(raw) == dictionary {
    body = raw.at("content", default: raw.at("body", default: none))
    let d = raw
    let _ = d.remove("content", default: none)
    let _ = d.remove("body", default: none)
    if "position" in d {
      position = d.position
      let _ = d.remove("position")
    }
    if "offset" in d {
      offset = d.offset
      let _ = d.remove("offset")
    }
    if "gap" in d {
      gap = d.gap
      let _ = d.remove("gap")
    }
    if "color" in d {
      d.fill = d.color
      let _ = d.remove("color")
    }
    style = style + d
  }
  if body == none { return none }
  (body: body, style: style, position: position, offset: offset, gap: gap)
}

#let _render-graph-node-label(node-position, boundary, resolved-style, label) = {
  if label == none { return }
  let label-direction = external-label-direction(label.position)
  let offset-x = label.offset.at(0)
  let offset-y = label.offset.at(1)
  let label-gap = label.gap
  let boundary-distance = _calculate-node-boundary-radius(
    boundary.at(0),
    boundary.at(1),
    label-direction.at(0),
    label-direction.at(1),
    half-width: boundary.at(2),
  )
  let text-style = label.style
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  let label-size = measure(text(..text-style)[#label.body])
  let half-label-width = label-size.width / 1cm / 2
  let half-label-height = label-size.height / 1cm / 2
  let rotation-radians = rotation
  let rotated-half-width = (
    calc.abs(calc.cos(rotation-radians)) * half-label-width
      + calc.abs(calc.sin(rotation-radians)) * half-label-height
  )
  let rotated-half-height = (
    calc.abs(calc.sin(rotation-radians)) * half-label-width
      + calc.abs(calc.cos(rotation-radians)) * half-label-height
  )
  let projected-label-half-size = (
    calc.abs(label-direction.at(0)) * rotated-half-width
      + calc.abs(label-direction.at(1)) * rotated-half-height
  )
  let label-position = (
    node-position.at(0)
      + label-direction.at(0) * (boundary-distance + label-gap + projected-label-half-size)
      + offset-x,
    node-position.at(1)
      + label-direction.at(1) * (boundary-distance + label-gap + projected-label-half-size)
      + offset-y,
  )
  content(label-position, text(..text-style)[#label.body], angle: rotation)
}

#let _place-graph-node-label(node-id, node-position, boundary, label, node-ids, node-positions, node-boundaries, graph-edges, node-labels, resolved-style, directed, edge-customizations, edge-routing, placed-label-obstacles) = {
  if label == none or label.position != "auto" { return label }
  let text-style = label.style
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  let label-size = measure(text(..text-style)[#label.body])
  let half-width = label-size.width / 1cm / 2
  let half-height = label-size.height / 1cm / 2
  let rotated-half-width = calc.abs(calc.cos(rotation)) * half-width + calc.abs(calc.sin(rotation)) * half-height
  let rotated-half-height = calc.abs(calc.sin(rotation)) * half-width + calc.abs(calc.cos(rotation)) * half-height
  let candidates = ()
  for (position, direction) in external-label-directions {
    let boundary-distance = _calculate-node-boundary-radius(
      boundary.at(0), boundary.at(1), direction.at(0), direction.at(1),
      half-width: boundary.at(2),
    )
    let center = external-label-center(
      node-position, direction, boundary-distance, label.gap,
      rotated-half-width, rotated-half-height,
    )
    candidates.push((
      position: position,
      center: (center.at(0) + label.offset.at(0), center.at(1) + label.offset.at(1)),
      half-width: rotated-half-width,
      half-height: rotated-half-height,
    ))
  }
  let node-obstacles = ()
  for obstacle-id in node-ids {
    if obstacle-id == node-id { continue }
    let obstacle-position = node-positions.at(obstacle-id)
    let obstacle-boundary = node-boundaries.at(obstacle-id)
    node-obstacles.push((
      obstacle-position.at(0), obstacle-position.at(1),
      obstacle-boundary.at(2), obstacle-boundary.at(1),
    ))
  }
  let edge-obstacles = ()
  let edge-label-obstacles = ()
  for (from-id, to-id, edge-label) in graph-edges {
    let edge-customization = _resolve-graph-edge-customization(
      edge-customizations, from-id, to-id, directed,
    )
    let reciprocal-customization = if directed {
      _resolve-graph-edge-customization(edge-customizations, to-id, from-id, directed)
    } else { none }
    edge-customization = _resolve-graph-edge-routing(
      graph-edges, from-id, to-id, directed, edge-routing, edge-customization,
      reciprocal-custom: reciprocal-customization,
      node-ids: node-ids, node-positions: node-positions,
      node-boundaries: node-boundaries,
    )
    if from-id == to-id {
      let loop = _calculate-graph-loop-geometry(
        node-positions.at(from-id), node-boundaries.at(from-id),
        bend: edge-customization.at("bend", default: false),
      )
      edge-obstacles += calculate-cubic-edge-segments(
        loop.start, loop.control-start, loop.control-end, loop.end,
      )
      let resolved-label = _resolve-graph-edge-label(edge-label, resolved-style, edge-customization)
      let size = resolved-label.style.at("size", default: 9pt)
      let gap = (size.to-absolute() / 1pt) * 0.6 / 28.346
      let center = (loop.label.at(0), loop.label.at(1) + loop.side * gap)
      if resolved-label.body != none {
        let geometry = measure-external-label(resolved-label.body, resolved-label.style)
        edge-label-obstacles.push((center.at(0), center.at(1), geometry.half-width, geometry.half-height))
      }
      continue
    }
    let from-position = node-positions.at(from-id)
    let to-position = node-positions.at(to-id)
    let bend = edge-customization.at("bend", default: false)
    let edge-clearance = 0.04 + if edge-wave(resolved-style, custom: edge-customization) {
      resolved-style.edge-wave-amplitude
    } else { 0 }
    if bend == false or bend == none {
      edge-obstacles.push((
        _trim-edge-to-boundary(from-position, to-position, node-boundaries.at(from-id)),
        _trim-edge-to-boundary(to-position, from-position, node-boundaries.at(to-id)),
        edge-clearance,
      ))
    } else {
      let angle = edge-customization.at("angle", default: 25deg)
      let control = _calculate-graph-edge-bend-point(from-position, to-position, bend, angle)
      let start = _trim-edge-to-boundary(from-position, control, node-boundaries.at(from-id))
      let end = _trim-edge-to-boundary(to-position, control, node-boundaries.at(to-id))
      edge-obstacles += calculate-through-edge-segments(start, control, end, radius: edge-clearance)
    }
    let label-position = _calculate-edge-label-position(
      from-position, to-position, node-boundaries.at(from-id),
      node-boundaries.at(to-id), edge-customization, resolved-style,
    )
    let resolved-label = _resolve-graph-edge-label(edge-label, resolved-style, edge-customization)
    if resolved-label.body != none {
      let geometry = measure-external-label(resolved-label.body, resolved-label.style)
      edge-label-obstacles.push((label-position.at(0), label-position.at(1), geometry.half-width, geometry.half-height))
    }
  }
  let explicit-label-obstacles = ()
  for other-id in node-ids {
    if other-id == node-id { continue }
    let other-label = _resolve-graph-node-label(resolved-style, node-labels, other-id)
    if other-label == none or other-label.position == "auto" { continue }
    let other-direction = external-label-direction(other-label.position)
    let other-geometry = measure-external-label(other-label.body, other-label.style)
    let other-boundary = node-boundaries.at(other-id)
    let other-boundary-distance = _calculate-node-boundary-radius(
      other-boundary.at(0), other-boundary.at(1),
      other-direction.at(0), other-direction.at(1),
      half-width: other-boundary.at(2),
    )
    let other-center = external-label-center(
      node-positions.at(other-id), other-direction, other-boundary-distance,
      other-label.gap, other-geometry.half-width, other-geometry.half-height,
    )
    explicit-label-obstacles.push((
      other-center.at(0) + other-label.offset.at(0),
      other-center.at(1) + other-label.offset.at(1),
      other-geometry.half-width, other-geometry.half-height,
    ))
  }
  let selected-candidate = select-external-label-candidate(
    candidates, node-obstacles, edge-obstacles,
    label-obstacles: explicit-label-obstacles + edge-label-obstacles + placed-label-obstacles,
  )
  let positioned-label = label
  positioned-label.position = selected-candidate.position
  positioned-label._auto-center = selected-candidate.center
  positioned-label._auto-half-width = selected-candidate.half-width
  positioned-label._auto-half-height = selected-candidate.half-height
  positioned-label
}

// The text a node label is drawn with: the value-text role plus the node's
// `text:` customization. The rotation is split off because `text()` does not
// take it. Measuring and drawing both use this, so node-fit sees drawn text.
#let _resolve-graph-node-text(resolved-style, custom) = {
  let text-style = resolved-style.value-text
  if custom != none and "text" in custom { text-style = text-style + custom.text }
  text-style = _normalize-graph-text-style(text-style)
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  (style: text-style, rotation: rotation)
}

// Labels are measured in their drawn text style. `measure` needs the document
// styles, so callers must invoke this inside a `context` block.
#let _measure-fitted-node-half-widths(node-ids, labels, resolved-style, node-customizations) = {
  let measured-half-widths = (:)
  for node-id in node-ids {
    let node-customization = _resolve-graph-node-customization(node-customizations, node-id)
    let shape = _resolve-graph-node-shape(resolved-style, node-customization)
    let radius = _resolve-graph-node-radius(resolved-style, node-customization)
    let node-text = _resolve-graph-node-text(resolved-style, node-customization)
    let label-box = measure(text(..node-text.style, labels.at(node-id, default: node-id)))
    measured-half-widths.insert(
      node-id,
      _fitted-node-half-width(label-box.width / 1cm, shape, radius),
    )
  }
  measured-half-widths
}

// A node's boundary is `(shape, radius, half-width)`. Nodes that are not
// fitted use the default half-width for their shape.
#let _resolve-graph-node-boundary(resolved-style, custom, measured-half-width) = {
  let shape = _resolve-graph-node-shape(resolved-style, custom)
  let radius = _resolve-graph-node-radius(resolved-style, custom)
  let half-width = if measured-half-width == none {
    _default-node-half-width(shape, radius)
  } else {
    measured-half-width
  }
  (shape, radius, half-width)
}

#let _render-graph-node(label, p, boundary, resolved-style, custom) = {
  let shape = boundary.at(0)
  let r = boundary.at(1)
  let half-width = boundary.at(2)
  let fill = if custom != none and "fill" in custom { custom.fill } else { resolved-style.node-fill }
  let stroke = if custom != none and "stroke" in custom { custom.stroke } else { resolved-style.node-stroke }
  let node-text = _resolve-graph-node-text(resolved-style, custom)
  let polygon = pts => line(..pts, close: true, fill: fill, stroke: stroke)
  if shape == "square" {
    rect((p.at(0) - half-width, p.at(1) - r), (p.at(0) + half-width, p.at(1) + r), fill: fill, stroke: stroke)
  } else if shape == "rounded" {
    rect((p.at(0) - half-width, p.at(1) - r), (p.at(0) + half-width, p.at(1) + r), radius: 25%, fill: fill, stroke: stroke)
  } else if shape == "capsule" {
    rect((p.at(0) - half-width, p.at(1) - r), (p.at(0) + half-width, p.at(1) + r), radius: 50%, fill: fill, stroke: stroke)
  } else if shape == "diamond" {
    polygon(((p.at(0), p.at(1) + r), (p.at(0) + r, p.at(1)), (p.at(0), p.at(1) - r), (p.at(0) - r, p.at(1))))
  } else if shape == "hexagon" {
    let k = 0.86 * r
    polygon((
      (p.at(0) - r, p.at(1)),
      (p.at(0) - r / 2, p.at(1) + k),
      (p.at(0) + r / 2, p.at(1) + k),
      (p.at(0) + r, p.at(1)),
      (p.at(0) + r / 2, p.at(1) - k),
      (p.at(0) - r / 2, p.at(1) - k),
    ))
  } else {
    circle(p, radius: r, fill: fill, stroke: stroke)
  }
  content(p, text(..node-text.style, label), angle: node-text.rotation)
}

// Draws the graph once every node's boundary is known. `measured-half-widths`
// maps node ids to fitted half-widths, or is empty when no node is fitted.
#let _draw-graph-at-positions(
  adjacency,
  directed,
  labels,
  node-positions,
  edge-customizations,
  node-customizations,
  node-labels,
  resolved-style,
  edge-routing,
  measured-half-widths,
) = {
  let node-ids = _collect-graph-node-ids(adjacency)
  let graph-edges = _collect-graph-edges(adjacency, directed)
  let node-boundaries = (:)
  for node-id in node-ids {
    let node-customization = _resolve-graph-node-customization(
      node-customizations,
      node-id,
    )
    node-boundaries.insert(node-id, _resolve-graph-node-boundary(
      resolved-style,
      node-customization,
      measured-half-widths.at(node-id, default: none),
    ))
  }

  scaled(resolved-style, cetz.canvas({
    for (from-node-id, to-node-id, edge-label) in graph-edges {
      let edge-customization = _resolve-graph-edge-customization(
        edge-customizations,
        from-node-id,
        to-node-id,
        directed,
      )
      let reciprocal-customization = if directed {
        _resolve-graph-edge-customization(
          edge-customizations, to-node-id, from-node-id, directed,
        )
      } else {
        none
      }
      edge-customization = _resolve-graph-edge-routing(
        graph-edges,
        from-node-id,
        to-node-id,
        directed,
        edge-routing,
        edge-customization,
        reciprocal-custom: reciprocal-customization,
        node-ids: node-ids,
        node-positions: node-positions,
        node-boundaries: node-boundaries,
      )
      let from-boundary = node-boundaries.at(from-node-id)
      let to-boundary = node-boundaries.at(to-node-id)
      if from-node-id == to-node-id {
        _render-graph-self-loop(
          node-positions.at(from-node-id), from-boundary, edge-label,
          directed, resolved-style, edge-customization,
        )
      } else {
        _render-graph-edge(
          node-positions.at(from-node-id),
          node-positions.at(to-node-id),
          from-boundary,
          to-boundary,
          directed,
          resolved-style,
          edge-customization,
        )
        _render-graph-edge-label(
          edge-label,
          node-positions.at(from-node-id),
          node-positions.at(to-node-id),
          from-boundary,
          to-boundary,
          resolved-style,
          edge-customization,
        )
      }
    }
    let placed-auto-label-obstacles = ()
    for node-id in node-ids {
      let node-customization = _resolve-graph-node-customization(
        node-customizations,
        node-id,
      )
      let node-boundary = node-boundaries.at(node-id)
      _render-graph-node(
        labels.at(node-id, default: node-id),
        node-positions.at(node-id),
        node-boundary,
        resolved-style,
        node-customization,
      )
      let placed-label = _place-graph-node-label(
        node-id,
        node-positions.at(node-id),
        node-boundary,
        _resolve-graph-node-label(resolved-style, node-labels, node-id),
        node-ids,
        node-positions,
        node-boundaries,
        graph-edges,
        node-labels,
        resolved-style,
        directed,
        edge-customizations,
        edge-routing,
        placed-auto-label-obstacles,
      )
      if placed-label != none and "_auto-center" in placed-label {
        placed-auto-label-obstacles.push((
          placed-label._auto-center.at(0),
          placed-label._auto-center.at(1),
          placed-label._auto-half-width,
          placed-label._auto-half-height,
        ))
      }
      _render-graph-node-label(
        node-positions.at(node-id),
        node-boundary,
        resolved-style,
        placed-label,
      )
    }
  }))
}

#let _render-graph-at-positions(
  adjacency,
  directed,
  labels,
  node-positions,
  edge-customizations,
  node-customizations,
  node-labels,
  resolved-style,
  edge-routing: "manual",
) = {
  if not resolved-style.node-fit {
    return context _draw-graph-at-positions(
      adjacency, directed, labels, node-positions, edge-customizations,
      node-customizations, node-labels, resolved-style, edge-routing, (:),
    )
  }
  let node-ids = _collect-graph-node-ids(adjacency)
  context _draw-graph-at-positions(
    adjacency, directed, labels, node-positions, edge-customizations,
    node-customizations, node-labels, resolved-style, edge-routing,
    _measure-fitted-node-half-widths(node-ids, labels, resolved-style, node-customizations),
  )
}
