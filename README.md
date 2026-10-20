# Farm input subsidies and sustainable agricultural practices in Malawi

Stata research code for **Farm input subsidies (FISP) and adoption of sustainable agricultural practices in Malawi: synergies and implications on farm productivity and household resilience to food shocks**.

The study examines FISP participation and adoption of sustainable agricultural practices among maize-growing households. It profiles four regimes, studies their determinants, and estimates regime-specific outcomes and counterfactual comparisons for maize productivity and household food security.

**Author:** Lonjezo Erick Folias  
**Contact:** lonjefolias@hotmail.com

## Replication status — 20 October 2026

**Not yet validated by a full Stata execution or a numerical comparison with the report.**
The original final-label dependency `004_labels.do` is still required. Cleaning now stops immediately if it is absent, before modifying datasets.

A source audit found and repaired two support-script incompatibilities: the earlier keep-list discarded maize/coordinate fields needed later, and the climate merge referenced an undefined temporary-file macro. No outcome formulas, samples, instruments, bootstrap settings, treatment-effect formulas or estimation tables were edited. See [the follow-up audit](docs/AUDIT_2026_10_20.md).

The supplied estimation source writes `10_15` results. The available reference report is `MESR_results_main_10_10.docx`; exact equality has not been established. Use the data, source files and report from the same run before claiming replication.

## Regimes and Research design

| Code | FISP | SAP adoption | Regime |
|---|---|---|---|
| 1 | Yes | No | FISP only |
| 2 | No | Yes | SAPs only |
| 3 | Yes | Yes | FISP and SAPs |
| 4 | No | No | Neither — reference category |

SAP adoption in the active cleaner covers six soil and water conservation practices: box/tied ridges, erosion-control bunds, vetiver, planting pits, terraces and water-harvesting bunds. Outcomes are maize productivity, the dietary diversity measure stored as `HDDS`, and the Food Consumption Score (`FCS`). The title does not imply that these scripts directly estimate dynamic resilience to shocks.

The estimation workflow includes:

1. Regime profiles and unconditional outcome differences.
2. **Determinants:** Multinomial probit participation equations and average marginal effects; a separate multinomial logit supplies the MESR selection correction.
3. **Second stage:** Regime-specific continuous-outcome regressions with **DMF(0) correction** for **multinomial endogenous switching regression (MESR)**.
4. ATT, ATU, ATE, heterogeneity measures and coupled-versus-standalone comparisons.
5. Excluded-variable relevance/falsification tests and probability-overlap diagnostics.

The descriptive probit and MESR logit first stage have different roles. The current helper is bundled; the active main file does not call archived `selmlog`. The current excluded variables are extension-officer distance above 5 km and radio advice on pit planting; including them in the code does not itself establish exclusion validity.

## File sequence

| Stage | File | Execution |
|---|---|---|
| **00** | [`00_master-dofile.do`](00_master-dofile.do) | Set paths and choose stages. Main entry point. |
| **01** | [`01_data_cleaning.do`](do-files/01_data_cleaning.do) | Constructs the analysis data. Called by the master. |
| 01.1 | [`01.1_expenditure.do`](do-files/01.1_expenditure.do) | Called inside cleaning; do not run independently. |
| 01.2 | [`01.2_ihsvclimate.do`](do-files/01.2_ihsvclimate.do) | Called inside cleaning; do not run independently. |
| 01.3 | [`01.3_var_labels.do`](do-files/01.3_var_labels.do) | Construction/labels/codebook helper called inside cleaning. |
| **02** | [`02_MESR_main.do`](do-files/02_MESR_main.do) | Estimation and Word results. Loads 02.1 automatically. |
| **02.1** | [`02.1_MESR_programs.do`](do-files/02.1_MESR_programs.do) | Program definitions; not an independent analysis. |
| **03** | [`03_graphs.do`](do-files/03_graphs.do) | Optional alternative distribution figures. |

**The supplied master runs cleaning only. Installation and estimation remain switched off.** Decimal numbering identifies helpers, not an instruction to run all files in sorted order.

## Setup

### Local paths

Clone the repository. In the user-1 block of the master, update:

```stata
global projectfolder "C:/path/to/AERC 2026"
global github        "C:/path/to/GitHub"
```

`github` is the **parent directory containing the clone** named `MESR-estimation-FISP-and-adoption-of-SAPs`, not the clone itself. The master constructs `$dofiles` from it. Only user 1 currently has an implemented path block.

