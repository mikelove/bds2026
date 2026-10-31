// splicelogic preprint (bioRxiv-style, single column)
// Compile: typst compile splicelogic.typ

// Set to false to hide drafting tags, notes and TODOs
#let show-notes = true

#let tag(body) = if show-notes {
  text(size: 0.8em, fill: gray.darken(30%), font: "DejaVu Sans Mono")[\[#body\]]
}
#let note(body) = if show-notes {
  block(
    fill: luma(245), stroke: (left: 2pt + gray), inset: (x: 8pt, y: 5pt),
    width: 100%, text(size: 0.9em, fill: gray.darken(40%), body),
  )
}
#let todo(body) = if show-notes { text(fill: red.darken(20%))[⟨#body⟩] }

// Placeholder until figure files exist; swap for image("figures/....pdf", width: 100%)
#let placeholder(label) = rect(
  width: 100%, height: 4.5cm, stroke: (dash: "dashed", paint: gray),
  align(center + horizon, text(fill: gray)[#label]),
)

#let sl = raw("splicelogic")

// ---------------------------------------------------------------------------

#set document(title: "splicelogic", author: ())
#set page(
  paper: "us-letter",
  margin: (x: 0.75in, y: 0.8in),
  numbering: "1",
  columns: 2,
)
#set columns(gutter: 0.3in)
#set text(font: "Libertinus Serif", size: 10pt, lang: "en")
#set par(justify: true, leading: 0.65em, spacing: 1em)
// #set par.line(numbering: "1", number-clearance: 0.8em)
#show raw: set text(font: "DejaVu Sans Mono", size: 0.9em)
#show raw.where(block: true): block.with(fill: luma(245), inset: 8pt, radius: 2pt, width: 100%)
#show heading.where(level: 1): set text(size: 12pt)
#show heading.where(level: 1): set block(above: 1.6em, below: 0.9em)
#show heading.where(level: 2): set text(size: 10pt, style: "italic", weight: "regular")
#show link: set text(fill: blue.darken(30%))
#show ref: set text(fill: blue.darken(30%))
#show figure.caption: set text(size: 0.9em)
#show figure.caption: set align(left)
#show bibliography: set text(size: 0.85em)

// Title block (spans both columns) ---------------------------------------------

#place(top + center, float: true, scope: "parent", clearance: 1.5em)[
#align(center)[
  #text(size: 17pt, weight: "bold")[Deducing splicing events from transcript sets with splicelogic]
  #v(0.8em)
  Beatriz Campillo#super[1,2], Michael I. Love#super[2,3]
  #v(0.4em)
  #text(size: 9pt)[
    #super[1]Bioinformatics and Computational Biology Curriculum, University of North Carolina at Chapel Hill \
    #super[2]Department of Genetics, University of North Carolina at Chapel Hill \
    #super[3]Department of Biostatistics, University of North Carolina at Chapel Hill \
    Correspondence: love\@unc.edu
  ]
]

#v(1em)
#block(inset: (x: 2em))[
  #set align(left)
  #set text(size: 9pt)
  *Abstract.*
  
Long-read RNA sequencing captures a greater proportion of full-length transcripts, enabling more accurate isoform identification, discovery of novel isoforms, and more precise differential transcript usage analysis. However, comparing transcripts, whether between conditions or between sets such as novel and annotated isoforms, yields complex isoform changes that are hard to manipulate, summarize, and visualize. This is compounded by vertical integration of some tools, where downstream analysis depends on the specific output of a particular upstream tool.
To address this gap, we have developed splicelogic, an R/Bioconductor package that makes transcript-set comparisons biologically interpretable by turning them into discrete splicing events, such as exon skipping, alternative splice sites, intron retention, and alternative transcription start and end sites. We designed splicelogic to integrate easily with existing RNA-seq workflows and tools.
The splicelogic functions are modular, readable, and extensible, making it easy for users to adapt core logic to their own custom scientific questions or novel splicing definitions. By obtaining interpretable splicing events from transcript changes, splicelogic enables downstream analyses, including annotation of RNA-binding protein recognition sites, alongside summary statistics and visualization.
The splicelogic package is publicly available and distributed through Bioconductor.

  #v(0.3em)
  *Keywords:* alternative splicing, differential isoform usage, differential transcript usage, long-read RNA-seq
]
]

