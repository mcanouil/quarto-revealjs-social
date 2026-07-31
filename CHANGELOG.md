# Changelog

## Unreleased

### Documentation

- docs: Add a documentation website under `docs/`, built on the `atelier` project type and published to <https://m.canouil.dev/quarto-revealjs-social/>, building the same deck with and without the filter so the two heads can be compared.
- docs: Record that current Quarto emits twelve social tags for RevealJS by itself, that the filter adds six more, and that ten are written twice when both run.
- docs: Trim `README.md` to a landing page pointing at the website, and `example.qmd` to a short starting point to copy.
- docs: Add the Pages workflow, which renders `docs/` on pull requests and deploys it from the release tag.
- docs: Add the Quarto Extensions Updates workflow, scanning `docs` for the website's own dependencies.

## 1.0.0 (2026-07-10)

- feat: Initial release.
