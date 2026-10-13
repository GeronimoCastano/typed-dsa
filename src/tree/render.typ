// CeTZ rendering for validated, laid-out tree state.

#import "@preview/cetz:0.5.2"
#import "../shared/style.typ": (
  theme, scaled, resolve-mark-style, edge-mark, edge-stroke, edge-wave,
  wavy-parts,
)
#import "../shared/label-placement.typ": (
  external-label-directions, external-label-direction, external-label-center,
  measure-external-label, select-external-label-candidate,
)
#import "../shared/edge-path.typ": calculate-through-edge-segments
#import cetz.draw: line, circle, rect, content, bezier-through
#import "layout.typ": _calculate-tree-layout, _calculate-tidy-tree-layout
#import "state.typ": _tree-node-id, _visible-tree-children

// ── Render ───────────────────────────────────────────────────────────────────

#let _maximum-height-label-half-width(tree-node, resolved-style) = {
  if tree-node == none { return 0.0 }
  let maximum-half-width = 0.0
  if tree-node.kind == "subtree" and tree-node.h-label != none {
    let label-style = resolved-style.value-text
    let rotation = label-style.at("rotation", default: 0deg)
    if "rotation" in label-style { let _ = label-style.remove("rotation") }
    let label-box = measure(
      text(..label-style)[#tree-node.h-label],
    )
    let label-half-width = label-box.width / 1cm / 2
    let label-half-height = label-box.height / 1cm / 2
    maximum-half-width = (
      calc.abs(calc.cos(rotation)) * label-half-width
        + calc.abs(calc.sin(rotation)) * label-half-height
    )
  }
  if tree-node.kind == "subtree" { return maximum-half-width }
  for child-node in _visible-tree-children(tree-node) {
    maximum-half-width = calc.max(
      maximum-half-width,
      _maximum-height-label-half-width(child-node, resolved-style),
    )
  }
  maximum-half-width
}

#let _maximum-subtree-half-width(tree-node, resolved-style) = {
  if tree-node == none { return 0.0 }
  let maximum-half-width = 0.0
  if tree-node.kind == "subtree" {
    maximum-half-width = resolved-style.tri-w / 2 * tree-node.tscale
    if tree-node.h-label != none {
      maximum-half-width += 0.4
        + 2 * resolved-style.at("_height-label-half-width", default: 0)
    }
    return maximum-half-width
  }
  for child-node in _visible-tree-children(tree-node) {
    maximum-half-width = calc.max(
      maximum-half-width,
      _maximum-subtree-half-width(child-node, resolved-style),
    )
  }
  maximum-half-width
}

#let _calculate-tree-layout-style(root, resolved-style, node-customizations, style) = {
  let height-label-half-width = _maximum-height-label-half-width(
    root,
    resolved-style,
  )
  let layout-style = resolved-style
  layout-style._height-label-half-width = height-label-half-width
  let maximum-node-radius = resolved-style.node-radius
  let maximum-node-width-factor = if resolved-style.node-shape == "capsule" { 1.4 } else { 1.0 }
  for (_, customization) in node-customizations {
    let radius = customization.at("node-radius", default: resolved-style.node-radius)
    let shape = customization.at("shape", default: resolved-style.node-shape)
    maximum-node-radius = calc.max(maximum-node-radius, radius)
    if shape == "capsule" { maximum-node-width-factor = 1.4 }
  }
  for mark-kind in ("new", "path", "remove", "rotate") {
    let mark-style = resolve-mark-style(resolved-style, mark-kind)
    maximum-node-radius = calc.max(maximum-node-radius, mark-style.node-radius)
    if mark-style.shape == "capsule" { maximum-node-width-factor = 1.4 }
  }
  let maximum-node-half-width = maximum-node-width-factor * maximum-node-radius
  layout-style._maximum-node-radius = maximum-node-radius
  layout-style._maximum-node-half-width = maximum-node-half-width
  let maximum-subtree-half-width = _maximum-subtree-half-width(
    root,
    layout-style,
  )
  let maximum-horizontal-half-width = calc.max(
    maximum-node-half-width,
    maximum-subtree-half-width,
  )
  let required-horizontal-gap = 2 * maximum-horizontal-half-width + 0.24
  layout-style.x-gap = calc.max(
    resolved-style.x-gap,
    required-horizontal-gap,
  )
  layout-style.y-gap = calc.max(
    resolved-style.y-gap,
    2 * maximum-node-radius + 0.24,
  )
  layout-style
}