// Introduction ----------------------------------------------------------------

= Introduction

A single gene can give rise to multiple distinct mRNA isoforms through alternative transcription start sites, alternative splicing, and alternative transcription end sites. Splicing removes introns from the pre-mRNA and joins exons to form the mature transcript. Alternative promoters and polyadenylation sites change the 5′ and 3′ ends of the transcript, altering UTRs and, in some cases, the first or last coding exons. Together these processes are a major mechanism of gene regulation and a key source of protein diversity, and isoform usage can shift in response to different conditions or over time.

Despite the central role of splicing in transcriptome complexity, the systematic detection and functional interpretation of splicing changes remain a significant challenge. Interpreting these changes requires understanding both what drives them, such as changes in RNA-binding protein activity, and what they lead to, such as altered protein function, RNA localization, or transcript stability, including nonsense-mediated decay. Splicing changes between conditions, tissues, or cell types are rarely a single event: one condition may favor skipping of some exons and inclusion of others, while also shifting splice sites, retaining introns, or switching first and last exons. Summarizing these directional shifts across many genes and event types remains difficult.

RNA-seq has become the standard tool for quantifying isoform expression. Short-read RNA-seq is cost-effective and widely available. However, because most short reads are compatible with multiple overlapping transcripts, assigning them to specific isoforms is inherently ambiguous. Short-read sequencing limits resolution of complex structures involving multiple splicing events or alternative UTRs, as well as novel transcripts. As a result, most splicing detection methods for short reads work at the level of individual events, quantifying splicing as ratios of junction-spanning read counts without the context of the full transcript.

Beyond junction-level methods, several tools work with whole transcripts. _SUPPA2_ @Trincado2018 and _IsoformSwitchAnalyzeR_ @VittingSeerup2019 accept abundances from common quantifiers but apply their own differential tests, so neither tool can take results from an arbitrary differential transcript usage (DTU) method. _GeneStructureTools_ @Signal2026 interprets events only from junction-based tools, and long-read tools such as _SQANTI3_ @PardoPalacios2024 and _IsoQuant_ @Prjibelski2023 classify novel isoforms relative to the reference rather than calling directional events between transcript sets. _FLAIR_ @Tang2020 derives intron retention, alternative 5′ and 3′ splice site, and exon skipping events from isoform models assembled by _FLAIR_ and read counts from its own quantification step, and tests their differential usage. It also predicts isoform productivity from open reading frames. _Swan_ @Reese2021 is flexible, accepting any transcriptome as a GTF together with a transcript abundance table. It tracks the usage of transcripts and of transcription start and end sites, and, when paired with a companion tool, of intron chains. _Swan_ tests each of these for switching between two conditions with its own differential test, and can use a splice graph to detect exon skipping, intron retention, and alternative splice site events relative to the reference annotation.

Long-read RNA sequencing captures a greater proportion of full-length transcripts, enabling more accurate isoform identification, discovery of novel isoforms, and more precise DTU analysis. However, the isoform changes underlying shifts in usage are complex, and asking questions outside a tool's predefined analyses typically requires custom code that may be difficult for others to read and adapt. This is compounded by the vertical integration of some existing tools, where each downstream analysis depends on specific output of a particular upstream tool.

Here we present #sl, an R/Bioconductor @Huber2015 package that turns any two sets of transcripts into discrete splicing events, working equally well with results from any DTU method or with any user-defined partition of the transcripts. We designed #sl as a modular, efficient, and flexible framework that integrates easily with existing RNA-seq workflows and tools, and allows customized downstream computation and visualization.

// Approach ----------------------------------------------------------------------

= Approach

== 1. Overview

