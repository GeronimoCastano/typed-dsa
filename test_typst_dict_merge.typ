#let a = (node-text: (size: 9pt, fill: black))
#let b = (node-text: (size: 11pt))
#let c = a + b
#assert(c.node-text == (size: 11pt))