#let _tree-node-position(tree-node, resolved-style) = (
  tree-node._col * resolved-style.x-gap,
  -tree-node._depth * resolved-style.y-gap,
)

#let _resolve-tree-edge-customization(customizations, from-node-id, to-node-id) = {
  for (custom-from-id, custom-to-id, options) in customizations {
    if custom-from-id == from-node-id and custom-to-id == to-node-id {
      return options
    }
  }
  none
}

#let _resolve-tree-node-customization(customizations, node-id) = {
  for (custom-node-id, options) in customizations {
    if custom-node-id == node-id { return options }
  }
  none
}

#let _normalize-text-style(style) = {
  let normalized-style = style
  if "color" in normalized-style {
    normalized-style.fill = normalized-style.color
    let _ = normalized-style.remove("color")
  }
  normalized-style
}

#let _lookup-node-value(values, node-id) = {
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

#let _resolve-node-radius(resolved-style, mark: none, custom: none) = {
  if custom != none and "node-radius" in custom { return custom.node-radius }
  if mark != none { return mark.node-radius }
  resolved-style.node-radius
}

#let _resolve-node-shape(resolved-style, mark: none, custom: none) = {
  if custom != none and "shape" in custom { return custom.shape }
  if mark != none { return mark.shape }
  resolved-style.node-shape
}

#let _calculate-shape-boundary-radius(shape, node-radius, unit-x, unit-y) = {
  if shape in ("square", "rounded") {
    return node-radius / calc.max(calc.abs(unit-x), calc.abs(unit-y))
  }
  if shape == "diamond" {
    return node-radius / (calc.abs(unit-x) + calc.abs(unit-y))
  }
  if shape == "capsule" {
    let horizontal-radius-offset = 0.4 * node-radius
    return horizontal-radius-offset * calc.abs(unit-x) + calc.sqrt(
      node-radius * node-radius
        - horizontal-radius-offset * horizontal-radius-offset * unit-y * unit-y,
    )
  }
  node-radius
}

#let _trim-edge-to-shape(from-position, toward-position, shape, node-radius) = {
  let delta-x = toward-position.at(0) - from-position.at(0)
  let delta-y = toward-position.at(1) - from-position.at(1)
  let distance = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  if distance == 0 { return from-position }
  let unit-x = delta-x / distance
  let unit-y = delta-y / distance
  let boundary-distance = _calculate-shape-boundary-radius(
    shape,
    node-radius,
    unit-x,
    unit-y,
  )
  (
    from-position.at(0) + unit-x * boundary-distance,
    from-position.at(1) + unit-y * boundary-distance,
  )
}

#let _calculate-edge-bend-point(from-position, to-position, bend-direction, angle) = {
  let delta-x = to-position.at(0) - from-position.at(0)
  let delta-y = to-position.at(1) - from-position.at(1)
  let distance = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  let midpoint-x = (from-position.at(0) + to-position.at(0)) / 2
  let midpoint-y = (from-position.at(1) + to-position.at(1)) / 2
  if distance == 0 { return (midpoint-x, midpoint-y) }
  let unit-x = delta-x / distance
  let unit-y = delta-y / distance
  let (perpendicular-x, perpendicular-y) = if bend-direction == "left" {
    (-unit-y, unit-x)
  } else {
    (unit-y, -unit-x)
  }
  let sagitta = (distance / 2) * calc.tan(angle)
  (
    midpoint-x + perpendicular-x * sagitta,
    midpoint-y + perpendicular-y * sagitta,
  )
}


