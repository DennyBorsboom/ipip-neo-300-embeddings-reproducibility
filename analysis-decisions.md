# Current scope and analysis decisions

This is a retrospective, shortened record for the correlation-focused archive, prepared 30 September 2026. The complete historical decision log, original design, previous scripts, figures, and complete archive are preserved in the working project's `editorial/before_construct_revision` folder. Retired analyses are excluded from the current portable archive; this record does not claim that the current presentation was specified before inspecting results.

## Data and computational provenance

- The user selected the 300-item IPIP-NEO and bootnet for network psychometrics. Johnson's 2005 OSF component supplies 20,993 records, rather than the larger 2014 archive.
- The scoring key begins with short-form items, so rows were sorted by full number before joining responses. Exact texts were checked against the author's printable questionnaire and scoring directions against an independent workbook.
- Source responses were already reverse scored. Zeros became missing before negative-keyed columns were transformed with 6-x. All primary estimates concern endorsement of the displayed statement.
- Missingness was inspected before empirical/embedding agreement. The primary complete-case N is 7,325. Pairwise respondent inclusion and rank correlations were planned sensitivities.
- Exact requests and 300 embedding vectors were saved. No further model generation was requested. The Gram matrix was full rank, so the primary inverse used no ridge repair.
- bootnet estimates both empirical networks, invokes the custom geometric estimator, and supplies 500 respondent resamples per empirical network. Twenty checkpoints preserve all 1,000 edge vectors, seeds, warnings and replicate IDs.
- Signed QAP uses 4,999 unrestricted and 4,999 facet/key-restricted permutations. Embedding coordinates are never treated as respondents.

## Decisions after results were inspected

- Partial-network agreement was systematically lower in bootstrap samples. Percentile ranges are reported as resampling diagnostics, with means and bias retained; no bias correction was applied.
- The user identified the positive and negative empirical branches. Magnitude comparisons and sign-specific summaries were developed after seeing this pattern and are exploratory.
- The user tried an average spring layout and then requested the previous fixed domain/facet layout. Current network panels use exactly those restored positions, with unchanged displayed edges and weight mappings.
- The user requested a distinction between semantic similarity as a construct and embedding correlations as its operationalization. Cosine remains the uncentered correlation; no estimator or frozen embedding was changed to implement the terminology.
- The current draft focuses on correlations. Main scatterplots retain only matched zero-order and partial comparisons; Table 1 retains cross comparisons. Previously included discrimination analyses, their output files, functions and cached summary columns have been removed. Their full previous version is preserved outside the active package.
- Figure 1 uses absolute empirical and embedding measures. Figure 2 uses the same horizontal measures, including |Q| for the partial panel, but keeps empirical signs. Its printed sign-group correlations are calculated using these displayed variables.
- Curvature and the lower bound at zero motivated quadratic fractional-logit fits. These were not prespecified. Fitted means stay between zero and one; coefficients and prediction grids are exported. No conventional significance tests or bands assume independent pairs.
- Saved bootstrap edge values and retained matrix values are checked against their pre-revision versions. Removing retired summary fields does not change a respondent draw.

## Document and reproducibility

The manuscript is a standalone private draft with AI co-author OpenAI Codex (GPT-6), followed by Prompter Denny Borsboom. The generic label is AI RESEARCH NOTE. Note 7 remains solely in folder and file names. Main-text emphasis uses italics. The Introduction and Discussion address semantic similarity; Methods define the operationalization, and Results report embedding correlations. The exact item appendix and all analysis inputs preserve source wording. The paper explains unfamiliar concepts for personality researchers, includes Messick (1989, 1995) and Markus and Borsboom (2013), and makes no claim to public preregistration, peer review or publication.


## 2026-09-30: Author-authorized public reproducibility archive

The user requested publication of the reproducibility archive on GitHub and insertion of its HTTP address in the paper. Version 1.0.0 contains the correlation-focused analysis and saved inputs and draws. The versioned release is https://github.com/DennyBorsboom/ipip-neo-300-embeddings-reproducibility/releases/tag/v1.0.0. No journal submission, DOI, or external peer-review claim is made. All numerical inputs, scripts, results and figures remain unchanged from the independently reproduced version.
