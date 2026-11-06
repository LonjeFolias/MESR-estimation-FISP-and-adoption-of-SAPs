# Stata to Overleaf output map

All paths below are relative to `$presentation` (default `$result/latex`). Upload these output folders into the existing Overleaf project; do not replace its slide source or preamble.

| Output | Source | Current use |
|---|---|---|
| `tables/objective1_summary.tex` | Saved Table 5 coefficients, standard errors and stars | Objective 1, slide 14 |
| `tables/t1.tex` | Regime distribution | Annex A1 |
| `tables/t3.tex` | Descriptive statistics | Annex A2 |
| `tables/t4.tex` | Unconditional differences | Annex A3 |
| `tables/t5.tex` | Full MNP coefficients and marginal effects | Annex A4 |
| `tables/t6.tex` | Instrument diagnostics | Annex A5 |
| `tables/mproductivitywinsr.tex`, `mHDDS.tex`, `mFCS.tex` | MESR outcome equations | Annex A6, A8, A10 |
| `tables/eproductivitywinsr.tex`, `eHDDS.tex`, `eFCS.tex` | Saved ATT/ATU/ATE and heterogeneity tables | Slides 17–19 and Annex A7/A9/A11 |
| `tables/scalars.tex` | Regime counts and sample metadata | Sample macros for optional use in slide text |
| `figures/regime_distribution.pdf` | Table 1 counts | Slide 12 |
| `figures/Fig2_outcomes_10_15.png` | Copied main-run outcome distributions | Slide 13 |
| `figures/att_atu_ate_summary.pdf` | Saved effect-table cells | Slide 16 |
| `figures/overlap.png` | Copied main-run overlap figure | Available for diagnostics |
| `figures/objective1_marginal_effects.pdf` | Saved Table 5 marginal effects | Optional figure |

The exporter additionally writes other saved logical tables and the compatibility alias `outcome_distributions.png`. Table 2 is not inserted into the current deck.

The selected MNP table identifies sandy soil, good soil quality and North as reference categories. Marital status uses married as its base in the full model; those rows are absent from the selected table when none meets its significance rule.

Numbers, standard errors and stars come from the same saved table cells as the Word report. Layout controls do not change estimation. The overview uses point estimates; uncertainty remains available in the tables. Negative future estimates, if present, are displayed rather than clipped.

The exporter does not update numeric claims typed directly into slide text or redraw the paper's conceptual framework. After a changed estimation run, review those narrative claims, IV diagnostics and recommendations as well as replacing tables/figures.

`tables/export_status.txt` is set to COMPLETE only after required outputs have been written. Missing main-run inputs stop export. Run `07_MESR_main.do` to regenerate missing saved inputs before retrying the exporter.