#let _render-tree-edge(
  from-position,
  to-position,
  from-boundary,
  to-boundary,
  resolved-style,
  customization,
) = {
  let delta-x = to-position.at(0) - from-position.at(0)
  let delta-y = to-position.at(1) - from-position.at(1)
  let distance = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  if distance == 0 { return }
  let arrow-mark = edge-mark(
    if customization != none and "arrow" in customization {
      customization.arrow
    } else {
      resolved-style.edge-arrow
    },
  )
  let stroke = edge-stroke(resolved-style, custom: customization)
  let bend-direction = if customization != none {
    customization.at("bend", default: false)
  } else {
    false
  }
  if bend-direction != false and bend-direction != none {
    let bend-position = _calculate-edge-bend-point(
      from-position,
      to-position,
      bend-direction,
      customization.at("angle", default: 25deg),
    )
    let trimmed-start = _trim-edge-to-shape(
      from-position,
      bend-position,
      from-boundary.at(0),
      from-boundary.at(1),
    )
    let trimmed-end = _trim-edge-to-shape(
      to-position,
      bend-position,
      to-boundary.at(0),
      to-boundary.at(1),
    )
    bezier-through(
      trimmed-start,
      bend-position,
      trimmed-end,
      stroke: stroke,
      mark: arrow-mark,
    )
  } else {
    let trimmed-start = _trim-edge-to-shape(
      from-position,
      to-position,
      from-boundary.at(0),
      from-boundary.at(1),
    )
    let trimmed-end = _trim-edge-to-shape(
      to-position,
      from-position,
      to-boundary.at(0),
      to-boundary.at(1),
    )
    if edge-wave(resolved-style, custom: customization) {
      let has-start-tip = arrow-mark != none and "start" in arrow-mark
      let has-end-tip = arrow-mark != none and "end" in arrow-mark
      let wave-parts = wavy-parts(
        trimmed-start,
        trimmed-end,
        resolved-style,
        start-tip: has-start-tip,
        end-tip: has-end-tip,
      )
      line(..wave-parts.points, stroke: stroke)
      let arrow-fill = if arrow-mark == none {
        none
      } else {
        arrow-mark.at("fill", default: none)
      }
      if has-start-tip {
        line(
          trimmed-start,
          wave-parts.start-cap,
          stroke: stroke,
          mark: (start: ">", fill: arrow-fill),
        )
      }
      if has-end-tip {
        line(
          wave-parts.end-cap,
          trimmed-end,
          stroke: stroke,
          mark: (end: ">", fill: arrow-fill),
        )
      }
    } else {
      line(trimmed-start, trimmed-end, stroke: stroke, mark: arrow-mark)
    }
  }
}


#let _resolve-tree-edge-label(resolved-style, custom) = {
  let style = resolved-style.edge-label-text
  let body = none
  if custom != none and "label" in custom {
    let lbl = custom.label
    if type(lbl) == dictionary {
      body = lbl.at("content", default: lbl.at("body", default: none))
      let d = lbl
      let _ = d.remove("content", default: none)
      let _ = d.remove("body", default: none)
      if "color" in d {
        d.fill = d.color
        let _ = d.remove("color")
      }
      style = style + d
    } else {
      body = lbl
    }
  }
  (body: body, style: style)
}

#let _resolve-tree-node-label(resolved-style, node-labels, id) = {
  let raw = _lookup-node-value(node-labels, id)
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

