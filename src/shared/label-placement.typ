// Shared geometry for selecting an external node-label direction.

#let external-label-directions = (
  ("right", (1, 0)),
  ("left", (-1, 0)),
  ("top", (0, 1)),
  ("bottom", (0, -1)),
  ("top-right", (0.7071067812, 0.7071067812)),
  ("top-left", (-0.7071067812, 0.7071067812)),
  ("bottom-right", (0.7071067812, -0.7071067812)),
  ("bottom-left", (-0.7071067812, -0.7071067812)),
)

#let external-label-direction(position) = {
  for (name, direction) in external-label-directions {
    if position == name { return direction }
  }
  if type(position) == angle { return (calc.cos(position), calc.sin(position)) }
  (1, 0)
}

#let external-label-center(node-position, direction, boundary-distance, gap, half-width, half-height) = {
  let projected-half-size = (
    calc.abs(direction.at(0)) * half-width
      + calc.abs(direction.at(1)) * half-height
  )
  (
    node-position.at(0) + direction.at(0) * (boundary-distance + gap + projected-half-size),
    node-position.at(1) + direction.at(1) * (boundary-distance + gap + projected-half-size),
  )
}

#let measure-external-label(body, style) = {
  let text-style = style
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  let label-size = measure(text(..text-style)[#body])
  let half-width = label-size.width / 1cm / 2
  let half-height = label-size.height / 1cm / 2
  if type(rotation) == str {
    let bounding-radius = calc.sqrt(half-width * half-width + half-height * half-height)
    return (rotation: 0deg, half-width: bounding-radius, half-height: bounding-radius)
  }
  (
    rotation: rotation,
    half-width: calc.abs(calc.cos(rotation)) * half-width + calc.abs(calc.sin(rotation)) * half-height,
    half-height: calc.abs(calc.sin(rotation)) * half-width + calc.abs(calc.cos(rotation)) * half-height,
  )
}

#let _label-rectangle-overlap-area(center, half-width, half-height, obstacle) = {
  let overlap-width = calc.max(
    0,
    calc.min(center.at(0) + half-width, obstacle.at(0) + obstacle.at(2))
      - calc.max(center.at(0) - half-width, obstacle.at(0) - obstacle.at(2)),
  )
  let overlap-height = calc.max(
    0,
    calc.min(center.at(1) + half-height, obstacle.at(1) + obstacle.at(3))
      - calc.max(center.at(1) - half-height, obstacle.at(1) - obstacle.at(3)),
  )
  overlap-width * overlap-height
}

#let _segment-label-rectangle-penalty(center, half-width, half-height, segment) = {
  let from = segment.at(0)
  let to = segment.at(1)
  let delta-x = to.at(0) - from.at(0)
  let delta-y = to.at(1) - from.at(1)
  let radius = segment.at(2)
  let x-minimum = center.at(0) - half-width - radius
  let x-maximum = center.at(0) + half-width + radius
  let y-minimum = center.at(1) - half-height - radius
  let y-maximum = center.at(1) + half-height + radius
  let first-fraction = 0.0
  let last-fraction = 1.0
  let intersects = true
  for (origin, delta, minimum, maximum) in (
    (from.at(0), delta-x, x-minimum, x-maximum),
    (from.at(1), delta-y, y-minimum, y-maximum),
  ) {
    if delta == 0 {
      if origin < minimum or origin > maximum { intersects = false }
    } else {
      let first-crossing = (minimum - origin) / delta
      let last-crossing = (maximum - origin) / delta
      first-fraction = calc.max(
        first-fraction, calc.min(first-crossing, last-crossing),
      )
      last-fraction = calc.min(
        last-fraction, calc.max(first-crossing, last-crossing),
      )
      if first-fraction > last-fraction { intersects = false }
    }
  }
  if intersects { 1.0 + last-fraction - first-fraction } else { 0.0 }
}

#let select-external-label-candidate(candidates, node-obstacles, edge-obstacles, label-obstacles: ()) = {
  let best-candidate = candidates.first()
  let best-score = float.inf
  // Strict comparison keeps ties in the declared direction order; a crowded
  // layout therefore still produces a stable least-overlap placement.
  for candidate in candidates {
    let score = 0.0
    for obstacle in node-obstacles {
      assert(type(obstacle) == array, message: repr(obstacle))
      score += _label-rectangle-overlap-area(
        candidate.center,
        candidate.half-width,
        candidate.half-height,
        obstacle,
      ) * 100
    }
    for obstacle in label-obstacles {
      assert(type(obstacle) == array, message: repr(obstacle))
      score += _label-rectangle-overlap-area(
        candidate.center,
        candidate.half-width,
        candidate.half-height,
        obstacle,
      ) * 100
    }
    for segment in edge-obstacles {
      score += _segment-label-rectangle-penalty(
        candidate.center,
        candidate.half-width,
        candidate.half-height,
        segment,
      ) * 10
    }
    if score < best-score {
      best-candidate = candidate
      best-score = score
    }
  }
  best-candidate
}
