# BDS 2026 talk

Short slide deck for Biological Data Science 2026: "Frameworks for multi-sample
long-read RNA-seq analysis" (Michael Love, Beatriz Campillo, Justin Landis).
Source abstract is in `abstract.txt`.

## Files

- `michael-love-bds-2026.qmd` — the deck (Quarto + R chunks, Typst engine)
- `michael-love-bds-2026.pdf` — rendered output (git-ignored, along with `.quarto/`)

## Workflow

- The user renders the deck themselves (`quarto render michael-love-bds-2026.qmd`).
  Don't render unless asked; just edit the `.qmd`.
- Target structure: 1 title slide + 6 content slides + 1 acknowledgments/funding
  slide (8 pages total). Keep each slide to a single page.

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

## R code

- plyxp requires wrapping a SummarizedExperiment with `new_plyxp(se)` before
  dplyr verbs. Contexts: `rows()`, `cols()`; pronouns `.assays_asis`, `.cols`, etc.
- Slides 4–5 use a small simulated transcript-level SE (12 tx, 4 genes, 6 samples).
- tximeta chunk is `eval: false` (illustrative only).

## TODO

- Funding slide has placeholder grant numbers marked TODO.