#let _render-tree-node-label(node-position, boundary, resolved-style, label) = {
  if label == none { return }
  let label-direction = external-label-direction(label.position)
  let offset-x = label.offset.at(0)
  let offset-y = label.offset.at(1)
  let label-gap = label.gap
  let boundary-distance = _calculate-shape-boundary-radius(
    boundary.at(0),
    boundary.at(1),
    label-direction.at(0),
    label-direction.at(1),
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

#let _place-tree-node-label(node-id, node-position, boundary, label, obstacles, placed-label-obstacles) = {
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
    let boundary-distance = _calculate-shape-boundary-radius(
      boundary.at(0), boundary.at(1), direction.at(0), direction.at(1),
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
  for obstacle in obstacles.nodes {
    if obstacle.at(0) == node-id { continue }
    node-obstacles.push(obstacle.slice(1))
  }
  let selected-candidate = select-external-label-candidate(
    candidates, node-obstacles, obstacles.edges,
    label-obstacles: obstacles.labels + placed-label-obstacles,
  )
  let positioned-label = label
  positioned-label.position = selected-candidate.position
  positioned-label._auto-center = selected-candidate.center
  positioned-label._auto-half-width = selected-candidate.half-width
  positioned-label._auto-half-height = selected-candidate.half-height
  positioned-label
}

#let _render-tree-edge-label(p, q, r1, r2, resolved-style, custom) = {
  let lbl = _resolve-tree-edge-label(resolved-style, custom)
  if lbl.body == none { return }
  let dx = q.at(0) - p.at(0)
  let dy = q.at(1) - p.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }
  let ux = dx / len
  let uy = dy / len
  let a = _trim-edge-to-shape(p, q, r1.at(0), r1.at(1))
  let b = _trim-edge-to-shape(q, p, r2.at(0), r2.at(1))
  let bend = if custom != none { custom.at("bend", default: false) } else { false }
  let base = if bend == false or bend == none {
    ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
  } else {
    _calculate-edge-bend-point(p, q, bend, if custom != none { custom.at("angle", default: 25deg) } else { 25deg })
  }
  let (ox, oy) = if bend == "right" {
    (uy, -ux)
  } else if bend == "left" {
    (-uy, ux)
  } else if dx < 0 {
    (uy, -ux)
  } else {
    (-uy, ux)
  }
  let shift = 0.16
  let text-style = lbl.style
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  if rotation == "edge" {
    rotation = calc.atan2(dx, dy)
    if dx < 0 { rotation += 180deg }
  }
  content((base.at(0) + ox * shift, base.at(1) + oy * shift), text(..text-style)[#lbl.body], angle: rotation)
}

#let _render-tree-edges(tree-node, resolved-style, edge-customizations, node-customizations) = {
  if tree-node == none or tree-node.kind == "subtree" { return }
  let parent-position = _tree-node-position(tree-node, resolved-style)
  for child-node in _visible-tree-children(tree-node) {
    if child-node != none {
      let child-position = _tree-node-position(child-node, resolved-style)
      let parent-customization = _resolve-tree-node-customization(
        node-customizations,
        _tree-node-id(tree-node),
      )
      let child-customization = _resolve-tree-node-customization(
        node-customizations,
        _tree-node-id(child-node),
      )
      let parent-boundary = (
        _resolve-node-shape(
          resolved-style,
          custom: parent-customization,
        ),
        _resolve-node-radius(
          resolved-style,
          custom: parent-customization,
        ),
      )
      let child-boundary = if child-node.kind == "subtree" {
        ("circle", 0)
      } else {
        (
          _resolve-node-shape(
            resolved-style,
            custom: child-customization,
          ),
          _resolve-node-radius(
            resolved-style,
            custom: child-customization,
          ),
        )
      }
      let edge-customization = _resolve-tree-edge-customization(
        edge-customizations,
        _tree-node-id(tree-node),
        _tree-node-id(child-node),
      )
      _render-tree-edge(
        parent-position,
        child-position,
        parent-boundary,
        child-boundary,
        resolved-style,
        edge-customization,
      )
      _render-tree-edge-label(
        parent-position,
        child-position,
        parent-boundary,
        child-boundary,
        resolved-style,
        edge-customization,
      )
      _render-tree-edges(
        child-node,
        resolved-style,
        edge-customizations,
        node-customizations,
      )
    }
  }
}