Given two contrasting sets of transcripts, we describe their differences as a series of discrete splicing events. Transcript sets come either from a user-supplied partition or from a DTU analysis, in which each transcript with a detected change has a signed effect estimate such as a model coefficient, a change in isoform fraction, or $Delta psi$ (change in percent spliced in). Because the input is a set of transcript-level effect estimates, any upstream DTU method can be used, including _DRIMSeq_ @Nowicka2016, _DEXSeq_ @Anders2012, _satuRn_ @Gilis2022, and _edgeR_ @Chen2025.

Event detection is built on vectorized integer-range operations from _GenomicRanges_ @Lawrence2013 and typically takes a fraction of a second on large transcript sets from long-read RNA-seq experiments. The framework is modular and fits into existing workflows: results are projected from transcript space to the space of exon events, so users can operate directly on the detected events and their coordinates. Splice events and their consequences are represented as standard range objects, and annotations are provided as metadata columns available for computation. This allows users to directly ask subsequent questions with tools such as _plyranges_ or _Biostrings_, for example to compare nucleotide frequencies around splice events or the proportions of event types. 

== 2. Input: two entry points

#sl takes as input the exon ranges for a set of transcripts across all genes, with each exon labeled by its gene, its transcript, its rank within the transcript, and a value giving the direction of change of that transcript. This input can be built from a DTU analysis or from a defined partition of the transcripts into two sets. With DTU results, the transcript annotation is combined with the per-transcript effect estimates, and the sign of each estimate marks a transcript as "positive" (up-regulated) or "negative" (down-regulated). With a set partition, such as novel versus annotated isoforms or disease versus control, no estimates are needed: the reference set is "negative" and the alternative set is "positive". Either route yields the same input, and from that point on the workflow is identical.


== 3. Event detection

#sl detects various types of events: skipped exons (SE), included exons (IE), mutually exclusive exons (MXE), retained introns (RI), alternative 5′ and 3′ splice sites (A5SS, A3SS), and alternative transcription start and end sites (ATSS, ATES). Each event is defined between a pair of transcripts from the same gene, one from each group, by comparing their exon structures. For SE, IE, and MXE, neighboring exons can be matched across transcript pairs using different levels of stringency (#link(<supp-type>)[Supplementary Methods]). Each event type has its own function, which can be called by a short name or by a longer alias for readability, so `find_se()` and `find_skipped_exons()` are equivalent, and `find_all_events()` runs all of them at once.

== 4. Output

Each `find_*()` function returns the exons involved in an event, one row per exon and paired transcript. Each row keeps the user's original exon-level metadata, which describes the transcript that contains the returned exon, and adds event-specific columns, prefixed with `event_`, that describe the paired transcript against which the event is defined: the event type, the paired transcript's ID and estimate, and any additional columns requested by the user (_e.g._ $psi$ per group).

== 5. Design and integration

Detected events are returned as genomic ranges with metadata, so downstream analysis can use standard Bioconductor tools rather than package-specific functions. For example, the nucleotide sequence of each event, or of its flanking intronic region, can be extracted with the helper function `splicelogic::get_seq()` and subsequently analyzed with _Biostrings_ summarization or pattern-matching functions. Events can be manipulated or summarized with readable syntax from _plyranges_ @Lee2019, part of the tidyomics ecosystem @Hutchison2024. 

In #sl and in other splicing annotation workflows, an exon can participate in an event against more than one paired transcript, and so may appear on several rows. Grouping by exon and event type and collapsing with _plyranges_ results in one call per exon and event type, with the paired transcript IDs concatenated in metadata columns (@code-collapse). This facilitates transcriptome-wide summaries of numbers of events by type, without numbers being inflated across transcript pairs within a gene. Similarly, grouping events by transcript pair identifies pairs carrying more than one event, revealing complex splicing patterns. These downstream use cases are demonstrated in the #sl vignette. Each event type is defined in a short function built from standard range operations, so users can inspect the core logic and adapt it to their own questions or to new event definitions.