| Project path | Contents |
|---|---|
| `data/01_raw/ihs/MWI_2019_IHS-V_v06_M_Stata` | Raw IHS5 Stata modules and conversion factors. |
| `data/01_raw/weather` | CRU inputs including `cru_pre_2.csv` and `cru_tmp_2.csv`. |
| `data/02_workingfiles` | Working data, final analysis data and cleaning audits. |
| `data/03_final` | Defined by the master; the current cleaner actually saves the final analysis data in `02_workingfiles`. |
| `result` | Tables, graphs, estimates, logs and draws. |

Create working/result directories before cleaning; the master defines paths but does not create every directory. Raw data are not included. Obtain IHS5 and its documentation from the [NSO/World Bank catalogue](https://microdata.worldbank.org/catalog/3818), subject to the catalogue's access conditions.

### Required final labels file

**Full cleaning requires your existing `do-files/004_labels.do`.** The supplied cleaner calls it, but it was not attached or present in the repository. The call is preserved. Do not substitute `01.3_var_labels.do`: that is a different, earlier step. Until the actual final-label script is supplied locally, this is not a complete clean-from-raw replication bundle.

### Stata and commands

Use **Stata 17 or later** for the full pipeline: cleaning declares version 17. Main estimation, helpers and graphs declare version 16.

Cleaning calls user-written commands including `winsor2`, `zscore` and `iecodebook` from `iefieldkit`. Check/install these before running:

```stata
ssc install winsor2
ssc install zscore
ssc install iefieldkit
```

The master's older package list is preserved and disabled; it does not guarantee installation of all cleaning dependencies. Active MESR estimation/helper commands are built-in Stata commands.

## Running the workflow

### Cleaning and estimation

The master's execution section retains cleaning `if (1)` and estimation `if (0)`. When ready to estimate, change the **estimation** switch to `if (1)` and run:

```stata
do "C:/path/to/GitHub/MESR-estimation-FISP-and-adoption-of-SAPs/00_master-dofile.do"
```

To use an existing clean dataset, set the cleaning switch to `if (0)`. Then enable estimation in the master, or run the master to define paths and subsequently run:

```stata
do "$dofiles/02_MESR_main.do"
```

The main file uses `$data`, falling back to `$workingfiles` if `$data` is empty. It first looks for `final_esr_data.dta`, then `final esr data.dta`, the name saved by the cleaner. **If both exist, the underscore version takes precedence.** Ensure the intended file and `$data` are consistent.

The main file automatically loads `02.1_MESR_programs.do`. Supplied settings remain **500 bootstrap replications**, `rerun_bootstrap = 1`, and `effect_mode = "legacy"`. The update does not change estimation or treatment-effect calculations.

### Optional graphs

The main estimator already writes its distribution and overlap figures. For the alternative graph style, use its saved analysis sample:

```stata
do "$dofiles/03_graphs.do" "$result/MESR_analysis_sample_10_15.dta" "$result"
```

Or use an in-memory analysis sample with `regime` already defined:

```stata
do "$dofiles/03_graphs.do"
```

This exports PNG/PDF figures. It only appends to Word if a document is already open; it does not save its own Word report. Plotting the full clean dataset can produce a different sample from the estimation tables.

## Outputs

- **`$result/MESR_tables_10_15.docx`** — main/appendix tables and embedded figures.
- `Fig2_outcomes_10_15.png` and `Fig3_overlap_10_15.png` under `$result`.
- `$result/MESR_analysis_sample_10_15.dta` — estimation sample.
- `$result/MNP_10_15.ster`, `MNL_10_15.ster`, `MESR_main_trap_10_15.ster` — stored estimates.
- `$result/MESR_main_draws_10_15.dta` — bootstrap draws.
- `$workingfiles/final esr data.dta` and cleaning audit files.

Original `10_15` output suffixes are retained. See the [file guide](docs/FILE_GUIDE.md) for outputs and table numbering. A separate robustness driver referenced in the former header was not uploaded and does not run automatically.

## Documentation and historical versions

[`docs/FILE_GUIDE.md`](docs/FILE_GUIDE.md) explains file roles and dependencies. [`docs/DOCUMENTATION_CHANGES.md`](docs/DOCUMENTATION_CHANGES.md) records the source mapping and scope; [`docs/VERIFICATION.md`](docs/VERIFICATION.md) records preservation checks.

`legacy/` contains earlier repository source files, unmodified for reference. Do not mix them with the current workflow. The three numbered cleaning helpers come from the previous repository; their compatibility with the newly uploaded cleaner has not been verified by execution.

The 19 October 2026 update adds consistent headers, section comments, numbering and documentation. **Commands are preserved against each file's source, except references to renamed do-files. Executable variable labels, output tables and model settings are unchanged.** Older-versus-newer analysis differences come from the author's uploaded source versions.

Validation was static. Native Stata execution and econometric validation were not performed in this documentation update.
