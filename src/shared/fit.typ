// Width fitting for complete diagrams and composed operation panels.

#import "validate.typ": check-type, fail, show-value

#let fit-to-width(body, width: 100%) = {
  check-type("fit-to-width()", "body", body, (content, str), fix: "pass rendered content, such as structure.diagram")
  check-type("fit-to-width()", "width:", width, (length, ratio), fix: "pass a positive absolute length or percentage, such as 12cm or 100%")
  if type(width) == length {
    if width.em != 0 {
      fail("fit-to-width()", "width: is " + show-value(width), expected: "a positive absolute length or percentage", fix: "use an absolute unit such as cm or pt, or a percentage")
    }
  }
  let width-value = if type(width) == length { width.abs / 1pt } else { width / 1% }
  if not (width-value > 0 and width-value < float.inf) {
    fail("fit-to-width()", "width: is " + show-value(width), expected: "a finite positive absolute length or percentage", fix: "pass a width such as 12cm or 100%")
  }
  layout(container => {
    let requested-width = if type(width) == ratio { container.width * width } else { width }
    let available-width = calc.min(container.width, requested-width)
    let natural-width = measure(body).width
    if natural-width == 0pt or natural-width <= available-width {
      body
    } else {
      let fitting-scale = available-width / natural-width
      scale(x: fitting-scale * 100%, y: fitting-scale * 100%, reflow: true, body)
    }
  })
}
