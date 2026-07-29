# CLAUDE.md

This file provides guidance to agents when working with code in this repository.

## Commit and Attribution Rules

Never include any of the following in commit messages, PR descriptions, code
comments, or project files:
- `Co-Authored-By:` lines
- Generated-by or tool-attribution footers
- Any assistant/tooling attribution

## Code Comment Style

Comments should explain what a function or block does in general terms. Keep
them durable: describe the behavior, not the history of how it came to be.

Do not write comments that narrate a specific bug fix or a single triggering
input. Avoid phrases like "previously...", "no longer...", "this fixes...", and
example inputs cited only to justify a change. Such details belong in the
commit message, not the code. A reader should understand the comment without
knowing what the code used to do.

## Code Philosophy

Write code for humans first. The implementation should communicate its data
structure, algorithmic, layout, and rendering intent through names and
organization.

A reader familiar with data structures should be able to follow the code without
decoding generic helper names or relying on comments that repeat the
implementation.

### Module Ownership and Architectural Boundaries

Every implementation must consider which existing module owns the new code.
Place state, operations, validation, algorithms, layout, transitions, and
rendering with the domain and architectural layer that already owns the
concept.

If no existing module provides a coherent home, consider extracting or creating
a focused module. Refactor boundaries when a data-structure file accumulates
unrelated state, algorithm, semantic validation, layout, and rendering
responsibilities.

Do not fragment modules merely to make them smaller or force every data
structure into the same file pattern. A boundary should represent clear domain
ownership or an architectural dependency layer, and shared infrastructure
should be extracted only when multiple domains use the same stable abstraction.

### Readability over Cleverness

Prefer direct and explicit Typst code over dense expressions, excessive
dictionary manipulation, or abstractions that obscure the underlying algorithm.

Good:

```typst
let insertion-path = find-bst-insertion-path(root, key)
let tree-after-insertion = insert-key-at-path(root, key, insertion-path)
```

```typst
if should-highlight-search-path {
  render-path-highlight(search-path)
}
```

Avoid:

```typst
let p = find(root, k)
let t2 = ins(root, k, p)
```

```typst
if hl {
  draw(p)
}
```

The implementation should remain useful as teaching material as well as package
code.

### Self-Documenting Names

Use names that reveal the relevant data structure, algorithm, transition, or
drawing responsibility.

Prefer names such as:

```typst
find-bst-insertion-path(...)
insert-bst-node(...)
remove-bst-node(...)
rebalance-avl-subtree(...)
calculate-balance-factor(...)
rotate-subtree-left(...)
rotate-subtree-right(...)
restore-min-heap-order(...)
select-heap-swap-child(...)
build-linked-list-cells(...)
resolve-graph-node-position(...)
calculate-circular-graph-layout(...)
trace-breadth-first-search(...)
trace-depth-first-search(...)
calculate-shortest-paths(...)
resolve-edge-customization(...)
render-transition-step(...)
```

Avoid vague names such as:

```text
process(...)
handle(...)
helper(...)
walk(...)
do-op(...)
make(...)
fix(...)
calc(...)
data
item
thing
temp
result2
```

A generic verb is acceptable only when the object makes the responsibility
precise, such as `render-tree-edge` or `resolve-node-style`.

### Name Booleans as Questions

Boolean names should read naturally as yes-or-no questions.

Good:

```typst
is-leaf
is-balanced
has-left-child
has-right-child
should-rotate-left
should-highlight-node
uses-linear-probing
graph-is-directed
edge-has-label
operation-changes-root
```

Avoid:

```text
flag
check
enabled2
valid
mode
do-rotate
highlight
dir
```

Public argument names that are already established, such as `directed`, may
remain unchanged. Internal derived values should use question-like names where
that improves clarity.

### Use Algorithmic Vocabulary Consistently

Use established data-structure and algorithm terminology.

Do not invent synonyms for an existing concept merely to avoid repetition.

### Distinguish Identity, Value, Label, and Position

Names must make clear whether a value represents:

- the identity of a node;
- the displayed label;
- the stored value;
- its array index;
- its diagram position.

Prefer:

```text
node-id
node-label
node-value
heap-index
node-position
adjacency-key
display-label
```

Avoid using `key`, `value`, or `node` interchangeably when the distinction
matters.

### Distinguish Model, Layout, Style, and Rendering

Keep the main layers conceptually separate:

Avoid functions that silently modify model data while also calculating geometry
and drawing CeTZ content.

### One Responsibility per Function

Each function should perform one logical task.

Prefer separating:

```text
build a structure
perform an operation
record transition states
calculate positions
resolve style
draw the diagram
```

For example, an AVL insertion flow may contain distinct helpers for:

```text
finding the insertion path
inserting the node
updating subtree heights
detecting imbalance
selecting a rotation
applying the rotation
building rebalance panels
rendering the result
```

Do not combine these into one large function solely because they belong to one
public operation.

### Extract Algorithmic Decisions

Replace complicated inline conditions with named predicates or helpers.

Instead of:

```typst
if left-height - right-height > 1
  and key < left-child.at("value")
  and node.at("left") != none
{
  ...
}
```

prefer:

```typst
if requires-left-left-rotation(node, inserted-key) {
  rotate-subtree-right(node)
}
```

Instead of commenting a graph condition, extract:

```typst
if should-relax-edge(current-distance, edge-weight, neighbor-distance) {
  ...
}
```

The helper name should communicate the algorithmic rule without hiding important
behavior.

### Prefer Explicit Intermediate Values

Use named intermediate values when they make an algorithm or layout step easier
to follow.

Good:

```typst
let parent-index = calc.floor((heap-index - 1) / 2)
let parent-value = heap-values.at(parent-index)
let violates-min-heap-order = node-value < parent-value
```

Avoid compressing several conceptual steps into a single expression merely to
reduce line count.

### Prefer Early Exits

Handle empty structures, missing nodes, invalid operation inputs, and terminal
algorithm states before the main path.

Good:

```typst
if root == none {
  return empty-tree-result
}
```

```typst
if frontier.len() == 0 {
  return traversal-result
}
```

Keep the successful or common operation path minimally nested.

### Keep Abstractions Domain-Specific

Introduce abstractions that represent stable concepts such as:

```text
tree node
operation step
traversal trace
edge customization
resolved style
graph layout
hash bucket
probe sequence
```

Avoid generic utility frameworks or configuration machinery introduced for only
one caller.

Prefer existing shared helpers in `src/style.typ` and the relevant structure
module before creating a new convention.

### Comments Explain Why

Comments are a last resort.

First improve names, split the function, introduce an intermediate value, or
extract an algorithmic predicate.

Good:

```typst
// Diff marks use values rather than positions so operation steps remain stable
// across layout changes.
```

```typst
// Graph identity comes from adjacency keys; labels affect display only.
```

```typst
// Nested style dictionaries merge over defaults so callers can override one
// typography field without replacing the entire text style.
```

Bad:

```typst
// Loop through all nodes.
```

```typst
// Calculate the left child index.
```

```typst
// Draw an arrow.
```

Comments must describe durable algorithmic reasoning, model invariants, layout
constraints, public contracts, or deliberate tradeoffs. They must not narrate a
bug fix, previous behavior, triggering example, or development history.

### Preserve Educational Clarity

This package renders concepts used in CS teaching material. Internal code should
not become so abstract that the underlying algorithm can no longer be
recognized.

Prefer a readable implementation that follows the conceptual steps of BST
insertion, AVL rotation, heap restoration, BFS, DFS, or Dijkstra over a generic
framework that unifies them at the cost of clarity.

### Refactor Instead of Explaining

When a block needs a comment describing its steps, first attempt to represent
those steps with:

1. algorithm-specific helper names;
2. explicit intermediate values;
3. separate model, layout, and rendering functions;
4. guard clauses;
5. precise object and field names.

Prefer readable code with a few valuable comments over dense code explained by
many comments.

### Optimize Only with Evidence

Do not obscure an algorithm or layout routine for hypothetical performance
benefits.

When optimization is justified, keep the conceptual algorithm recognizable and
document why the less-direct implementation is necessary.


## Current Status