// `mark` is `none` (use `resolved-style`'s node defaults and `fill`) or a resolved dict
// from `mark-style`, overriding the shape/stroke/radius/text of this node.
#let _render-tree-node-shape(p, label, resolved-style, fill, mark: none, custom: none) = {
  let shape = _resolve-node-shape(resolved-style, mark: mark, custom: custom)
  let r = _resolve-node-radius(resolved-style, mark: mark, custom: custom)
  let stroke = if custom != none and "stroke" in custom { custom.stroke } else if mark != none { mark.stroke } else { resolved-style.node-stroke }
  let f = if custom != none and "fill" in custom { custom.fill } else if mark != none { mark.fill } else { fill }
  let text-style = if mark != none { mark.text } else { resolved-style.value-text }
  if custom != none and "text" in custom { text-style = text-style + custom.text }
  text-style = _normalize-text-style(text-style)
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  let polygon = pts => line(..pts, close: true, fill: f, stroke: stroke)
  if shape == "square" {
    rect((p.at(0) - r, p.at(1) - r), (p.at(0) + r, p.at(1) + r), fill: f, stroke: stroke)
  } else if shape == "rounded" {
    rect((p.at(0) - r, p.at(1) - r), (p.at(0) + r, p.at(1) + r), radius: 25%, fill: f, stroke: stroke)
  } else if shape == "capsule" {
    rect((p.at(0) - 1.4 * r, p.at(1) - r), (p.at(0) + 1.4 * r, p.at(1) + r), radius: 50%, fill: f, stroke: stroke)
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
    circle(p, radius: r, fill: f, stroke: stroke)
  }
  content(p, text(..text-style)[#label], angle: rotation)
}

#let _render-subtree-triangle(subtree-node, resolved-style) = {
  let node-position = _tree-node-position(subtree-node, resolved-style)
  let triangle-scale = subtree-node.tscale
  let half-width = resolved-style.tri-w / 2 * triangle-scale
  let triangle-height = resolved-style.tri-h * triangle-scale
  let fill-tint = subtree-node.fill
  let stroke = if fill-tint == none {
    resolved-style.node-stroke
  } else {
    1pt + fill-tint
  }
  let text-style = if fill-tint == none {
    resolved-style.value-text
  } else {
    resolved-style.value-text + (fill: fill-tint)
  }
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  line(
    node-position,
    (
      node-position.at(0) - half-width,
      node-position.at(1) - triangle-height,
    ),
    (
      node-position.at(0) + half-width,
      node-position.at(1) - triangle-height,
    ),
    close: true,
    stroke: stroke,
  )
  content(
    (
      node-position.at(0),
      node-position.at(1) - triangle-height * 0.62,
    ),
    text(..text-style, subtree-node.label),
    angle: rotation,
  )
  if subtree-node.h-label != none {
    let bracket-gap = 0.32
    let bracket-x = node-position.at(0) - half-width - bracket-gap
    let height-label-box = measure(
      text(..text-style)[#subtree-node.h-label],
    )
    let height-label-half-width = height-label-box.width / 1cm / 2
    let height-label-half-height = height-label-box.height / 1cm / 2
    let height-label-half-extent = (
      calc.abs(calc.cos(rotation)) * height-label-half-width
        + calc.abs(calc.sin(rotation)) * height-label-half-height
    )
    line(
      (bracket-x, node-position.at(1)),
      (bracket-x, node-position.at(1) - triangle-height),
      stroke: stroke,
      mark: (start: ">", end: ">"),
    )
    content(
      (
        bracket-x - height-label-half-extent - 0.08,
        node-position.at(1) - triangle-height / 2,
      ),
      text(..text-style, subtree-node.h-label),
      angle: rotation,
    )
  }
}

#let _collect-tree-label-obstacles(tree-node, resolved-style, node-customizations, node-labels, edge-customizations) = {
  let nodes = ()
  let edges = ()
  let labels = ()
  let targets = ()
  if tree-node == none { return (nodes: nodes, edges: edges, labels: labels, targets: targets) }
  if tree-node.kind == "subtree" {
    let node-position = _tree-node-position(tree-node, resolved-style)
    let half-width = resolved-style.tri-w * tree-node.tscale / 2
    let half-height = resolved-style.tri-h * tree-node.tscale
    nodes.push((
      _tree-node-id(tree-node), node-position.at(0),
      node-position.at(1) - half-height / 2, half-width, half-height / 2,
    ))
    if tree-node.h-label != none {
      let label-style = resolved-style.value-text
      let geometry = measure-external-label(tree-node.h-label, label-style)
      labels.push((
        node-position.at(0) - half-width - geometry.half-width - 0.40,
        node-position.at(1) - half-height / 2,
        geometry.half-width, geometry.half-height,
      ))
    }
    return (nodes: nodes, edges: edges, labels: labels, targets: targets)
  }
  let node-id = _tree-node-id(tree-node)
  let node-position = _tree-node-position(tree-node, resolved-style)
  let node-customization = _resolve-tree-node-customization(node-customizations, node-id)
  let node-shape = _resolve-node-shape(resolved-style, custom: node-customization)
  let node-radius = _resolve-node-radius(resolved-style, custom: node-customization)
  let node-half-width = if node-shape == "capsule" { 1.4 * node-radius } else { node-radius }
  nodes.push((node-id, node-position.at(0), node-position.at(1), node-half-width, node-radius))
  targets.push((node-id, node-position, (node-shape, node-radius)))
  let node-label = _resolve-tree-node-label(resolved-style, node-labels, node-id)
  if node-label != none and node-label.position != "auto" {
    let direction = external-label-direction(node-label.position)
    let geometry = measure-external-label(node-label.body, node-label.style)
    let boundary-distance = _calculate-shape-boundary-radius(
      node-shape, node-radius, direction.at(0), direction.at(1),
    )
    let label-center = external-label-center(
      node-position, direction, boundary-distance, node-label.gap,
      geometry.half-width, geometry.half-height,
    )
    labels.push((
      label-center.at(0) + node-label.offset.at(0),
      label-center.at(1) + node-label.offset.at(1),
      geometry.half-width, geometry.half-height,
    ))
  }
  for child-node in _visible-tree-children(tree-node) {
    if child-node == none { continue }
    let child-position = _tree-node-position(child-node, resolved-style)
    let child-id = _tree-node-id(child-node)
    let child-customization = _resolve-tree-node-customization(node-customizations, child-id)
    let child-shape = if child-node.kind == "subtree" {
      "circle"
    } else {
      _resolve-node-shape(resolved-style, custom: child-customization)
    }
    let child-radius = if child-node.kind == "subtree" {
      0
    } else {
      _resolve-node-radius(resolved-style, custom: child-customization)
    }
    let edge-customization = _resolve-tree-edge-customization(
      edge-customizations, node-id, child-id,
    )
    let bend = if edge-customization == none { false } else { edge-customization.at("bend", default: false) }
    let start = _trim-edge-to-shape(node-position, child-position, node-shape, node-radius)
    let end = _trim-edge-to-shape(child-position, node-position, child-shape, child-radius)
    if bend == false or bend == none {
      edges.push((start, end, 0.04))
    } else {
      let control = _calculate-edge-bend-point(
        node-position, child-position, bend,
        edge-customization.at("angle", default: 25deg),
      )
      let first = _trim-edge-to-shape(node-position, control, node-shape, node-radius)
      let last = _trim-edge-to-shape(child-position, control, child-shape, child-radius)
      edges += calculate-through-edge-segments(first, control, last)
    }
    let edge-label = _resolve-tree-edge-label(resolved-style, edge-customization)
    if edge-label.body != none {
      let dx = child-position.at(0) - node-position.at(0)
      let dy = child-position.at(1) - node-position.at(1)
      let distance = calc.sqrt(dx * dx + dy * dy)
      if distance > 0 {
        let ux = dx / distance
        let uy = dy / distance
        let base = if bend == false or bend == none {
          ((start.at(0) + end.at(0)) / 2, (start.at(1) + end.at(1)) / 2)
        } else {
          _calculate-edge-bend-point(
            node-position, child-position, bend,
            edge-customization.at("angle", default: 25deg),
          )
        }
        let (offset-x, offset-y) = if bend == "right" {
          (uy, -ux)
        } else if bend == "left" {
          (-uy, ux)
        } else if dx < 0 { (uy, -ux) } else { (-uy, ux) }
        let geometry = measure-external-label(edge-label.body, edge-label.style)
        labels.push((base.at(0) + offset-x * 0.16, base.at(1) + offset-y * 0.16, geometry.half-width, geometry.half-height))
      }
    }
    let child-obstacles = _collect-tree-label-obstacles(
      child-node, resolved-style, node-customizations, node-labels, edge-customizations,
    )
    nodes += child-obstacles.nodes
    edges += child-obstacles.edges
    labels += child-obstacles.labels
    targets += child-obstacles.targets
  }
  (nodes: nodes, edges: edges, labels: labels, targets: targets)
}

