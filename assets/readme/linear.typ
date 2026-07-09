// typst compile --root . --ppi 300 assets/readme/linear.typ assets/readme/linear.png
#import "../../src/lib.typ": *
#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "New Computer Modern", size: 11pt)

#std.stack(
  dir: ttb,
  spacing: 1.6em,
  std.stack(spacing: 0.5em, align(left)[*Linked list* — simple style],
    linked-list(3, 1, 4, 1, 5, head: true).diagram),
  std.stack(spacing: 0.5em, align(left)[*Linked list* — pointer style with addresses],
    linked-list(15, 3, 17, 90, pointer: true, head: true,
      addresses: ("3200", "3600", "4000", "4400")).diagram),
  std.stack(spacing: 0.5em, align(left)[*Doubly linked list* — two-way arrows],
    doubly-linked-list(3, 1, 4, 1, 5, head: true).diagram),
  std.stack(spacing: 0.5em, align(left)[*Doubly linked list* — pointer style],
    doubly-linked-list(15, 3, 17, 90, pointer: true, head: true,
      addresses: ("3200", "3600", "4000", "4400"),
      style: (prev-ptr-fill: rgb("#FDE2E4"), next-ptr-fill: rgb("#D7ECC9"))).diagram),
  std.stack(spacing: 0.5em, align(left)[*Stack* and *queue*],
    std.stack(dir: ltr, spacing: 2em, stack(9, 7, 2).diagram, queue(3, 8, 5, 1).diagram)),
  std.stack(spacing: 0.9em, align(left)[*Queue* with enqueue / dequeue],
    queue(3, 4, 5, 6, 7, 8, enqueue: 9, dequeue: 2,
      front-label: [Front / Head], rear-label: [Back / Tail / Rear]).diagram),
)
