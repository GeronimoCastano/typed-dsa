// Negative tests: every case here must FAIL to compile, with a diagnostic that
// names the problem in words the caller can act on.
//
// Run them with `scripts/negative-tests.sh`, which compiles this file once per
// case with `--input case=<index>` and checks two things: that compilation
// failed, and that the error text contains the case's `expect` fragment.
// Compiling this file with no `case` input instead emits the case list as
// metadata, which is how the runner discovers the cases.
//
// Add a case whenever a public function, argument, operation, customization,
// or style key gains a new way to be used wrongly.

#let cases = (
  (
    name: "bst: keys of mixed types that cannot be ordered against each other",
    expect: "mixes number and string keys",
    code: "#bst(1, \"two\").diagram",
  ),
  (
    name: "bst: a key that cannot be ordered at all",
    expect: "cannot be ordered",
    code: "#bst(1, [two]).diagram",
  ),
  (
    name: "bst: duplicate keys",
    expect: "more than once",
    code: "#bst(5, 3, 5).diagram",
  ),
  (
    name: "bst: node-customizations naming a node that does not exist",
    expect: "does not exist in the structure",
    code: "#bst(5, 3, node-customizations: ((9, (fill: red)),)).diagram",
  ),
  (
    name: "bst: edge-customizations naming an edge that does not exist",
    expect: "not a parent/child pair",
    code: "#bst(5, 3, edge-customizations: ((3, 5, (color: red)),)).diagram",
  ),
  (
    name: "bst: edge-customizations with an unknown option key",
    expect: "unknown key \"colour\"",
    code: "#bst(5, 3, edge-customizations: ((5, 3, (colour: red)),)).diagram",
  ),
  (
    name: "bst: edge-customizations with an unsupported bend",
    expect: "not a supported value",
    code: "#bst(5, 3, edge-customizations: ((5, 3, (bend: \"up\")),)).diagram",
  ),
  (
    name: "bst: node-labels keyed by a node that does not exist",
    expect: "does not exist in the structure",
    code: "#bst(5, 3, node-labels: (\"9\": [x])).diagram",
  ),
  (
    name: "bst: node-labels with an unsupported position",
    expect: "not a supported value",
    code: "#bst(5, 3, node-labels: ((5, (content: [x], position: \"middle\")),)).diagram",
  ),
  (
    name: "bst: node-customizations with an unsupported shape",
    expect: "not a supported value",
    code: "#bst(5, 3, node-customizations: ((5, (shape: \"blob\")),)).diagram",
  ),
  (
    name: "tree: root that is not a node",
    expect: "node(...) value",
    code: "#tree(\"root\")",
  ),
  (
    name: "node: a child that is not a node",
    expect: "node(...) value",
    code: "#tree(node(\"a\", left: 5))",
  ),
  (
    name: "node: children together with left/right",
    expect: "children: was given together with",
    code: "#tree(node(\"a\", children: (node(\"b\"),), left: node(\"c\")))",
  ),
  (
    name: "subtree: a scale that is not positive",
    expect: "out of range",
    code: "#tree(subtree(\"T\", scale: 0))",
  ),
  (
    name: "tree edge label: typography with no content",
    expect: "no label content",
    code: "#tree(node(\"a\", left: node(\"b\")), edge-customizations: ((\"a\", \"b\", (label: (color: red))),))",
  ),
  (
    name: "tree-delete: a key the tree does not hold",
    expect: "nothing to delete",
    code: "#transition(\"bst\", (5, 3), tree-delete(9))",
  ),
  (
    name: "tree-insert: a key the tree already holds",
    expect: "already in the tree",
    code: "#transition(\"bst\", (5, 3), tree-insert(3))",
  ),
  (
    name: "tree-insert: an unknown rebalance option",
    expect: "unknown key \"enable\"",
    code: "#transition(\"avl\", (5, 3), tree-insert(1, rebalance: (enable: true)))",
  ),
  (
    name: "tree-insert: a rebalance option that is not a boolean",
    expect: "must be boolean",
    code: "#transition(\"avl\", (5, 3), tree-insert(1, rebalance: (enabled: \"yes\")))",
  ),
  (
    name: "transition: an unknown variant",
    expect: "not a supported value",
    code: "#transition(\"splay\", (5, 3), tree-insert(1))",
  ),
  (
    name: "transition: a heap operation on a tree variant",
    expect: "was given a heap operation",
    code: "#transition(\"bst\", (5, 3), heap-insert(1))",
  ),
  (
    name: "transition: a tree operation on a heap variant",
    expect: "was given a tree operation",
    code: "#transition(\"min-heap\", (5, 3), tree-insert(1))",
  ),
  (
    name: "transition: an op that is not an operation",
    expect: "which is not an operation",
    code: "#transition(\"bst\", (5, 3), 42)",
  ),
  (
    name: "transition: keys that are not an array",
    expect: "must be array",
    code: "#transition(\"bst\", 5, tree-insert(1))",
  ),
  (
    name: "bst object: inserting a key that is already present",
    expect: "already in the tree",
    code: "#let t = bst(5, 3)\n#(t.insert)(5).diagram",
  ),
  (
    name: "bst object: deleting a key that is absent",
    expect: "nothing to delete",
    code: "#let t = bst(5, 3)\n#(t.delete)(9).diagram",
  ),
  (
    name: "bst object: searching with an incomparable key",
    expect: "cannot be compared",
    code: "#let t = bst(5, 3)\n#(t.search)(\"x\").diagram",
  ),
  (
    name: "min-heap: keys of mixed types that cannot be ordered against each other",
    expect: "mixes number and string keys",
    code: "#min-heap(3, \"x\").diagram",
  ),
  (
    name: "max-heap: a key that cannot be ordered at all",
    expect: "cannot be ordered",
    code: "#max-heap(3, [x]).diagram",
  ),
  (
    name: "heap-extract: an empty heap",
    expect: "no root to extract",
    code: "#transition(\"min-heap\", (), heap-extract)",
  ),
  (
    name: "heap object: extracting from an empty heap",
    expect: "no root to extract",
    code: "#let h = max-heap()\n#(h.extract)().diagram",
  ),
  (
    name: "heap-insert: a key that cannot be compared with the heap",
    expect: "cannot be compared",
    code: "#let h = min-heap(1, 2)\n#(h.insert)(\"x\").diagram",
  ),
  (
    name: "linked-list: addresses that do not match the values",
    expect: "one address per value",
    code: "#linked-list(1, 2, 3, addresses: (\"a\", \"b\")).diagram",
  ),
  (
    name: "linked-list: a pointer flag that is not a boolean",
    expect: "must be boolean",
    code: "#linked-list(1, 2, pointer: \"yes\").diagram",
  ),
  (
    name: "linked-list: inserting past the end of the list",
    expect: "out of bounds",
    code: "#let l = linked-list(1, 2)\n#(l.insert)(9, index: 5).diagram",
  ),
  (
    name: "linked-list: delete-at on an index that does not exist",
    expect: "out of bounds",
    code: "#let l = linked-list(1, 2)\n#(l.delete-at)(7).diagram",
  ),
  (
    name: "linked-list: delete-at on an empty list",
    expect: "list is empty",
    code: "#let l = linked-list()\n#(l.delete-at)(0).diagram",
  ),
  (
    name: "linked-list: deleting a value that is not in the list",
    expect: "nothing to delete",
    code: "#let l = linked-list(1, 2)\n#(l.delete)(9).diagram",
  ),
  (
    name: "doubly-linked-list: deleting a value that is not in the list",
    expect: "nothing to delete",
    code: "#let l = doubly-linked-list(1, 2)\n#(l.delete)(9).diagram",
  ),
  (
    name: "stack: popping an empty stack",
    expect: "stack is empty",
    code: "#let s = stack()\n#(s.pop)().diagram",
  ),
  (
    name: "queue: dequeueing an empty queue",
    expect: "queue is empty",
    code: "#let q = queue()\n#(q.dequeue)().diagram",
  ),
  (
    name: "skip-list: values that are not ascending",
    expect: "not ascending",
    code: "#skip-list(3, 1, 2).diagram",
  ),
  (
    name: "skip-list: duplicate values",
    expect: "more than once",
    code: "#skip-list(1, 2, 2).diagram",
  ),
  (
    name: "skip-list: values of mixed types",
    expect: "mixes number and string",
    code: "#skip-list(1, \"b\").diagram",
  ),
  (
    name: "skip-list: a decision-fn that is not a function",
    expect: "must be function",
    code: "#skip-list(1, 2, decision-fn: true).diagram",
  ),
  (
    name: "skip-list: a decision-fn that does not return a boolean",
    expect: "decision-fn: returned",
    code: "#skip-list(1, 2, decision-fn: (level, value) => 1).diagram",
  ),
  (
    name: "skip-list: a negative max-level",
    expect: "out of range",
    code: "#skip-list(1, 2, max-level: -1).diagram",
  ),
  (
    name: "skip-list: a level-spacing that is not positive",
    expect: "out of range",
    code: "#skip-list(1, 2, level-spacing: 0).diagram",
  ),
  (
    name: "skip-list: inserting above max-level",
    expect: "out of range",
    code: "#let s = skip-list(1, 2, max-level: 3)\n#(s.insert)(5, level: 9).diagram",
  ),
  (
    name: "skip-list: inserting a value that is already present",
    expect: "already in the skip list",
    code: "#let s = skip-list(1, 2)\n#(s.insert)(2).diagram",
  ),
  (
    name: "skip-list: deleting a value that is absent",
    expect: "nothing to delete",
    code: "#let s = skip-list(1, 2)\n#(s.delete)(9).diagram",
  ),
  (
    name: "graph: an adjacency that is not a dictionary",
    expect: "must be dictionary",
    code: "#graph((\"a\", \"b\")).diagram",
  ),
  (
    name: "graph: an adjacency entry that is not an array",
    expect: "must be array",
    code: "#graph((\"a\": \"b\")).diagram",
  ),
  (
    name: "graph: a malformed neighbour entry",
    expect: "neighbour name",
    code: "#graph((\"a\": (7,))).diagram",
  ),
  (
    name: "graph: labels naming a node that does not exist",
    expect: "does not exist in the structure",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), labels: (\"c\": [C])).diagram",
  ),
  (
    name: "graph: node-customizations naming a node that does not exist",
    expect: "does not exist in the structure",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), node-customizations: ((\"c\", (fill: red)),)).diagram",
  ),
  (
    name: "graph: edge-customizations naming an edge that does not exist",
    expect: "does not exist in the graph",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), edge-customizations: ((\"b\", \"a\", (color: red)),)).diagram",
  ),
  (
    name: "graph: positions naming a node that does not exist",
    expect: "does not exist in the structure",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), positions: (\"c\": (0, 0))).diagram",
  ),
  (
    name: "graph: a position that is not an (x, y) pair",
    expect: "(x, y) pair",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), positions: (\"a\": 3)).diagram",
  ),
  (
    name: "graph: a relative position naming a missing node",
    expect: "does not exist in the structure",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), positions: (\"a\": (rel: \"z\", offset: (1, 0)))).diagram",
  ),
  (
    name: "graph: relative positions that form a cycle",
    expect: "form a cycle",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), positions: (\"a\": (rel: \"b\"), \"b\": (rel: \"a\"))).diagram",
  ),
  (
    name: "graph: manual layout missing a position",
    expect: "no position for node",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), layout: \"manual\", positions: (\"a\": (0, 0))).diagram",
  ),
  (
    name: "graph: an unknown layout",
    expect: "not a supported value",
    code: "#graph((\"a\": ()), layout: \"grid\").diagram",
  ),
  (
    name: "graph: radius with a layout that does not use it",
    expect: "radius: was given with layout",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), layout: \"linear\", radius: 2).diagram",
  ),
  (
    name: "graph: gap with a layout that does not use it",
    expect: "gap: was given with layout",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), gap: 2).diagram",
  ),
  (
    name: "graph: layout options with a layout that does not use them",
    expect: "layout-options: was given with layout",
    code: "#graph((\"a\": ()), layout-options: (node-gap: 2)).diagram",
  ),
  (
    name: "graph: layout options that are not a dictionary",
    expect: "layout-options: must be dictionary",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (1, 2)).diagram",
  ),
  (
    name: "graph: layered layout on an undirected graph",
    expect: "was given directed: false",
    code: "#graph((\"a\": (\"b\",), \"b\": ()), directed: false, layout: \"layered\").diagram",
  ),
  (
    name: "graph: layered layout on a directed cycle",
    expect: "found a directed cycle",
    code: "#graph((\"a\": (\"b\",), \"b\": (\"a\",)), layout: \"layered\").diagram",
  ),
  (
    name: "graph: unknown force layout option",
    expect: "unknown key \"edge-lenght\"",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (edge-lenght: 2)).diagram",
  ),
  (
    name: "graph: layered option with force layout",
    expect: "unknown key \"node-gap\"",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (node-gap: 2)).diagram",
  ),
  (
    name: "graph: force option with layered layout",
    expect: "unknown key \"repulsion\"",
    code: "#graph((\"a\": ()), layout: \"layered\", layout-options: (repulsion: 2)).diagram",
  ),
  (
    name: "graph: invalid layered direction",
    expect: "not a supported value",
    code: "#graph((\"a\": ()), layout: \"layered\", layout-options: (direction: \"sideways\")).diagram",
  ),
  (
    name: "graph: non-positive force edge length",
    expect: "layout-options.edge-length is 0",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (edge-length: 0)).diagram",
  ),
  (
    name: "graph: non-positive force repulsion",
    expect: "layout-options.repulsion is 0",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (repulsion: 0)).diagram",
  ),
  (
    name: "graph: non-positive force attraction",
    expect: "layout-options.attraction is 0",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (attraction: 0)).diagram",
  ),
  (
    name: "graph: non-positive force node-edge repulsion",
    expect: "layout-options.node-edge-repulsion is 0",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (node-edge-repulsion: 0)).diagram",
  ),
  (
    name: "graph: negative force node-edge clearance",
    expect: "layout-options.node-edge-clearance is -0.1",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (node-edge-clearance: -0.1)).diagram",
  ),
  (
    name: "graph: force node-edge clearance that is not numeric",
    expect: "layout-options.node-edge-clearance is \"wide\"",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (node-edge-clearance: \"wide\")).diagram",
  ),
  (
    name: "graph: non-positive force component gap",
    expect: "layout-options.component-gap is 0",
    code: "#graph((\"a\": (), \"b\": ()), layout: \"force\", layout-options: (component-gap: 0)).diagram",
  ),
  (
    name: "graph: non-positive layered layer gap",
    expect: "layout-options.layer-gap is 0",
    code: "#graph((\"a\": ()), layout: \"layered\", layout-options: (layer-gap: 0)).diagram",
  ),
  (
    name: "graph: non-positive layered node gap",
    expect: "layout-options.node-gap is 0",
    code: "#graph((\"a\": ()), layout: \"layered\", layout-options: (node-gap: 0)).diagram",
  ),
  (
    name: "graph: force iterations below one",
    expect: "layout-options.iterations is 0",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (iterations: 0)).diagram",
  ),
  (
    name: "graph: force iterations that are not an integer",
    expect: "layout-options.iterations must be integer",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (iterations: 2.5)).diagram",
  ),
  (
    name: "graph: force iterations above the limit",
    expect: "layout-options.iterations is 501",
    code: "#graph((\"a\": ()), layout: \"force\", layout-options: (iterations: 501)).diagram",
  ),
  (
    name: "graph: layered crossing sweeps below zero",
    expect: "layout-options.crossing-sweeps is -1",
    code: "#graph((\"a\": ()), layout: \"layered\", layout-options: (crossing-sweeps: -1)).diagram",
  ),
  (
    name: "graph: layered crossing sweeps that are not an integer",
    expect: "layout-options.crossing-sweeps must be integer",
    code: "#graph((\"a\": ()), layout: \"layered\", layout-options: (crossing-sweeps: 1.5)).diagram",
  ),
  (
    name: "graph: layered crossing sweeps above the limit",
    expect: "layout-options.crossing-sweeps is 21",
    code: "#graph((\"a\": ()), layout: \"layered\", layout-options: (crossing-sweeps: 21)).diagram",
  ),
  (
    name: "graph: a directed flag that is not a boolean",
    expect: "must be boolean",
    code: "#graph((\"a\": ()), directed: \"yes\").diagram",
  ),
  (
    name: "bfs: a source that is not in the graph",
    expect: "does not exist in the structure",
    code: "#bfs((\"a\": (\"b\",), \"b\": ()), \"z\").diagram",
  ),
  (
    name: "bfs: a target that is not in the graph",
    expect: "does not exist in the structure",
    code: "#bfs((\"a\": (\"b\",), \"b\": ()), \"a\", target: \"z\").diagram",
  ),
  (
    name: "bfs: an unknown goal-test",
    expect: "not a supported value",
    code: "#bfs((\"a\": (\"b\",), \"b\": ()), \"a\", goal-test: \"arrival\").diagram",
  ),
  (
    name: "dfs: a column count below one",
    expect: "out of range",
    code: "#dfs((\"a\": (\"b\",), \"b\": ()), \"a\", columns: 0).diagram",
  ),
  (
    name: "dijkstra: a negative edge weight",
    expect: "non-negative weight",
    code: "#dijkstra((\"a\": ((\"b\", -2),), \"b\": ()), \"a\").diagram",
  ),
  (
    name: "dijkstra: an edge weight that is not a number",
    expect: "which is not a number",
    code: "#dijkstra((\"a\": ((\"b\", [w]),), \"b\": ()), \"a\").diagram",
  ),
  (
    name: "array-view: a cell customization outside the array",
    expect: "out of bounds",
    code: "#array-view(1, 2, 3, cell-customizations: ((7, (fill: red)),)).diagram",
  ),
  (
    name: "array-view: a cell customization with an unknown option",
    expect: "unknown key \"colour\"",
    code: "#array-view(1, 2, cell-customizations: ((0, (colour: red)),)).diagram",
  ),
  (
    name: "array-view: a pointer outside the array",
    expect: "out of bounds",
    code: "#array-view(1, 2, pointers: ((index: 5, label: [i], color: red),)).diagram",
  ),
  (
    name: "array-view: a pointer with no label",
    expect: "no \"label\" entry",
    code: "#array-view(1, 2, pointers: ((index: 0, color: red),)).diagram",
  ),
  (
    name: "matrix: rows of different lengths",
    expect: "same number of cells",
    code: "#matrix(((1, 2), (3,))).diagram",
  ),
  (
    name: "matrix: no rows at all",
    expect: "rows is empty",
    code: "#matrix(()).diagram",
  ),
  (
    name: "matrix: a cell customization outside the matrix",
    expect: "out of bounds",
    code: "#matrix(((1, 2), (3, 4)), cell-customizations: (((0, 5), (fill: red)),)).diagram",
  ),
  (
    name: "matrix: more row labels than rows",
    expect: "at most one label per row",
    code: "#matrix(((1, 2),), row-labels: ([a], [b])).diagram",
  ),
  (
    name: "sequence: an unknown mode",
    expect: "not a supported value",
    code: "#sequence(mode: \"final\", [x])",
  ),
  (
    name: "operation-sequence: a closure that does not return a step",
    expect: "returned",
    code: "#operation-sequence(bst(5), object => 7)",
  ),
  (
    name: "quick-sort: an unknown order",
    expect: "not a supported value",
    code: "#quick-sort((3, 1, 2), order: \"up\")",
  ),
  (
    name: "quick-sort: a pivot index outside the array",
    expect: "out of bounds",
    code: "#quick-sort((3, 1, 2), pivot: 9)",
  ),
  (
    name: "quick-sort: an unknown pivot mode",
    expect: "not a supported value",
    code: "#quick-sort((3, 1, 2), pivot: \"median\")",
  ),
  (
    name: "quick-sort: an empty array",
    expect: "is empty",
    code: "#quick-sort(())",
  ),
  (
    name: "bubble-sort: values of mixed types that cannot be ordered against each other",
    expect: "mixes number and string values",
    code: "#bubble-sort((3, \"x\"))",
  ),
  (
    name: "selection-sort: a value that cannot be ordered at all",
    expect: "cannot be ordered",
    code: "#selection-sort((3, [x]))",
  ),
  (
    name: "bubble-sort: a role override with an unknown key",
    expect: "unknown key \"colour\"",
    code: "#bubble-sort((3, 1), compare: (colour: red))",
  ),
  (
    name: "insertion-sort: an input that is neither an array nor an array-view",
    expect: "array-view",
    code: "#insertion-sort(7)",
  ),
  (
    name: "merge-operation: a left array that is not sorted",
    expect: "is not sorted",
    code: "#merge-operation((3, 1), (2, 4))",
  ),
  (
    name: "partition-step: an unknown pivot mode",
    expect: "not a supported value",
    code: "#partition-step((3, 1, 2), pivot: \"first\")",
  ),
  (
    name: "sort-sequence: steps that are not an array",
    expect: "must be array",
    code: "#sort-sequence(7)",
  ),
  (
    name: "hash-table: a size below one",
    expect: "out of range",
    code: "#hash-table(\"a\", size: 0).diagram",
  ),
  (
    name: "hash-table: an unknown collision strategy",
    expect: "not a supported value",
    code: "#hash-table(\"a\", collision: \"quadratic\").diagram",
  ),
  (
    name: "hash-table: an entry that is neither a key nor a pair",
    expect: "(key, value) pair",
    code: "#hash-table((\"a\", 1, 2), size: 5).diagram",
  ),
  (
    name: "hash-table: a hash function that does not return an integer",
    expect: "hash: returned",
    code: "#hash-table(\"a\", hash: key => \"x\").diagram",
  ),
  (
    name: "hash-table: a hash result outside the table",
    expect: "not a slot in this table",
    code: "#hash-table(\"a\", size: 4, hash: key => 9).diagram",
  ),
  (
    name: "hash-table: a hash that is not a function",
    expect: "must be function",
    code: "#hash-table(\"a\", hash: 3).diagram",
  ),
  (
    name: "hash-table: filling a linear-probing table",
    expect: "every slot is occupied",
    code: "#let h = hash-table(1, 2, size: 2, collision: \"linear\")\n#(h.insert)(3).diagram",
  ),
  (
    name: "style: an unknown key",
    expect: "unknown key \"node-fil\"",
    code: "#bst(5, style: (node-fil: red)).diagram",
  ),
  (
    name: "style: a dimension that is not positive",
    expect: "out of range",
    code: "#bst(5, style: (node-radius: -1)).diagram",
  ),
  (
    name: "style: a scale of zero",
    expect: "out of range",
    code: "#bst(5, style: (scale: 0)).diagram",
  ),
  (
    name: "style: an unknown nested typography key",
    expect: "unknown key \"sixe\"",
    code: "#bst(5, style: (node-text: (sixe: 9pt))).diagram",
  ),
  (
    name: "style: a typography role that is not a dictionary",
    expect: "must be dictionary",
    code: "#bst(5, style: (node-text: 9pt)).diagram",
  ),
  (
    name: "style: an unknown node shape",
    expect: "not a supported value",
    code: "#bst(5, style: (node-shape: \"blob\")).diagram",
  ),
  (
    name: "style: an unknown box shape",
    expect: "not a supported value",
    code: "#linked-list(1, style: (box-shape: \"oval\")).diagram",
  ),
  (
    name: "style: a fill that is not a color",
    expect: "must be color",
    code: "#bst(5, style: (node-fill: \"red\")).diagram",
  ),
  (
    name: "style: a highlight role with an unknown key",
    expect: "unknown key \"colour\"",
    code: "#bst(5, style: (new-style: (colour: red))).diagram",
  ),
  (
    name: "style: an unknown edge pattern",
    expect: "not a supported value",
    code: "#bst(5, 3, style: (edge-pattern: \"squiggly\")).diagram",
  ),
  (
    name: "style: an indices dictionary with an unknown key",
    expect: "unknown key \"enable\"",
    code: "#array-view(1, 2, style: (indices: (enable: true))).diagram",
  ),
  (
    name: "style: a style argument that is not a dictionary",
    expect: "must be dictionary",
    code: "#bst(5, style: 3).diagram",
  ),
  (
    name: "theme-preset: an unknown theme",
    expect: "not a supported value",
    code: "#theme-preset(\"neon\")",
  ),
  (
    name: "language: an unsupported language",
    expect: "not a supported value",
    code: "#bst(5, language: \"fr\").diagram",
  ),
  (
    name: "messages: an unknown message key",
    expect: "unknown message key",
    code: "#bst(5, messages: (tree: (insrt: key => [x]))).diagram",
  ),
  (
    name: "messages: a positional argument",
    expect: "positional argument",
    code: "#messages((tree: (insert: key => [x])))",
  ),
  (
    name: "messages: a message value that is not content or a function",
    expect: "must be content or string or function",
    code: "#bst(5, messages: (tree: (insert: 3))).diagram",
  ),
)

// Every case is evaluated with the whole public API in scope, exactly as a
// user document would import it.
#let _preamble = "#import \"/src/lib.typ\": *\n"

#let requested-case = sys.inputs.at("case", default: none)

#set page(width: auto, height: auto, margin: 4pt)

#if requested-case == none [
  #metadata(cases.map(case => (name: case.name, expect: case.expect))) <negative-cases>
  #cases.len() negative cases.
] else {
  eval(_preamble + cases.at(int(requested-case)).code, mode: "markup")
}