#let _resolve-tree-node-label-placements(targets, resolved-style, node-labels, obstacles) = {
  let positioned-labels = ()
  let placed-label-obstacles = ()
  for (node-id, node-position, boundary) in targets {
    let label = _resolve-tree-node-label(resolved-style, node-labels, node-id)
    let positioned-label = _place-tree-node-label(
      node-id, node-position, boundary, label, obstacles, placed-label-obstacles,
    )
    if positioned-label != none and "_auto-center" in positioned-label {
      placed-label-obstacles.push((
        positioned-label._auto-center.at(0), positioned-label._auto-center.at(1),
        positioned-label._auto-half-width, positioned-label._auto-half-height,
      ))
    }
    if positioned-label != none { positioned-labels.push((node-id, positioned-label)) }
  }
  positioned-labels
}

#let _render-tree-nodes(tree-node, resolved-style, marks, node-customizations, positioned-labels) = {
  if tree-node == none { return }
  if tree-node.kind == "subtree" {
    _render-subtree-triangle(tree-node, resolved-style)
    return
  }
  for child-node in _visible-tree-children(tree-node) {
    _render-tree-nodes(
      child-node,
      resolved-style,
      marks,
      node-customizations,
      positioned-labels,
    )
  }
  let node-key = tree-node.at("key", default: none)
  let fill-tint = tree-node.at("fill", default: none)
  let display-label = tree-node.at("label", default: none)
  if display-label == none { display-label = str(node-key) }
  let node-id = _tree-node-id(tree-node)
  let node-customization = _resolve-tree-node-customization(
    node-customizations,
    node-id,
  )
  // A hand-composed node(fill:) tint takes priority over an operation
  // highlight; generated bst/avl nodes never set `.fill`, so the two never
  // actually collide.
  if fill-tint != none {
    _render-tree-node-shape(
      _tree-node-position(tree-node, resolved-style),
      display-label,
      resolved-style,
      fill-tint,
      custom: node-customization,
    )
  } else {
    let mark-kind = if node-key == none {
      none
    } else {
      marks.at(str(node-key), default: none)
    }
    let mark-style = if mark-kind != none {
      resolve-mark-style(
        resolved-style,
        mark-kind,
        base-fill: resolved-style.node-fill,
      )
    } else {
      none
    }
    _render-tree-node-shape(
      _tree-node-position(tree-node, resolved-style),
      display-label,
      resolved-style,
      resolved-style.node-fill,
      mark: mark-style,
      custom: node-customization,
    )
  }
  let node-boundary = (
    _resolve-node-shape(resolved-style, custom: node-customization),
    _resolve-node-radius(resolved-style, custom: node-customization),
  )
  _render-tree-node-label(
    _tree-node-position(tree-node, resolved-style),
    node-boundary,
    resolved-style,
    _lookup-node-value(positioned-labels, node-id),
  )
}

