// A worked example pairing typed-dsa's heap transitions with the reference
// solution, rendered side by side with codly.
//
// typst compile --root . assets/readme/last-stone-weight.typ assets/readme/last-stone-weight.pdf
// typst compile --root . --ppi 160 assets/readme/last-stone-weight.typ assets/readme/last-stone-weight.png

#import "../../src/lib.typ": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

// codly measures the page width to lay out its frame, so this needs a fixed
// width — `width: auto` leaves the code block collapsed to zero width.
#set page(width: 18cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 10.5pt)
#show: codly-init
#codly(languages: codly-languages, zebra-fill: none)

#align(center)[
  #text(size: 16pt, weight: "bold")[Last Stone Weight]
  #v(0.15em)
  #text(size: 10pt, fill: rgb("#666666"))[LeetCode 1046 · Easy]
]

#v(0.6em)

Smash the two heaviest stones together, repeatedly, until at most one is left.
If they're equal both are destroyed; otherwise the difference goes back in.
A max-heap hands you the two heaviest in $O(log n)$ each round instead of a
full rescan.

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

#v(0.6em)

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

#std.stack(spacing: 1.4em, r1.frame, r2.frame, r3.frame, r4.frame)

#v(0.4em)
One stone remains, weight *1* — matching `lastStoneWeight([2, 7, 4, 1, 8, 1]) == 1`.