`typed-dsa` is a Typst package that renders declarative data-structure diagrams
for CS teaching material: trees, heaps, linked lists, stacks, queues, graphs,
and before/after operation transitions.

Architecture:

```text
Typst builder call -> data-structure model -> layout helpers -> CeTZ drawing
```

There is no Rust/WASM plugin in this package. The implementation is pure Typst,
with CeTZ used for drawing.

The current package name is `typed-dsa`. Use `main` as the source of truth for
development. The `typst/packages` checkout is only a staging area for package
submission.

## Commands

```sh
# Compile the visual smoke test
typst compile --root . tests/test.typ tests/test.pdf

# Run the invariant and valid-input checks
typst compile --root . tests/check.typ -f pdf tests/check.pdf

# Run the negative diagnostic suite (every case must fail with a useful error)
scripts/negative-tests.sh
scripts/negative-tests.sh 42   # run a single case by index

# Compile the user guide
typst compile --root . docs/documentation.typ docs/documentation.pdf

# Compile a PNG version of the visual smoke test when useful for inspection
typst compile --root . --ppi 140 tests/test.typ tests/test.png

# Regenerate README assets
typst compile --root . --ppi 300 assets/readme/trees.typ assets/readme/trees.png
typst compile --root . --ppi 300 assets/readme/heaps.typ assets/readme/heaps.png
typst compile --root . --ppi 300 assets/readme/linear.typ assets/readme/linear.png
typst compile --root . --ppi 300 assets/readme/graphs.typ assets/readme/graphs.png
typst compile --root . --ppi 300 assets/readme/transitions.typ assets/readme/transitions.png
typst compile --root . --ppi 300 assets/readme/styling.typ assets/readme/styling.png

# Prepare a Typst packages preview copy for a version
VERSION=0.1.0
scripts/package-preview.sh "$VERSION" /Users/gerocastano8/Documents/Coding/Projects/typst-packages
```

## Invalid-Input Rule

Every new public function, data structure, algorithm, operation, customization,
style key, or argument must define and test its invalid-input behavior. Invalid
values, unsupported combinations, malformed structures, impossible operations,
and invalid references must produce actionable editor-visible diagnostics.
Silently ignoring, clamping, dropping, or defaulting invalid user input is not
acceptable.

In practice:

- Validate at the public boundary, in three phases: argument schema (types,
  enums, numeric ranges, dictionary keys), then structure, then references into
  the resolved structure. Model, layout, and rendering code may assume a valid
  model and must not re-check or silently repair one.
- Reuse the shared helpers in `src/validate.typ` (`check-type`, `check-enum`,
  `check-index`, `check-known-keys`, `check-reference`, `check-comparable`,
  `check-customization-entries`, `fail`, ...) and the schema lists and
  customization checkers in `src/style.typ`. Do not write a second,
  slightly-different validator for a concept that already has one.
- Every diagnostic must name four things: the public function and argument, the
  offending value, the accepted range or the available identifiers, and how to
  correct the call. `fail(where, problem, expected:, fix:)` enforces that shape.
- Keep the distinction between an invalid operation and a valid "not found".
  Searching for an absent key is a legitimate result, reported through the
  step's `found:` field. An out-of-range index, a malformed operation, an
  impossible mutation, or a customization of a target that does not exist is an
  error.
- Add cases to `tests/negative.typ` for each new way a call can be wrong, and
  add the matching valid usage to `tests/check.typ`. Both suites must pass
  before a change is finished.

## Visual Test Rule

Every new feature, rendering change, or bug fix must add a small visual section
to `tests/test.typ`, then regenerate `tests/test.pdf`. The PDF may grow over
time; keep each added section focused and labeled so regressions are easy to
inspect.

Always append new test sections at the end of `tests/test.typ`, never in the
middle, so the newest additions land on the last pages of the PDF and are easy
to view.

When a change affects README examples or rendered output shown in the README,
regenerate the matching `assets/readme/*.png` file from its `.typ` source.

## Documentation Rule

Every change to the public API or user-visible behavior must be reflected in
`docs/documentation.typ` and recompiled to `docs/documentation.pdf`.