// Results -------------------------------------------------------------------------

= Results

#figure(
  image("figures/figure1.png", width: 100%),
  placement: top,
  scope: "parent",
    caption: [Speed of event detection and intronic context around skipped exons.
    (a) Runtime of `find_se()` on simulated data, shown as mean ±s.e. over 200 iterations.
    (b) Nucleotide composition of the intronic sequence flanking skipped exons (SE) detected by `find_se()` in transcripts with significant DTU after PTBP1 knockdown, shown as solid lines, compared to random non-skipped exons (non-SE) from transcripts without DTU, shown as dashed lines.],

) <fig-flank>

== 1. Speed benchmark on simulated data

We benchmarked the speed of #sl on simulated data. We varied the number of genes, the number of "positive" transcripts per gene, each compared against one "negative" transcript, and the fraction of genes carrying a skipped-exon event. Runtime of `find_se()` increased linearly with the total number of exons and remained under 0.3~s for the largest case of 150,000 exons (5,000 genes, 2 transcripts per gene, and 15 exons per transcript; @fig-flank#"a"\; #link(<supp-bench>)[Supplementary Methods]). The other `type` settings of `find_se()` and event detection functions performed similarly.



== 2. Correctness

We validated #sl splicing event detection against _Biosurfer_ @Murali2025. _Biosurfer_ compares pairs of GENCODE protein isoforms and classifies the splicing events behind each region where their protein sequences differ.
From its GENCODE v42 output, we selected isoform pairs that differ by a single skipped exon, included exon, alternative 5′ splice site, or alternative 3′ splice site, sampling up to 2,000 pairs per event type. We then ran the matching #sl function on each pair (#link(<supp-biosurfer>)[Supplementary Methods]).
For each detected event, we translated the skipped or included exon, or the region between the two alternative splice sites, with `translate()` from _Biostrings_.
For every event type, the translated amino acid sequence was identical to the sequence _Biosurfer_ reported as gained or lost, both for exons in phase and for exons out of phase.
We additionally sampled up to 2,000 pairs of transcripts with retained introns, where #sl detected all retained introns at the level of coordinates (#link(<supp-biosurfer>)[Supplementary Methods]).

== 3. Application datasets

The #sl vignette demonstrates the package on a published long-read dataset @Jones2024, in which Jones _et al._ used Oxford Nanopore Technologies (ONT) sequencing to compare splicing across four mouse brain regions and between sexes. We used the authors' DTU results, focusing on female versus male cortex and splitting the 26 transcripts with FDR < 0.1 into up- and down-regulated sets by the DTU coefficient. From these, #sl recovered 22 events in 10 genes and 20 transcripts.

We also applied #sl to a long-read ONT dataset published by Glinos _et al._ @Glinos2022 as part of GTEx v9. We focused on the long-read data of RNA from human skin fibroblasts subject to PTBP1 knockdown (KD) as well as controls. We quantified transcript abundance with _oarfish_ @ZareJousheghani2025 on the AnVIL platform @Schatz2022, then performed DTU analysis using _satuRn_ @Gilis2022 and identified 1,987 transcripts in 1,023 genes with significant changes in usage (FDR < 0.1). #sl was used to detect splicing events in the presence of PTBP1 (WT) compared to reduced PTBP1 (KD).

Within the Bioconductor and tidyomics frameworks, we extracted the intronic sequence flanking detected skipped exons. The sequence upstream of PTBP1-induced skipped exons recapitulated PTBP1's known binding preference (@fig-flank#"b"\; #link(<supp-flank>)[Supplementary Methods]). Example #sl code follows:


#figure(
  ```r
exons <- prepare_exons(
    txdb, dtu_results, coef_col = "estimate"
  ) %>%
  preprocess(coef_col = "estimate")

exons %>%
  find_skipped_exons() %>%
  flank_upstream(100) %>%
  mutate(intron_seq = get_seq(., "hg38"))
  ```,
  supplement: [Code],
  caption: [Finding skipped exons and obtaining their upstream intronic sequence. The #sl functions `find_skipped_exons()` and `get_seq()` are demonstrated within a tidyomics pipeline, including _plyranges_ for range manipulation.],
) <code-se>

