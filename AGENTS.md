# Meaning and Covariation in 300 Personality Items

These instructions apply to this project and its reproducibility archive.

## Working with Denny

Be friendly, creative, and clear. Explain computational work in ordinary language. Denny is a scientist; do not assume programming knowledge. Turn research ideas into working analyses and reviewable documents. Current explicit user instructions take precedence over this file.

## Identity and presentation

- Title: Meaning and Covariation in 300 Personality Items.
- Present the manuscript as a standalone unpublished research draft. Do not assign a journal, volume, or publication-series identity. The reproducibility archive is publicly released, with user authorization, as version 1.0.0 at https://github.com/DennyBorsboom/ipip-neo-300-embeddings-reproducibility/releases/tag/v1.0.0.
- Display these two byline lines in this order:
  - AI co-author: OpenAI Codex (GPT-6)
  - Prompter: Denny Borsboom
- Display “AI RESEARCH NOTE” as a generic document label in the masthead and running headers. Omit the red “RESEARCH NOTE · PRIVATE DRAFT” label.
- Omit the former journal subtitle and all journal framing, including in status text, metadata and references to prior private notes.
- Omit the year/volume/note/private-draft strip from the title page and page footers. Keep Note 7 in the project and file names.
- Keep the PDF metadata, Markdown source, LaTeX template, README and citation metadata consistent with these credits.
- Use APA author-date citations and verify scholarly references against primary sources.
- Cite Messick’s 1989 “Validity” book chapter alongside his 1995 article when discussing validity.
- The user authorized publication of the reproducibility archive on GitHub on 30 October 2026. This does not authorize journal submission or claim external review or a DOI. Further changes to the archive should preserve released tags and use a new version when appropriate.

## Reader and terminology

- Write for personality psychologists without assuming knowledge of embeddings or this conversation. Define unfamiliar concepts before using them, explain why each comparison matters, and distinguish correlations among item responses from agreement across item pairs.
- Distinguish semantic similarity (construct) from embedding correlations (operationalization). Use semantic similarity in the Introduction and Discussion, explain the operationalization in Methods, and report embedding correlations in Results. Explicitly define a zero-order embedding correlation as cosine similarity, an uncentered correlation, and a partial embedding correlation as residual-vector cosine. Preserve the exact model identifier and frozen vectors.
- Use italics, not boldface, for emphasis in the main text.
- Introduce linguistic relativity and its relevance before referring to the Sapir–Whorf hypothesis. The paper must establish its own motivation.
- Describe the final study directly. Remove references to drafting history, prior figure versions, or conversational decisions. Preserve scientific disclosure of analyses developed after inspecting the data, and retain historical decision logs.
- Explain calculations in ordinary language in the main text; keep matrix formulas and implementation details in Appendix A.
- Omit terminal periods inside item quotations in running prose. Preserve exact item content in analysis inputs and the item appendix. Place detailed item examples in Methods or Results; end the Introduction with a paper overview beginning “This paper is organized as follows.”

## Scientific requirements

- Analyze all 300 IPIP-NEO items using Johnson's public 20,993-protocol 2005 dataset. Primary complete-case N is 7,325; all 44,850 item pairs enter the matrix comparisons.
- Use bootnet for empirical network estimation and respondent bootstrapping. The custom semantic geometry estimator also runs through bootnet. Direct matrix calculations are independent validation checks.
- Retain exact source wording and full questionnaire numbers. The scoring workbook is not originally ordered by full item number.
- Source responses are already reverse scored: first convert zero to missing, then apply 6-x to negative-keyed items to match agreement with the embedded text.
- Preserve the frozen Jina request, response and vectors. Any new wording or model belongs to a separately documented analysis.
- Interpret inverse-Gram partial semantics as residual geometry. Embedding coordinates are not respondent observations; do not invent an inferential semantic sample size.
- Main scatterplots contain only zero-order/zero-order and partial/partial comparisons. Figure 1 uses absolute empirical correlations and embedding magnitudes. Figure 2 keeps empirical signs with the same horizontal measures and separate fitted curves by observed empirical sign. Retain cross comparisons in Table 1.
- Use descriptive quadratic fractional-logit curves to keep fitted mean absolute correlations between zero and one; no independent-pair significance tests or bands. Preserve curve coefficients and prediction grids. These data-informed fits are exploratory.
- All network figures must use identical saved node coordinates, node colors, sign colors and numerical edge-width mappings. Use the restored fixed domain/facet layout and domain labels; the user reverted the average spring layout after reviewing it. The current display shows the strongest 449 absolute edges per graph; this filter does not alter the statistical comparisons.
- The current paper and portable archive focus on correlations. Omit retired discrimination analyses, their code, cached summaries, figures and outputs. Preserve previous versions outside the active archive. Treat partial-network bootstrap percentile ranges as diagnostics because they are shifted below the observed estimate.
- Document result-driven additions in the decision log. Distinguish lexical overlap, shared meaning, behavioral traits and causal claims.

## Project structure and edits

In the full project, `editorial/manuscript_template.md` and `editorial/build_manuscript.py` generate `manuscript/source.md` from verified result tables. The LaTeX house design is `manuscript/journal_template.tex`. Regenerate `manuscript/main.tex` with Pandoc after source or template changes.

The standalone reproducibility ZIP opens directly onto `run_all.R`, `analysis/`, `inputs/`, `results/`, `figures/` and this file. In the full project these are under `reproducibility/`.

Run from the reproducibility root:

```sh
Rscript run_all.R --verify
Rscript run_all.R
```

The first command independently verifies frozen results. The second imports inputs, re-estimates networks, reuses included bootstrap checkpoints, recalculates comparisons and regenerates figures. The original analysis executed 500 bootnet respondent resamples per empirical network. To deliberately draw fresh bootstrap samples, preserve then move the checkpoint files and follow README.md. Do not rerun expensive analyses merely for typography or byline changes.

## Delivery checks

- Compile the manuscript with pdfLaTeX twice; render and inspect all final PDF pages.
- Keep the PDF, Overleaf ZIP, reproducibility ZIP and Markdown source synchronized.
- Use the filename prefix `AI_Research_Notes_Note_07` and place final artifacts in `deliverables/`, with copies in the top-level `AI_Research_Notes/` folder.
- Keep this AGENTS.md in the project root and in the reproducibility ZIP.
- Test a fresh extraction after changing a package. Metadata-only changes need compilation and verification checks, not a second full statistical run.
- Exclude the original SPSS demographics from the portable archive; include the anonymous 300-column item-response input. Exclude secrets, temporary QA images and LaTeX compilation debris from ZIPs.
- Record what was executed and checked in `editorial/`. Preserve full historical logs in editorial backups. Any shortened record in the portable archive must explicitly identify itself as retrospective and document the scope change.
