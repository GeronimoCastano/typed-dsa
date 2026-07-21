# Packaging And Release Checklist

Use `main` as the source of truth. The `typst/packages` fork is a release
artifact, not a development branch.

Agents must read this file before preparing a Typst package release, copying
files into the Typst packages checkout, or opening a Typst packages PR.

## Repositories

Source package repository:

```text
/Users/gerocastano8/Documents/Coding/Projects/typed-dsa
https://github.com/GeronimoCastano/typed-dsa
```

Local Typst packages checkout:

```text
/Users/gerocastano8/Documents/Coding/Projects/typst-packages
```

Typst packages fork and upstream:

```text
origin   https://github.com/GeronimoCastano/packages.git
upstream https://github.com/typst/packages.git
```

The package PR target is always `typst/packages:main`.

## Version Choice

- Patch release (`0.1.1`): bug fixes, documentation fixes, or small rendering
  improvements without API changes.
- Minor release (`0.2.0`): new public API, behavior changes, or larger features.

Typst packages are immutable in practice. After a version is accepted, publish
fixes as a new version instead of editing the old version directory.

```sh
VERSION=0.1.0
PKG_REPO=/Users/gerocastano8/Documents/Coding/Projects/typst-packages
BRANCH=typed-dsa-package-$VERSION
```

## Local Release Steps

1. Make changes on `main`.
2. Update `typst.toml` to the new version.
3. Update README imports and examples to use the new version.
4. Compile the visual smoke test and inspect the rendered PNG:

```sh
typst compile --root . tests/test.typ tests/test.pdf
typst compile --root . --ppi 140 tests/test.typ tests/test.png
```

5. Compile the user guide:

```sh
typst compile --root . docs/documentation.typ docs/documentation.pdf
```

6. Regenerate README assets if examples or rendering changed (see the commands
   at the top of each `assets/readme/*.typ` source file).
7. Commit and push `main`.

## Typst Packages PR Steps

1. Sync the fork with upstream `main` and branch from it:

```sh
cd "$PKG_REPO"
git fetch upstream
git switch -C "$BRANCH" upstream/main
```

2. Copy the package files from the source repository:

```sh
cd /Users/gerocastano8/Documents/Coding/Projects/typed-dsa
scripts/package-preview.sh "$VERSION" "$PKG_REPO"
```

3. Run the package checker:

```sh
cd "$PKG_REPO/packages"
typst-package-check check @preview/typed-dsa:$VERSION
```

4. Commit and push:

```sh
cd "$PKG_REPO"
git add "packages/preview/typed-dsa/$VERSION"
git commit -m "typed-dsa:$VERSION"
git push -u origin "$BRANCH"
```

5. Open a PR to `typst/packages:main`.

PR title format:

```text
typed-dsa:<VERSION>
```

Example:

```text
typed-dsa:0.4.0
```

For package updates, use only the compact update PR body. Do not include a
validation section, a checks section, generated artifact notes, or the full
new-package checklist.

PR body format:

```markdown
I am submitting

- [ ] a new package
- [x] an update for a package

Changes:

- <meaningful user-visible change>
- <meaningful user-visible change>
```

Example update PR body:

```markdown
I am submitting

- [ ] a new package
- [x] an update for a package

Changes:

- Add breadth-first search trace diagrams for graph teaching material.
- Add a rendered BFS showcase to the README.
```

Reserve the full Typst package submission checklist for the initial package
submission only. Only list meaningful user-visible changes. Do not mention
routine regenerated artifacts unless they are the point of the release.

## Package Bundle Contents

Include:

```text
typst.toml
README.md
LICENSE
src/*.typ
assets/readme/*.png
```

Do not include: `tests/*`, `docs/*`, `assets/readme/*.typ`, `scripts/*`,
`CLAUDE.md`, `AGENTS.md`, `PACKAGING.md`, `.DS_Store`.

README PNGs are committed for Typst Universe rendering but excluded from the
downloaded bundle with `exclude = ["assets/readme/*.png"]`.
