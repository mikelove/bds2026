# BDS 2026 talk

Short slide deck for Biological Data Science 2026: "Frameworks for multi-sample
long-read RNA-seq analysis" (Michael Love, Beatriz Campillo, Justin Landis).
Source abstract is in `abstract.txt`.

## Files

- `michael-love-bds-2026.qmd` — the deck (Quarto + R chunks, Typst engine)
- `michael-love-bds-2026.pdf` — rendered output (git-ignored, along with `.quarto/`)
- `images/` — hex stickers (tximeta, splicelogic, plyxp, tidyomics; plyranges from
  `~/bioc/BiocStickers/`) copied from
  `~/proj/mikelove.github.io/assets/`, which also has lab headshots and other logos.
  Helpers defined in the first Typst block: `#sticker("name")` (3cm, 0.7cm from page top and right edges
  of a slide) and `#sticker-row(..names, h: 3cm)` (title slide: tximeta, plyxp, splicelogic;
  summary slide adds plyranges, tidyomics at the end).

## Workflow

- The user renders the deck themselves (`quarto render michael-love-bds-2026.qmd`).
  Don't render unless asked; just edit the `.qmd`.
- Code chunks always go on their own slide (no bullets alongside). Keep each
  slide to a single page.
- Text slides: 3-5 bullets of 6-12 words each. No bold for emphasis in
  bullets (the user dislikes that style).
- Diagram, code, and flowchart slides have no words besides the title (no code
  comments either). Talking points go in `#notes[...]` (11pt grey, bottom
  margin, software-name styling suppressed) as notes to self.
- Max 14 slides: title, question, why-new-syntax (bullets with smaller grey
  `#detail[...]` second lines), workflow, tximeta (concept, diagram, code),
  plyxp (concept, code), splicelogic (concept, code), TAPIR (collaboration with Hicks lab, JHU;
  Rachel Sharp photo), back-to-question (merged
  with summary, sticker row), acknowledgments. One code slide per tool showing
  its key operations; talking points live in `#notes[...]`.

## Typst / Quarto notes

- `papersize: presentation-16-9`; each level-1 `#` heading starts a new slide
  (show rule with `pagebreak(weak: true)` in `include-in-header`).
- Title slide is a raw ```` ```{=typst} ```` block, not YAML `title`.
- Quarto wraps code in a `Skylighting()` function (built from `block` + inline `raw`
  tokens), so `#show raw.where(block: true)` rules have no effect. Code size and
  line spacing are set by redefining `Skylighting` in the first Typst block of the
  body. Set size *and* `par(leading)` inside it, otherwise leading inherits from
  the 20pt body font and long outputs spill onto a new page.
