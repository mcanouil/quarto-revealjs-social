# RevealJS Social

A Quarto extension that adds Open Graph and Twitter (X) social-card `<meta>` tags to the `<head>` of RevealJS presentations.

It reads the standard Quarto social metadata you already use and injects the corresponding `<meta>` tags at render time, so links to your slides render rich previews on social platforms and in chat apps.

> [!IMPORTANT]
> Current Quarto versions emit some of these tags for RevealJS by themselves, which they did not when this extension was written.
> The extension still adds the ones Quarto omits, `og:url` and `og:type` among them, and re-emits several that Quarto has already written.
> See <https://m.canouil.dev/quarto-revealjs-social/examples.html>, which compares the same deck rendered with and without the filter.

## Installation

```bash
quarto add mcanouil/quarto-revealjs-social@1.0.1
```

This will install the extension under the `_extensions` subdirectory.
If you are using version control, you will want to check in this directory.

## Documentation

The full documentation lives at <https://m.canouil.dev/quarto-revealjs-social/>: every tag and where its value comes from, all the options, the overlap with Quarto's own metadata, and two decks to compare.

[`example.qmd`](example.qmd) is a short, standalone starting point you can copy.

## Licence

[MIT](https://github.com/mcanouil/quarto-revealjs-social?tab=MIT-1-ov-file#readme).