Lastly, we ran #sl on a transcript set comparison without DTU results, using the Glinos _et al._ dataset to compare the annotated transcripts from the GENCODE v48 annotation with the novel isoforms detected by _bambu_ @Chen2023, which we also ran on AnVIL, with a novel discovery rate (NDR) threshold of 0.244. We used #sl to detect splicing events between the annotated and novel transcripts and summarized them by type, detecting 790 events in total after collapsing redundant exon events, most frequently ATSS (262, 33.2%) and ATES (219, 27.7%). Of the remaining 309 internal splicing events, the most frequent was SE (72, 23.3%).

// Conclusion ----------------------------------------------------------------------

= Conclusion
#sl turns any two sets of transcripts into discrete splicing events. Because it operates on whole transcript structures, these events are derived with full isoform context. #sl provides a modular, efficient, and flexible framework for identifying and interpreting splicing events while integrating with existing workflows.

= Code availability

The #sl package has been part of Bioconductor since release 3.23, and is also available at #link("https://github.com/thelovelab/splicelogic")[https://github.com/thelovelab/splicelogic].
The code used to generate the simulation and analyze the datasets can be found at #link("https://github.com/beamimc/splicelogic-paper"), archived at #link("https://doi.org/10.5281/zenodo.23787440")[doi:10.5281/zenodo.23787440].

= Acknowledgments

We thank Justin Landis, Rachel Sharp, Emma Jones, Dafni Glinos, Megan Schertzer, Gloria Sheynkman, and Kateřina Matějková for helpful discussions and feedback.

= Funding

This work was supported by the National Human Genome Research Institute [R01-HG009937] and by the Wellcome Trust [313919/Z/24/Z] as part of the Essential Open Source Software for Science (EOSS) program.

// References ----------------------------------------------------------------------

#set par.line(numbering: none)
#pagebreak()

#bibliography("references.bib", title: "References", style: "ieee")

// Supp Methods

#pagebreak()

= Supplementary Methods

== Matching of flanking exons <supp-type>
The functions `find_se()` and `find_mxe()` share the same vectorized first steps. Exons are split into the "positive" and "negative" sets by the sign of their estimate. Candidate exons are then selected with a single directed overlap count, within each gene. For each candidate, the two exons flanking it in its own transcript are matched, in one batched overlap search, against the "positive" exons of the same gene. A "positive" transcript skips the candidate when the two flanks match consecutive exons in it; for MXE, the flanks must match exons one apart, and the exon between them must not overlap the candidate. In both cases, the matched exons must not extend into the candidate. `find_ie()` similarly runs `find_se()` with the roles of the "positive" and "negative" sets swapped. The `type` argument sets what counts as a match between a flanking exon and its equivalent exon in the other set:

- `"over"` (default): any overlap, with no coordinate in common required. This is the most permissive setting.
- `"boundary"`: the two exons overlap _and_ share the inner boundary of the flank, the splice site facing the candidate: the donor of the upstream flank and the acceptor of the downstream one. The outer boundaries may differ.
- `"identical"`: the two exons are identical (same start and same end). This is the strictest setting.

== Benchmarking of event detection functions <supp-bench>

Simulated data were generated with `create_mock_data()`, giving each gene one "negative" transcript and one or more "positive" transcripts, each with 15 exons. Skipped-exon events were introduced with `generate_se()` in a fraction of genes set by the event ratio, with a maximum of 1 event per gene. From a baseline of 1,000 genes, an event ratio of 1, and one "positive" transcript per gene, we varied one parameter at a time: the number of genes (500, 1,000, 2,000, 5,000), the event ratio (0.1, 0.5, 1), and the number of "positive" transcripts per gene (1 to 10). Each setting was timed with _bench_ over 200 iterations on a MacBook Air with an Apple M4 chip and 16~GB of memory (macOS 15.6.1). @fig-flank#"a" shows the mean ±s.e. runtime of `find_se()` with the default `type`, `"over"`. We also measured the runtime of `find_se()` for each `type` setting, and of the other event finders, varying one parameter at a time from the same baseline.