- Software names are styled automatically (monospace, deep blue #2B6CA3) by a
  `show regex(...)` rule in the first Typst block; add new tool names to its
  list. An `in-code` state set inside `Skylighting` keeps code chunks unstyled.
- The closing slide's sticker row sits partly in the bottom margin (`dy`).
- Pandoc `.columns` divs don't render in Typst here; use a raw Typst `#grid(...)`.
- `section-numbering: null` fails YAML validation; just omit it.

## Content decisions

- Content slide 1 poses a question (why build frameworks / new syntax when an
  LLM can write the code?); the "Back to the question" closing slide (which
  also summarizes the three tools) answers it. Slide 3 makes the argument;
  the closing slide gives one bullet per tool as evidence, plus a takeaway.
- Slide 2 (question) has no title: hand-drawn cartoon
  `images/florm_human_coding.png` (13.8cm, `dy: -0.9cm` into the top margin) and the two bullets are both
  `place()`d (top / bottom), since in normal flow the list kept spilling
  onto an extra page well before the page was full.
- Closing slide: `images/finally.png` (6cm, centered) sits above the
  bullets; a trailing `#v(2.5cm)` reserves room for the placed sticker row
  (7cm overlapped it). Acknowledgments: `images/music_florm.png` (5cm) is `place()`d top
  right with the corner-sticker offsets, and `#v(3cm)` pushes the grid down.
  A `lab-photo()` row (Beatriz, Justin, Rachel; 2.6cm circles, first names)
  is `place()`d bottom right; inside the grid's right column it spilled to a new page.
- Student photos: `#student(file, name)` (circular 3cm photo + name, bottom-right,
  under the sticker column, caption in the bottom margin). Justin Landis on the
  first plyxp slide,
  Beatriz Campillo on the splicelogic slide, Rachel Sharp on the TAPIR slide; jpgs copied into `images/`.
- Content slide 2 is a workflow diagram (Typst `#grid` of `stage()` boxes; our
  tools highlighted in UNC blue) that replaced the original motivation slide.
  `stage(title, tools, desc)` = bold title, tools line, smaller grey
  description (pass `none` for no tools), vertically centered. First column
  stacks Annotate/Detect in a nested grid wrapped in `block(height: 100%)` so
  the 1fr rows resolve; the next column holds two rotated arrows (±30deg)
  converging on Quantify. A centered legend below (inline swatch box matching
  `ours: true`) reads "recent work from the lab".
- tximeta section follows the mixed-reference material in `refs/`
  (tximeta-mixed-ref-poster.qmd, salmon-with-mixed-ref-*, tximeta.Rmd):
  importData() -> inspectDigests() -> updateMetadata(), makeLinkedTxpData(),
  salmon (Snakemake digest rule + `mixedDigest`) is only mentioned in passing. Diagram is
  `images/mixed-ref-diagram.png` from the tximeta repo (the SVG renders with
  extra whitespace and small text in Typst, so use the PNG).
- plyxp and splicelogic messaging follows the Intro/Conclusion of the papers in
  `papers/` (plyxp.qmd, splicelogic.typ): plyxp = explicit contexts + pronouns,
  lazy data masks, used in tidySummarizedExperiment; splicelogic = any two
  transcript sets -> events, any DTU method, GRanges output, GTEx PTBP1 example.
  Isoform aggregation is mentioned only via the plyxp group_by/summarize code.
- Ecosystem tools to mention: upstream oarfish, bambu, AnVIL/Terra; downstream
  plyranges, DESeq2/satuRn (DEXSeq removed); related aggregation methods TreeTerminus/terminus,
  treeclimbR, stageR. Not chosen: IsoQuant/FLAIR/StringTie2, fishpond/swish,
  nullranges.

## R code

- plyxp requires wrapping a SummarizedExperiment with `new_plyxp(se)` before
  dplyr verbs. Contexts: `rows()`, `cols()`; pronouns `.assays_asis`, `.cols`, etc.
- All chunks are illustrative only: `execute: eval: false` globally plus `#| eval: false` in each chunk so Positron/VS Code don't treat them as runnable (Quarto is
  used just for syntax highlighting). No setup or toy-data chunks.

## Layout notes

- Quarto's Typst template justifies and hyphenates text; the first Typst block
  sets `par(justify: false)` and `text(hyphenate: false)` to avoid stretched
  spacing and "aggre-gate" breaks.
- No page numbers (removed at the user's request).
- Corner stickers must stay within the heading's height so they don't overlap
  the first bullet.
- Side margins are 2.8cm (was 1.6cm) to keep line lengths comfortable; the
  workflow-diagram boxes use 13pt text so labels still fit the narrower width.
- Slide content is vertically centered below the title: the heading show rule
  adds `v(1fr)` after the heading and (via the `slide-open` state) another
  `v(1fr)` before breaking to the next slide; a final `#v(1fr)` ends the document.
- For layout checks, render a copy in the scratchpad, not in the project dir.
- Code chunks use `set text(size: 24pt)` / `par(leading: 0.5em)` inside the
  `Skylighting` override (renders ~ body size, since raw tokens scale to 0.8em).
  Keep code lines under ~50 characters; put comments on their own lines.
  - All raw text (code chunks, inline code, styled software names) uses Fira Code
  via a global `#show raw: set text(font: "Fira Code")` in the first Typst block.
- Per-slide code overrides: `#code-size.update(20pt)` / `#code-width.update(72%)`
  in a Typst block before the chunk, reset to 24pt / 100% after. Used on the
  tximeta code slide, with `images/inspector.png` (5.6cm, ~1/3 slide height)
  `place()`d right + horizon.
