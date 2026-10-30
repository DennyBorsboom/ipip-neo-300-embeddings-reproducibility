# Reproducing Meaning and Covariation in 300 Personality Items

This file guides automated research assistants using this repository to reproduce the published analysis materials, inspect results, or develop a clearly identified extension. Read `README.md` for the study overview, `study-design.md` and `analysis-decisions.md` for the analysis history, and `LICENSE` and `inputs/sources.csv` for source terms and provenance.

## 1. Locate and preserve the analysis

The analysis root contains `run_all.R`, `analysis/`, `inputs/`, `results/`, `figures/`, and `session-info/`. In the GitHub repository these are at the root. In a submission folder, extract `AI_Research_Notes_Note_07_Reproducibility.zip` into a separate writable working directory. In the manuscript working project, use its `reproducibility/` directory. Run the commands below from the analysis root.

Record the archive version or Git commit before running anything. Keep an untouched copy of the downloaded archive and its checksum. Full reproduction overwrites derived results, figures, some derived inputs, and session information; run it in a working copy. Read-only submission snapshots should remain available for comparison.

## 2. Check the environment

- Use R with the packages listed in `session-info/package_versions.csv`: bootnet, qgraph, haven, readxl, jsonlite, digest, ggplot2, patchwork, data.table, and xml2.
- Inspect `session-info/sessionInfo.txt` for the original R version and platform. The reference analysis used R 4.6.0 and bootnet 1.9.1. Prefer the recorded package versions and document any differences; the repository does not provide an automatically restored package environment.
- Dependencies must be installed separately. Once they are available, the analysis uses the included files and requires no internet connection, embedding model download, API key, or model server.
- Allow several GB of memory and about 1 GB of storage for the unpacked analysis and temporary files. Preserve the original session records before a full run replaces them with the current environment.

## 3. Verify the saved results first

```sh
Rscript run_all.R --verify
```

Expected completion: `All 70 validation checks passed`. The command independently checks saved matrices, correlations, selected residual-vector projections, item wording and scoring keys, bootstrap counts, fitted curves, and common network positions. It writes `results/processed/validation.csv`. It does not re-estimate all networks or generate bootstrap samples, so report this as verification of saved results rather than a complete reproduction.

If a check fails, retain its name, values, error messages, and the R/package versions. Investigate the input or environment difference. Do not change expected values or numerical tolerances merely to obtain a passing result.

## 4. Reproduce the analysis from the supplied inputs

```sh
Rscript run_all.R
```

This executes `analysis/01_import.R` through `analysis/06_validate.R` in order: import and recode inputs; estimate networks; summarize respondent bootstrap draws; compare matrices and rerun permutations; regenerate figures; validate results. The included bootstrap checkpoints are reused. Missing checkpoints trigger new respondent resampling through bootnet.

```sh
Rscript run_all.R --serial
```

The serial option uses one worker for any missing bootstrap batches; the default is four. Capture the console output and inspect `results/processed/validation.csv` after completion. Network estimates, headline statistics and plotted data should agree within the tolerances in `analysis/06_validate.R`; image rendering can vary with the graphics environment.

## 5. Understand the inputs and estimators

- `inputs/source_items_scored.rds` contains 20,993 records and the original 300 numeric item columns. Zero indicates a missing response. The source has already reversed negative-keyed items: `01_import.R` first changes zeros to missing, then applies `6-x` to negative-keyed columns so responses indicate agreement with the displayed wording. Do not apply this transformation again to `inputs/responses_administered.rds`.
- The primary complete-case sample contains 7,325 respondents. All comparisons use the same 300 items and 44,850 distinct pairs. The scoring workbook must be sorted by full item number before matching response columns. Preserve exact item text and identifiers `I001` through `I300`.
- `inputs/embedding_request.json`, `inputs/jina_response.json`, and `inputs/jina_embeddings.rds` preserve the requests, response, and 300 by 1,024 vector matrix. Each request prefixes the exact item wording with `Document: `. Use these saved vectors for reproduction; new embeddings constitute a separate analysis.
- `analysis/common.R` defines the estimators. `fit_emp` calls bootnet's correlation and partial-correlation estimators. `fit_sem` calls `bootnet::estimateNetwork` with the custom `semantic_estimator`. That estimator computes cosine similarities from unit-length vectors, optionally applies `(1-ridge) * S + ridge * I`, and uses the inverse matrix for partial embedding correlations. It returns zero-diagonal connection matrices for network display.
- The primary cosine calculation does not subtract each vector's coordinate mean. Partial embedding correlations describe residual-vector geometry after adjustment for the other 298 items. Embedding coordinates are not respondents, an inferential sample size, or units to bootstrap.

