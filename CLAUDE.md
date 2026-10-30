# BDS 2026 talk

Short slide deck for Biological Data Science 2026: "Frameworks for multi-sample
long-read RNA-seq analysis" (Michael Love, Beatriz Campillo, Justin Landis).
Source abstract is in `abstract.txt`.

## Files

- `michael-love-bds-2026.qmd` — the deck (Quarto + R chunks, Typst engine)
- `michael-love-bds-2026.pdf` — rendered output (git-ignored, along with `.quarto/`)
- `images/` — hex stickers (tximeta, splicelogic, plyxp, tidyomics) copied from
  `~/proj/mikelove.github.io/assets/`, which also has lab headshots and other logos.
  Helpers defined in the first Typst block: `#sticker("name")` (2.3cm, 0.7cm from page top and right edges
  of a slide) and `#sticker-row(..names, h: 3cm)` (title and summary slides).

## Workflow

- The user renders the deck themselves (`quarto render michael-love-bds-2026.qmd`).
  Don't render unless asked; just edit the `.qmd`.
- Code chunks always go on their own slide (no bullets alongside); split a slide
  when needed. Slide count is not fixed (currently 10 pages). Keep each slide
  to a single page.

## Typst / Quarto notes

- `papersize: presentation-16-9`; each level-1 `#` heading starts a new slide
  (show rule with `pagebreak(weak: true)` in `include-in-header`).
- Title slide is a raw ```` ```{=typst} ```` block, not YAML `title`.
- Quarto wraps code in a `Skylighting()` function (built from `block` + inline `raw`
  tokens), so `#show raw.where(block: true)` rules have no effect. Code size and
  line spacing are set by redefining `Skylighting` in the first Typst block of the
  body. Set size *and* `par(leading)` inside it, otherwise leading inherits from
  the 20pt body font and long outputs spill onto a new page.
- Pandoc `.columns` divs don't render in Typst here; use a raw Typst `#grid(...)`.
- `section-numbering: null` fails YAML validation; just omit it.

## Content decisions

- Content slide 1 is a workflow diagram (Typst `#grid` of `stage()` boxes; our
  tools highlighted in UNC blue) that replaced the original motivation slide.
- Ecosystem tools to mention: upstream oarfish, bambu, AnVIL/Terra; downstream
  plyranges, DESeq2/satuRn (DEXSeq removed); related aggregation methods TreeTerminus/terminus,
  treeclimbR, stageR. Not chosen: IsoQuant/FLAIR/StringTie2, fishpond/swish,
  nullranges.

## R code

- plyxp requires wrapping a SummarizedExperiment with `new_plyxp(se)` before
  dplyr verbs. Contexts: `rows()`, `cols()`; pronouns `.assays_asis`, `.cols`, etc.
- Slides 4–5 use a small simulated transcript-level SE (12 tx, 4 genes, 6 samples).
- tximeta chunk is `eval: false` (illustrative only).

## TODO

- Funding slide has placeholder grant numbers marked TODO.

## Layout notes

- Quarto's Typst template justifies and hyphenates text; the first Typst block
  sets `par(justify: false)` and `text(hyphenate: false)` to avoid stretched
  spacing and "aggre-gate" breaks.
- Page number is a custom footer (12pt grey, right-aligned) set after the title
  slide; the title slide has no number.
- Corner stickers must stay within the heading's height so they don't overlap
  the first bullet.
- Side margins are 2.8cm (was 1.6cm) to keep line lengths comfortable; the
  workflow-diagram boxes use 13pt text so labels still fit the narrower width.
- Slide content is vertically centered below the title: the heading show rule
  adds `v(1fr)` after the heading and (via the `slide-open` state) another
  `v(1fr)` before breaking to the next slide; a final `#v(1fr)` ends the document.
- For layout checks, render a copy in the scratchpad, not in the project dir.
- Code chunks use `set text(size: 26pt)` / `par(leading: 0.25em)` inside the
  `Skylighting` override (renders ~ body size, since raw tokens scale to 0.8em).
  Keep code lines under ~50 characters; put comments on their own lines.
  