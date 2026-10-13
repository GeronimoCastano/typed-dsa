// Shared sampled edge geometry and waves along routed paths.

#import "@preview/cetz:0.5.2"

#let calculate-cubic-edge-segments(start, control-start, control-end, end, radius: 0.04) = {
  let segments = ()
  let previous-point = start
  for sample-index in range(1, 17) {
    let fraction = sample-index / 16
    let inverse-fraction = 1 - fraction
    let point = (0, 1).map(axis => (
      inverse-fraction * inverse-fraction * inverse-fraction * start.at(axis)
        + 3 * inverse-fraction * inverse-fraction * fraction * control-start.at(axis)
        + 3 * inverse-fraction * fraction * fraction * control-end.at(axis)
        + fraction * fraction * fraction * end.at(axis)
    ))
    segments.push((previous-point, point, radius))
    previous-point = point
  }
  segments
}

#let calculate-through-edge-segments(start, through, end, radius: 0.04) = {
  let (curve-start, curve-end, control-start, control-end) = (
    cetz.path-util.bezier.cubic-through-3points(
      start + (0,), through + (0,), end + (0,),
    )
  )
  calculate-cubic-edge-segments(
    curve-start.slice(0, 2), control-start.slice(0, 2),
    control-end.slice(0, 2), curve-end.slice(0, 2), radius: radius,
  )
}

#let _sample-edge-path(segments, distance) = {
  let remaining-distance = distance
  for (start, end, _) in segments {
    let delta = (end.at(0) - start.at(0), end.at(1) - start.at(1))
    let segment-length = calc.sqrt(delta.at(0) * delta.at(0) + delta.at(1) * delta.at(1))
    if segment-length == 0 { continue }
    if remaining-distance <= segment-length {
      let tangent = (delta.at(0) / segment-length, delta.at(1) / segment-length)
      return (
        position: (start.at(0) + tangent.at(0) * remaining-distance, start.at(1) + tangent.at(1) * remaining-distance),
        tangent: tangent,
      )
    }
    remaining-distance -= segment-length
  }
  let (start, end, _) = segments.last()
  let dx = end.at(0) - start.at(0)
  let dy = end.at(1) - start.at(1)
  let segment-length = calc.sqrt(dx * dx + dy * dy)
  (position: end, tangent: if segment-length == 0 { (1, 0) } else { (dx / segment-length, dy / segment-length) })
}

#let wavy-path-parts(segments, resolved-style, start-tip: false, end-tip: false) = {
  let path-length = 0.0
  for (start, end, _) in segments {
    let dx = end.at(0) - start.at(0)
    let dy = end.at(1) - start.at(1)
    path-length += calc.sqrt(dx * dx + dy * dy)
  }
  let start = segments.first().at(0)
  let end = segments.last().at(1)
  if path-length == 0 {
    return (points: (start, end), start-cap: start, end-cap: end)
  }
  let requested-start-cap = resolved-style.node-radius * if start-tip { 0.8 } else { 0.35 }
  let requested-end-cap = resolved-style.node-radius * if end-tip { 0.8 } else { 0.35 }
  let cap-scale = calc.min(1, path-length * 0.7 / (requested-start-cap + requested-end-cap))
  let start-cap-length = requested-start-cap * cap-scale
  let end-cap-length = requested-end-cap * cap-scale
  let usable-length = path-length - start-cap-length - end-cap-length
  let wave-count = calc.max(1, calc.round(usable-length / resolved-style.edge-wave-step))
  let sample-count = calc.max(8, calc.ceil(wave-count * 10))
  let start-cap = _sample-edge-path(segments, start-cap-length).position
  let end-cap = _sample-edge-path(segments, path-length - end-cap-length).position
  let points = if start-tip { (start-cap,) } else { (start, start-cap) }
  for sample-index in range(1, sample-count) {
    let fraction = sample-index / sample-count
    let sampled-path = _sample-edge-path(segments, start-cap-length + usable-length * fraction)
    let perpendicular-offset = calc.sin(360deg * wave-count * fraction) * resolved-style.edge-wave-amplitude
    points.push((
      sampled-path.position.at(0) - sampled-path.tangent.at(1) * perpendicular-offset,
      sampled-path.position.at(1) + sampled-path.tangent.at(0) * perpendicular-offset,
    ))
  }
  points.push(end-cap)
  if not end-tip { points.push(end) }
  (points: points, start-cap: start-cap, end-cap: end-cap)
}