// `marks` maps `str(key)` to a highlight kind ("new"/"path"/"remove"/"rotate"),
// resolved against `resolved-style`'s `<kind>-style` via `mark-style` at draw time — so a
// per-call `style:` override actually reaches the mark, not just the theme
// default.
#let _render-tree(root, marks: (:), resolved-style: theme, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:)) = {
  if root == none { return scaled(resolved-style, cetz.canvas({ circle((0, 0), radius: 0.01, stroke: none) })) }
  context {
    let layout-style = _calculate-tree-layout-style(
      root,
      resolved-style,
      node-customizations,
      style,
    )
    let placed = if layout-style.tree-layout == "tidy" {
      _calculate-tidy-tree-layout(root, layout-style)
    } else {
      _calculate-tree-layout(root, 0, 0).first()
    }
    let placement-obstacles = _collect-tree-label-obstacles(
      placed, layout-style, node-customizations, node-labels, edge-customizations,
    )
    let positioned-labels = _resolve-tree-node-label-placements(
      placement-obstacles.targets, layout-style, node-labels, placement-obstacles,
    )
    scaled(layout-style, cetz.canvas({
      _render-tree-edges(placed, layout-style, edge-customizations, node-customizations)
      _render-tree-nodes(placed, layout-style, marks, node-customizations, positioned-labels)
    }))
  }
}