== Comparison of exon translations with Biosurfer <supp-biosurfer>

Exons in phase were translated directly. For exons out of phase, the one or two nucleotides of the split codon at each boundary were first trimmed, and the split-codon residue was removed from the _Biosurfer_ sequence before comparing.
We did not compare amino acid sequences for retained introns, because they often introduce a premature stop codon or frameshift.

== Intronic sequence flanking skipped exons <supp-flank>

Skipped exons (SE) were obtained with `find_se()` on transcripts with significant DTU (_satuRn_, FDR < 0.1) between PTBP1 knockdown and control samples in the GTEx v9 ONT data of Glinos _et al._ @Glinos2022. Transcript abundance was quantified with _oarfish_ against the GENCODE v48 transcripts. As a comparison set, we sampled an equal number of random non-skipped exons (non-SE) from transcripts without evidence of DTU (_satuRn_, _p_ > 0.5). For each exon, we extracted the 100~bp of intronic sequence upstream and downstream with `get_seq()` and computed the nucleotide fraction in 10-bp overlapping windows sliding by 5~bp. @fig-flank#"b" shows the mean nucleotide fraction per window, with ribbons showing ±s.e.

== Collapsing events by exon and event type

Each `find_*()` call returns one row per exon and paired transcript. Because an exon can participate in an event against more than one partner transcript, the same range can appear on several rows: one for each transcript of the compared set with which it forms the same type of event. Keeping these rows is useful when both transcripts involved in each event are needed. However, for counting events, for example to summarize the total number of events by type, the rows should first be collapsed to one call per exon and event type, with the partner transcript IDs concatenated (@code-collapse). The column `n` gives the number of transcript pairs behind each call.

#figure(
  ```r
my_paste <- \(x) paste(unique(x), collapse = ",")

collapsed_events <- events |>
  group_by(exon_id, event_type) |>
  reduce_ranges_directed(
    n           = plyranges::n(),
    tx_id       = my_paste(tx_id),
    exon_rank   = my_paste(exon_rank),
    event_tx_id = my_paste(event_tx_id)
  )
event_counts <- collapsed_events |>
  as_tibble() |>
  count(event_type, name = "count")
  ```,
  kind: "supp-code",
  supplement: [Supplementary Code],
  caption: [Collapsing and summarizing splicing events. This code makes use of _plyranges_ and _dplyr_ to manipulate genomic ranges following #sl event detection functions.],
) <code-collapse>

#pagebreak()

== Piping with #sl and _plyranges_ <supp-pipe>

The base R pipe `|>` and the _magrittr_ pipe `%>%` can usually be used interchangeably with #sl and _plyranges_ functions. The exception is when the piped object must be referenced inside an argument on the right-hand side, as in `mutate(intron_seq = get_seq(., "hg38"))` in @code-se. There, `%>%` is needed, because its `.` placeholder stands for the piped object.

== Software versions <supp-versions>

R analyses used R 4.6 and Bioconductor 3.23, with #sl 1.1.4. Transcripts were quantified with _oarfish_ 0.9.4 and novel isoforms detected with _bambu_ 3.12.1 (R 4.5 and Bioconductor 3.22), both on AnVIL. _Biosurfer_ output was based on GENCODE v42, and all other analyses used GENCODE v48.

== GTEx data <supp-gtex>

The Genotype-Tissue Expression (GTEx) Project was supported by the Common Fund of the Office of the Director of the National Institutes of Health, and by NCI, NHGRI, NHLBI, NIDA, NIMH, and NINDS. The data used for the analyses described in this manuscript were obtained from dbGaP accession number phs000424.v11.p2 in May 2026.