- New or changed argument: update the relevant local argument reference,
  including nested dictionary keys such as `style.*`,
  `style.node-text.*`, `style.label-text.*`, and
  `edge-customizations[].options.*`.
- New feature: add or revise a live example in the documentation. Add it to
  `README.md` only when the feature belongs in the short project overview.
- Behavior clarification or bug fix: add a note in the relevant documentation
  section. Only add it to `README.md` if a user relying on the README alone
  would be surprised or misled without it.
- Keep the Quick Reference tables at the end of the documentation in sync with
  any signature changes.

## Project Structure

```text
typst.toml              Package manifest
src/lib.typ             Public API exports and transition dispatcher
src/tree.typ            Tree domain facade
src/tree-state.typ      Tree state, rotations, mutations, manual node models
src/tree-validation.typ Tree-specific structure and reference validation
src/tree-layout.typ     Tree layout calculations
src/tree-render.typ     Tree CeTZ rendering
src/tree-api.typ        Tree constructors, operations, objects, transitions
src/heap.typ            Array-backed min/max heaps and heap transitions
src/linear.typ          Linear-structure domain facade
src/linear-common.typ   Shared linear cells, validation, operation records
src/linear-lists.typ    Singly and doubly linked lists
src/linear-containers.typ Stack and queue structures
src/linear-skip-list.typ Skip-list state, algorithms, layout, rendering
src/graph.typ           Graph domain facade
src/graph-model.typ     Graph adjacency state and identity
src/graph-validation.typ Graph-specific argument and reference validation
src/graph-layout.typ    Graph node placement and edge geometry
src/graph-render.typ    Graph CeTZ rendering
src/graph-api.typ       Public graph constructor
src/graph-algorithms.typ BFS, DFS, and Dijkstra teaching traces
src/hash.typ            Chained and linear-probing hash tables and operations
src/grid.typ            Array, matrix, and step-sequence rendering
src/sorting.typ         Sorting domain facade
src/sorting-validation.typ Sorting-specific input and role validation
src/sorting-common.typ  Shared sorting trace records and presentation
src/sorting-merge.typ   Merge operations and merge-sort traces
src/sorting-quick.typ   Partition operations and quick-sort traces
src/sorting-elementary.typ Bubble, insertion, and selection traces
src/transition-view.typ Shared before/after transition presentation
src/style.typ           Shared theme defaults, style resolution, and schemas
src/validate.typ        Shared argument validation and diagnostic helpers
src/messages.typ        Localized caption catalogs and message overrides
docs/documentation.typ  User guide source
docs/documentation.pdf  Rendered user guide
assets/readme/          Typst source and rendered PNG README examples
tests/test.typ          Visual smoke test
tests/check.typ         Invariant and valid-input checks
tests/negative.typ      Negative diagnostic cases (must fail to compile)
scripts/                Release helper scripts
PACKAGING.md            Typst package release checklist
```

## Typst API

Structure builders:

```typst
#bst(..keys, style: (:), edge-customizations: ())
#avl(..keys, style: (:), edge-customizations: ())
#min-heap(..keys, style: (:))
#max-heap(..keys, style: (:))
#linked-list(..vals, style: (:), pointer: false, addresses: none, head: false)
#doubly-linked-list(..vals, style: (:), pointer: false, addresses: none, head: false)
#stack(..vals, style: (:))
#queue(..vals, style: (:), enqueue: none, dequeue: none, front-label: [Front], rear-label: [Rear])
#graph(adjacency, directed: true, labels: (:), positions: (:), layout: "auto", radius: auto, edge-customizations: (), style: (:))
#hash-table(..entries, size: 7, collision: "chaining", hash: auto, style: (:))
```

Hand-composed trees:

```typst
#tree(root, style: (:), edge-customizations: ())
#node(label, left: none, right: none, fill: none)
#subtree(label, fill: none, height: none, scale: 1)
```

Transitions and operations:

```typst
#transition(variant, keys, op, style: (:), edge-customizations: ())
#tree-insert(key, rebalance: (:))
#tree-delete(key)
#tree-search(key)
#heap-insert(key)
#heap-extract
#op-arrow(label, symbol: $arrow.r$)
#operation-sequence(initial, ..operations, columns: 1, mode: "after")
#bfs(adjacency, source, target: none, directed: true, style: (:))
#dfs(adjacency, source, target: none, directed: true, style: (:))
#dijkstra(adjacency, source, target: none, directed: true, style: (:))
```

Styling helpers:

```typst
#theme
#resolve(style)
```

Builder objects expose `.diagram` and operation fields where applicable.
Operation calls return a step with `.before`, `.after`, `.diagram`, `.label`,
and `.result`.

## Implemented Features

- Binary search trees and AVL trees built from insertion order
- BST/AVL insert, delete, and search transitions
- AVL rebalance panels via `tree-insert(..., rebalance: (enabled:, all-steps:))`
- Min-heaps and max-heaps rendered as complete binary trees
- Heap insert and extract transitions
- Unified object workflow with `.diagram`, operation fields, and chained
  `.result`
- Manual trees via `tree(node(...))` and elided `subtree(...)` triangles
- Linked lists and doubly linked lists, including pointer-cell mode, addresses,
  and head arrows
- Stacks and queues, including single-frame enqueue/dequeue arrows
- Directed and undirected graphs from adjacency dictionaries
- Graph edge labels via `(neighbor, label)` entries
- Graph node label overrides, automatic circular layout, manual layout, and
  relative positions
- Per-edge customization for trees and graphs:
  `stroke`, `color`, `pattern`, `arrow`, `bend`, `angle`, and graph label
  overrides
- Shared `style:` dictionaries for node/cell shape, fill, stroke, text, labels,
  scale, edge arrows, edge patterns, and diff highlights
- Linked-list prepend, indexed insert/delete, and search operations
- Hash tables with separate chaining or linear probing
- BFS, DFS, and Dijkstra traces rendered as graph state highlights
- Named theme presets, rounded/capsule nodes and cells, and typography roles
- Declarative operation chaining through `operation-sequence`
- Diff highlight styling through `new-style`, `path-style`, `remove-style`,
  `rotate-style`, and `diff-colors`

## Key Design Decisions

**Pure Typst implementation:** Keep the package lightweight and reviewable.
Data structures, layout, and rendering all live in Typst source files.

**CeTZ drawing backend:** Public builders return Typst content backed by CeTZ
canvas drawing. Prefer existing helpers in `src/style.typ`, `src/tree.typ`, and
the relevant structure module over introducing new drawing conventions.

**Unified object model:** Structure builders return an object that contains the
rendered `.diagram` and operation fields. Operation fields return a step object
with `.before`, `.after`, `.diagram`, `.label`, and `.result`.

**Style resolution:** Every public builder accepts `style:` and passes it
through `resolve(style)`. Nested dictionaries such as `node-text` and
`label-text` merge over defaults instead of replacing them wholesale.

**Operation marks:** Diff marks are keyed by values, not positions. This keeps
the implementation simple, but duplicate values can highlight more than the
single item that moved. Document this limitation when it matters.

**Graph identity vs display labels:** Graph identity comes from adjacency keys.
The `labels:` dictionary only changes what is drawn inside nodes.
`positions:` and `edge-customizations:` still use the identity keys.

## Dependencies

Typst imports:
- `@preview/cetz:0.5.2`

Documentation imports:
- `@preview/codly:1.3.0`
- `@preview/codly-languages:0.1.1`

Do not add a top-level `[dependencies]` table to `typst.toml`; the Typst
package checker rejects unknown manifest sections.

## Packaging Notes

Before preparing a Typst package release, copying files into the Typst packages
checkout, or opening a Typst packages PR, read `PACKAGING.md` and follow it as
the source of truth. It contains the local `typst-packages` checkout path,
branch naming, package-check command, and package bundle contents.

Runtime package files include:

```text
typst.toml
README.md
LICENSE
src/*.typ
assets/readme/*.png
```

Do not include development-only files in the Typst package PR:

```text
tests/*
docs/*
assets/readme/*.typ
scripts/*
CLAUDE.md
AGENTS.md
PACKAGING.md
.DS_Store
```
