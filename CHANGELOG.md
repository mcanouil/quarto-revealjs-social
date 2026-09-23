# Changelog

## Unreleased

### Bug Fixes

- fix: Read the `enabled` option through the schema, so a value that is not a boolean is reported rather than ignored. Comparing the document text left every spelling but `false` emitting the card tags in silence. (#22)
- fix: Gate the options check on the revealjs format so non-acting formats stay silent. (#22)
- fix: Report a key nested inside an option as a warning rather than an error, so one nested typo does not invalidate the whole configuration. This matches how the extension already reports an unknown key at the top of its own block. (#22)

### Documentation

- docs: Add a page for each group of social options, and turn the examples page into an overview that links to them. (#23)
- docs: Serve the extension's social card as the Open Graph image, so a shared link shows the card rather than the first image on the page. (#18)

### Refactoring

- build: Update the vendored Lua modules to 2.3.0, which includes the `schema-check` fix for an extension whose entry points are in a subdirectory. A module no longer carries a version line in its header, so its checksum changes only when its code changes. (#19)
- build: Fetch the schema validator from a Quarto Wizard release asset rather than a raw path inside its repository, which a refactor could move without notice. The vendored file is unchanged. (#21)
- build: Update the vendored Lua modules to 2.5.0, which adds the accessor that reads what the schema resolves an option to. The schema validator moves to its own release train and is pinned at `schema-v2.2.0`, which accepts only `true` and `false` as a boolean. (#22)

## 1.1.0 (2026-09-07)

### New Features

- feat: Check the document configuration against the extension schema and report what it does not accept. (#14)

## 1.0.1 (2026-08-01)

### Bug Fixes

- fix: Write `og:locale` as `language_TERRITORY`, which is the form Open Graph specifies. A value taken from `lang` is a BCP 47 tag using a hyphen, so `lang: en-GB` produced `en-GB` instead of `en_GB`.
- fix: Read a top-level `image-alt`, so `og:image:alt` and `twitter:image:alt` are emitted for a document that sets it outside the `open-graph` block.
- fix: Honour `enabled: false` written as a bare YAML boolean, which was read as an absent option so the filter kept running.

### Documentation

- docs: Add a documentation website under `docs/`, built on the `atelier` project type and published to <https://m.canouil.dev/quarto-revealjs-social/>, building the same deck with and without the filter so the two heads can be compared.
- docs: Record that current Quarto emits twelve social tags for RevealJS by itself, that the filter adds six more, and that ten are written twice when both run.
- docs: Trim `README.md` to a landing page pointing at the website, and `example.qmd` to a short starting point to copy.
- docs: Add the Pages workflow, which renders `docs/` on pull requests and deploys it from the release tag.
- docs: Add the Quarto Extensions Updates workflow, scanning `docs` for the website's own dependencies.

## 1.0.0 (2026-07-10)

- feat: Initial release.