## 6. Handle saved bootstrap draws correctly

`results/raw/bootstrap_cor_*.rds` and `bootstrap_pcor_*.rds` contain 20 batches of 50 draws: 500 respondent resamples for each empirical network. They include upper-triangle edge values, replicate identifiers, seeds, warnings, and summary measures. Edge order follows R's `upper.tri` matrix order. The two empirical networks are bootstrapped through bootnet; the embedding vectors stay fixed.

To generate fresh respondent samples, work in a separate copy, move all existing bootstrap checkpoints outside `results/raw/`, and rerun the full pipeline. Do not mix checkpoints from different inputs, item orders, estimators, or software environments. Bootstrap batch seeds are 72901 plus the starting replicate index; permutation seeds are 72902 and 72903. Worker counts and software versions can affect random streams. Report whether saved draws were reused or fresh draws were generated.

## 7. Locate and interpret the outputs

- `results/headline_results.csv`: all four empirical/embedding combinations. The `r` column describes signed agreement; `magnitude_r` describes agreement between absolute values. Matched magnitude Pearson correlations are approximately 0.377 for zero-order measures and 0.343 for partial measures; their Spearman correlations are approximately 0.303 and 0.046.
- `results/raw/matrices.rds` and `results/processed/matrix_*.csv`: complete empirical and embedding networks. The full run recreates `results/raw/bootnet_fits.rds`, which is omitted from the portable archive.
- `results/processed/edges.csv`: the 44,850 item pairs, wording, and connection values. Other files in this directory hold sign-group summaries, sensitivity analyses, bootstrap diagnostics, and permutation comparisons.
- `figures/`: the paper's figures. Figure 1 compares magnitudes for matched zero-order and partial measures. Figure 2 separates positive and negative empirical pairs using the same horizontal measures. Cross comparisons remain in the tables.
- `results/processed/display_curve_parameters.csv` and `display_curve_predictions.csv`: the descriptive quadratic fractional-logit curves. They keep predicted absolute correlations within zero and one. Item pairs share items; do not interpret ordinary independent-observation regression tests or bands as valid inference here.
- `results/processed/network_layout.csv` and `network_display_edges.csv`: shared node coordinates and displayed edges. Preserve identical positions, node colors, sign colors, and width mappings across all four network panels. The strongest 449 absolute edges per graph are displayed; all 44,850 pairs remain in numerical comparisons.

Treat partial-network bootstrap percentile ranges as diagnostics: they shift below the observed agreement statistic. Distinguish semantic similarity as a construct from embedding correlations as its operationalization, and do not infer causal or psychological conditional-independence claims from embedding geometry. The sign groups and fitted curves are exploratory.

## 8. Report reproduction and separate extensions

State the archive version or commit, commands executed, environment, whether checkpoints were reused, validation outcome, and any numerical differences or warnings. Compare against the original saved results before accepting overwritten outputs. Do not claim to have reproduced the analysis if only verification was run.

For extensions, use a separate branch or directory and document changes to data, item wording, model, estimator, inclusion rules, or plotting choices. Preserve the released inputs and outputs as the reference. Cite the archive and original data sources as described in `CITATION.cff` and `README.md`.
