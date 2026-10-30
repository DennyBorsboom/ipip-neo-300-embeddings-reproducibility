# Meaning and Covariation in 300 Personality Items

Reproducibility archive, version 1.0.1. AI co-author: OpenAI Codex (GPT-6); Prompter: Denny Borsboom. The accompanying manuscript is an unpublished research draft; no DOI or peer-review status is assigned.

## Download this version

Versioned release: https://github.com/DennyBorsboom/ipip-neo-300-embeddings-reproducibility/releases/tag/v1.0.1

Download `AI_Research_Notes_Note_07_Reproducibility.zip` from the release assets and unzip it to obtain the complete, ready-to-run folder. The ZIP contains the saved embeddings, anonymous item responses, all 1,000 bootstrap estimates, scripts, results, and figures. The adjacent `SHA256SUMS.txt` records its checksum. The same files are available in the tagged Git repository at https://github.com/DennyBorsboom/ipip-neo-300-embeddings-reproducibility/tree/v1.0.1.

The release identifies the computational materials, not a journal publication or external review.

## Documentation revision

Version 1.0.1 replaces AGENTS.md with instructions for independent agents to reproduce and inspect the analysis. The analysis code, inputs, saved bootstrap draws, numerical results, and figures are byte-identical to version 1.0.0, which is cited in the frozen manuscript. Version 1.0.0 remains available at its original release address.

## What this reproduces

Semantic similarity is the construct; embedding correlations operationalize it. A zero-order embedding correlation is cosine similarity, the uncentered correlation between two item vectors. A partial embedding correlation compares their residual vectors after accounting for the remaining items. These are compared with empirical zero-order and partial correlations estimated through bootnet.

The analysis uses all 300 IPIP-NEO items, 44,850 pairs, and 7,325 complete records from Johnson's public 20,993-protocol 2005 archive. This is component sxeq5 at https://osf.io/tbmh5/, rather than the larger 2014 dataset. The package includes exact item wording, frozen embedding requests and vectors, anonymous item responses, all 1,000 bootstrap edge vectors, permutation draws, result tables, and figures. No embedding model download or server is needed.

Original URLs and SHA256 hashes appear in `inputs/sources.csv`. The portable archive includes only the 300 numeric response columns, with no demographics or respondent identifiers. `source_items_scored.rds` preserves the original item coding, including missing-response zeros. The import script recreates responses in the direction of agreement with the displayed wording. The original SPSS file is retained in the working project but is unnecessary for this portable archive.

## Run

Required: R and the versions listed in `session-info/package_versions.csv`, particularly bootnet 1.9.1, qgraph, haven, readxl, jsonlite, digest, ggplot2, patchwork, data.table and xml2. Dependencies are not bundled. Once installed, reproduction requires no internet connection.

```sh
Rscript run_all.R --verify
Rscript run_all.R
Rscript run_all.R --serial
```

`--verify` independently checks the saved data, matrices, headline correlations, residual-vector projections, wording and keys, bootstrap counts, bounded curves, and shared network positions. It does not draw new bootstrap samples.

The full pipeline imports inputs, re-estimates networks through bootnet, reuses included bootstrap checkpoints, recalculates comparisons and both sets of 4,999 permutations, regenerates figures, and validates results. To draw fresh respondent samples, first move `results/raw/bootstrap_*.rds` outside the archive and rerun. Do not reuse checkpoints after changing the inputs, model, or software environment; treat that as a new analysis. `--serial` uses one worker, otherwise four workers are used for missing bootstrap batches. Changing worker counts can change random streams and hence bootstrap endpoints.

Allow several GB of RAM and about 1 GB of storage for unpacked files and temporary objects. A run using saved checkpoints is much faster than drawing 1,000 new respondent samples. The original bootstrap work took roughly 20 minutes on the development machine; runtime varies with hardware and worker count.

## Pipeline and files

1. `analysis/01_import.R`: source checks, item matching, independent questionnaire wording, response recoding, inclusion and embedding manifests.
2. `analysis/02_networks.R`: bootnet zero-order and partial networks; the custom embedding estimator; rank, pairwise, ridge, and coordinate-centering sensitivities. All retained matrices are in `results/raw/matrices.rds` and individual matrix CSVs.
3. `analysis/03_bootstrap.R`: 500 bootnet respondent resamples per primary empirical network, in batches of 50. Checkpoints store upper-triangle edge values, summary correlations, seed, warnings, and replicate IDs. Edge order is R's `which(upper.tri(matrix), arr.ind=TRUE)`. Embedding coordinates are never bootstrapped.
4. `analysis/04_compare.R`: signed and absolute-magnitude correlations, sign groups, item-label permutations, facet/key adjustment, numerical sensitivities, examples, and bounded quadratic curve fits.
5. `analysis/05_figures.R`: Figures 1–4 and individual network views. All four networks use identical domain/facet coordinates and plotting scales.
6. `analysis/06_validate.R`: independent numerical and source checks, recorded in `results/processed/validation.csv`.

