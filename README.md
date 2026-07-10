# RevealJS Social

A Quarto extension that adds Open Graph and Twitter (X) social-card `<meta>` tags to the `<head>` of RevealJS presentations.

Quarto emits social-card metadata for HTML documents and websites, but not for RevealJS presentations.
This extension fills that gap: it reads the standard Quarto social metadata you already use and injects the corresponding `<meta>` tags at render time, so links to your slides render rich previews on social platforms and in chat apps.

## Installation

```bash
quarto add mcanouil/quarto-revealjs-social@1.0.0
```

This will install the extension under the `_extensions` subdirectory.
If you are using version control, you will want to check in this directory.

## Usage

To use the extension, add the following to your document's front matter:

```yaml
filters:
  - social
```

The extension reads standard Quarto social metadata first and falls back to scoped `extensions.social` options.
A typical presentation only needs the standard keys:

```yaml
title: "The Grammar of Graphics Assembles"
description: "A talk on Gribouille, a native Typst grammar-of-graphics package."
site-url: "https://m.canouil.dev/2026-ggplot2-extenders-gribouille/"
image: "assets/social-card.png"
open-graph:
  image-width: 4000
  image-height: 2000
twitter-card: true
format: revealjs
filters:
  - social
```

### Metadata resolution

Each tag is resolved from the first available source, then the scoped fallback:

| Emitted tag                                            | Standard source(s)                                                            | Scoped fallback (`extensions.social.*`) |
| ------------------------------------------------------ | ----------------------------------------------------------------------------- | ------------------------------------------------ |
| `og:title`, `twitter:title`                            | `open-graph.title`, `twitter-card.title`, top-level `title`                   | `title`                                          |
| `description`, `og:description`, `twitter:description` | `open-graph.description`, `twitter-card.description`, top-level `description` | `description`                                    |
| `og:image`, `twitter:image`                            | `open-graph.image`, `twitter-card.image`, top-level `image`                   | `image`                                          |
| `og:image:width` / `og:image:height`                   | `open-graph.image-width` / `open-graph.image-height`                          | `image-width` / `image-height`                   |
| `og:image:alt`, `twitter:image:alt`                    | `open-graph.image-alt`                                                        | `image-alt`                                      |
| `og:site_name`                                         | `open-graph.site-name`                                                        | `site-name`                                      |
| `og:locale`                                            | `open-graph.locale`, top-level `lang`                                         | `locale`                                         |
| `og:url`                                               | `site-url` (or `url`)                                                         | `url`, `site-url`                                |
| `twitter:card`                                         | `twitter-card.card-style`                                                     | `card-style`                                     |
| `twitter:site` / `twitter:creator`                     | `twitter-card.site` / `twitter-card.creator`                                  | `twitter-site` / `twitter-creator`               |

The four Open Graph required properties (`og:title`, `og:type`, `og:image`, `og:url`) are emitted whenever a value is available.
`og:type` defaults to `website`, `og:image:type` is inferred from the image file extension, and `og:image:secure_url` is added when the image URL is HTTPS.

### Configuration

When the standard keys do not fit, configure the extension directly:

```yaml
extensions:
  social:
    site-url: "https://example.com/my-talk/"
    image: "assets/social-card.png"
    image-width: "1200"
    image-height: "630"
    image-alt: "Title slide of the talk."
    site-name: "My Talks"
    twitter-creator: "@myhandle"
```

#### Options

| Option            | Type    | Default              | Description                                                                 |
| ----------------- | ------- | -------------------- | --------------------------------------------------------------------------- |
| `enabled`         | boolean | `true`               | Enable or disable the filter.                                               |
| `title`           | string  | document title       | Social-card title.                                                          |
| `description`     | string  | document description | Social-card description.                                                    |
| `image`           | string  | document image       | Social-card image path or URL.                                              |
| `image-width`     | string  | (omitted)            | Image width in pixels.                                                      |
| `image-height`    | string  | (omitted)            | Image height in pixels.                                                     |
| `image-alt`       | string  | (omitted)            | Alternative text for the image.                                             |
| `image-type`      | string  | inferred             | IANA media type of the image (e.g. `image/png`).                            |
| `locale`          | string  | document `lang`      | Content locale for `og:locale` (e.g. `en_GB`).                              |
| `site-name`       | string  | (omitted)            | Site name for `og:site_name`.                                               |
| `site-url`        | string  | (omitted)            | Base URL used to build absolute `og:url` and `og:image` URLs.               |
| `url`             | string  | `site-url`           | Canonical page URL for `og:url`.                                            |
| `type`            | string  | `website`            | Open Graph object type for `og:type`.                                       |
| `card-style`      | string  | see below            | Twitter card style; defaults to `summary_large_image` when an image is set. |
| `twitter-site`    | string  | (omitted)            | Twitter `@username` of the site.                                            |
| `twitter-creator` | string  | (omitted)            | Twitter `@username` of the creator.                                         |

## Limitations

> [!IMPORTANT]
> Social scrapers require an absolute `og:image` URL.
> Set `site-url` so relative image paths are resolved against it, or provide an absolute image URL.
> A warning is emitted when a relative image path is used without `site-url`.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

Output of `example.qmd`:

- [Reveal.JS](https://m.canouil.dev/quarto-revealjs-social/)
