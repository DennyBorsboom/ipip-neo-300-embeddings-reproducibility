# Current analysis design

This is a retrospective account of the analysis reported in the current draft, updated 30 September 2026. It is not a preregistration or a replacement claim about what was specified before results were known. The complete original design and the pre-revision archive are preserved separately in the working project's `editorial/before_construct_revision` folder. The portable archive now focuses on correlations.

## Planned data and estimates

Use all 300 IPIP-NEO items from Johnson's 2005 OSF component sxeq5, with 20,993 records. Sort the author's key by full item number before matching i1:i300. Preserve exact text. Convert zeros to missing before undoing source reverse scoring (6-x for negative-keyed items). Primary analysis uses 7,325 complete respondents; pairwise respondent inclusion and Spearman empirical networks are planned sensitivities.

All empirical estimation and respondent resampling run through bootnet. Primary networks use default cor and pcor, Pearson, listwise deletion, and threshold zero. Partial correlations control for the other 298 items. Freeze the locally generated 1,024-dimensional vectors, model identifier, exact request and response. Cosine similarity is the uncentered embedding correlation. An inverse-Gram custom bootnet estimator yields residual-vector cosine for the partial measure. Embedding coordinates are not an inferential sample of respondents.

Check rank and eigenvalues. Use the ordinary inverse if the minimum eigenvalue exceeds 1e-8; otherwise report the limitation and use an explicitly identified ridge fallback of .01. Also report .01, .05, and .10 ridge sensitivities and coordinate-mean centering. The observed primary matrix needed no repair.

## Planned comparisons and resampling

All 44,850 unordered pairs enter the four signed empirical/embedding comparisons. Preserve Pearson and Spearman summaries, domain/facet/key groups, and adjustment for facet-pair and key-product averages. Use two-sided QAP with 4,999 item-label permutations (seed 72902); adjusted QAP shuffles within facet and key strata (seed 72903). No independent-edge p-values.

Use 500 nonparametric bootnet respondent samples per empirical network, retaining every edge estimate. Seeds are 72901 plus each batch's starting replicate. Hold the items and embedding matrices fixed. After observing that partial-network bootstrap agreement was systematically below the original estimate, interpret percentile ranges as diagnostics rather than calibrated confidence intervals.

## Exploratory comparisons and current presentation

Magnitude summaries, separation by observed empirical sign, and the bounded quadratic curves were developed after inspecting the empirical/embedding associations. They are exploratory. Figures 1 and 2 now show only matched zero-order/zero-order and partial/partial measures. Table 1 retains the cross comparisons. This presentation choice was made after results were known.

Figure 1 uses |R| versus S and |P| versus |Q|; S is positive for every observed pair. Figure 2 keeps the same horizontal measures and retains empirical signs. Fit quadratic fractional-logit means for the absolute empirical correlations, pooled and within each observed sign group. Plot the negative group's fitted values below zero. Fit all pairs equally, restrict curves to observed predictor ranges, and do not report independent-pair standard errors or significance tests.

The four networks reuse one fixed layout grouped by domain and facet, with identical colors and weight scales. Show the strongest 449 absolute edges per panel for display only. Export complete matrices and retain all 300 nodes. The general construct is semantic similarity; the numerical operationalization is embedding correlation. The data do not distinguish effects of meaning on ratings from real behavioral regularities, item selection, or model exposure to personality content.