`results/headline_results.csv` contains all four empirical/embedding combinations, including the cross comparisons retained in Table 1. Main figures focus on the matched zero-order/zero-order and partial/partial comparisons. `results/processed/edges.csv` contains all 44,850 pairs, exact wording, and matrix values. Machine-readable identifiers such as `semantic_cosine` retain their original names; they refer to measured embedding correlations.

Additional files include `sign_branch_results.csv`, `regional.csv`, `adjusted.csv`, `specifications.csv`, `example_pairs.csv`, `bootstrap_metrics.csv`, and `edge_uncertainty_cor.csv` / `edge_uncertainty_pcor.csv`. Curve coefficients are in `display_curve_parameters.csv`; the exact plotting grids are in `display_curve_predictions.csv`.

Seeds: respondent bootstrap 72901 plus the checkpoint starting index; unrestricted item-label permutations 72902; restricted permutations 72903. See `inputs/seeds.csv`.

## Reading the figures

Figure 1 uses absolute empirical correlations against zero-order embedding correlations (all positive here) or absolute partial embedding correlations. Figure 2 uses the same horizontal measures but retains empirical signs. Its groups are defined by observed empirical sign, not scoring key. Correlations printed in Figure 2 compare the horizontal measure with signed empirical values within each group. In particular, its partial panel uses the absolute embedding predictor; it differs from the fully signed agreement reported in Table 1.

Curves use `glm(y ~ x + I(x^2), family = quasibinomial(link = "logit"))`, with y the absolute empirical correlation. The inverse-logit transformation keeps predictions between zero and one. Figure 2 fits each empirical sign group separately and reflects the negative group's fitted means below zero. Curves cover only observed predictor ranges. No independent-pair significance tests or confidence bands are used. All pairs receive equal weight. The reported Pearson and Spearman correlations describe the observations and are not measures of the fitted curve's explanatory power.

Figure 3 displays the strongest 449 absolute connections per network, using identical item positions, node colors, sign colors and numerical width mappings. `network_layout.csv` saves positions; `network_display_edges.csv` saves displayed connections. The fixed domain/facet groups come from the questionnaire key. Figure 4 shows all matrix values. Display filtering never changes a statistical comparison.

## Interpretation and diagnostics

The source data were already reverse scored. Zero must become missing before applying 6-x to negative-keyed columns, so responses match the exact item wording. Complete cases are primary; pairwise inclusion is a sensitivity analysis.

Partial embedding correlations describe residual geometry. Coordinates are not respondents or an inferential sample size. The main inverse needed no ridge fallback. The pipeline does not silently repair a non-positive-definite empirical matrix. Polychoric analyses were not executed. Warnings from respondent estimation are preserved in checkpoint objects; failed validation stops the pipeline.

The partial-network agreement statistic shifts downward in the respondent bootstrap. Its central 95% ranges are therefore resampling diagnostics, not calibrated population confidence intervals. Bootstrap means, bias and SD are retained. Item-label permutations concern the planned signed comparisons, not the exploratory magnitude, sign-group, or curve analyses. Neither procedure addresses variation from choosing a different item set or model.

The current package focuses on correlations. The pre-revision archive and complete historical design logs are preserved separately in the working project's `editorial/before_construct_revision` folder. They are excluded from this portable package. `study-design.md` and `analysis-decisions.md` explicitly describe the current scope and which analyses followed inspection of the data.

## Source terms and citation

IPIP statements are public domain. Source datasets and author workbooks retain their original terms; access is documented by the author's repository and official IPIP data-source page. Jina model weights have their own license and are not included. The new manuscript, code, figures and result tables are offered under CC BY 4.0 in this archive; this does not relicense third-party inputs.

Suggested reference: OpenAI Codex (GPT-6), AI co-author; Borsboom, D., prompter. (2026). *Meaning and covariation in 300 personality items*. Reproducibility archive (Version 1.0.1). GitHub. https://github.com/DennyBorsboom/ipip-neo-300-embeddings-reproducibility/releases/tag/v1.0.1
