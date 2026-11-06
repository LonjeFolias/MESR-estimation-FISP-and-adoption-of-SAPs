# Farm input subsidies and sustainable agricultural practices in Malawi

Replication code for the study of FISP participation, sustainable agricultural practice (SAP) adoption, maize productivity and household food security in Malawi. The analysis uses IHS5 household and agricultural modules with CRU climate data.

**Code author:** Lonjezo Erick Folias · **Contact:** lonjefolias@hotmail.com

The four mutually exclusive regimes are FISP only (1), SAPs only (2), FISP + SAPs (3), and neither (4, the reference). Objective 1 uses multinomial probit estimates and marginal effects to describe regime choice. The MESR uses a multinomial logit first stage and regime-specific outcome equations with selection corrections. Outcomes are maize productivity, HDDS and FCS.

## Start here

1. Clone this repository and open `00_master-dofile.do` in Stata.
2. Set `projectfolder` to the local data/results project and `github` to the **parent directory containing this repository clone**.
3. Choose the stages in Part 2 of the master, then run the whole master file.

The supplied switches are **cleaning = 0, estimation = 0, presentation export = 1**. This is an export-only rerun using completed estimation results. For a full run, set all three to 1. For estimation from already cleaned data, use 0 / 1 / 1.

```stata
global projectfolder "C:/path/to/AERC 2026"
global github        "C:/path/to/GitHub"
```

## File sequence

| File | Role | Run it yourself? |
|---|---|---|
| `00_master-dofile.do` | Paths and stage switches | Yes: entry point |
| `do-files/01_data_cleaning.do` | Construct the cleaned analysis data | Through master |
| `do-files/02_expenditure.do` | Household expenditure helper | Called by cleaning |
| `do-files/03_ihsvclimate.do` | Match CRU rainfall and temperature to households | Called by cleaning |
| `do-files/04_labels.do` | Variable labels | Called by cleaning |
| `do-files/06_selmlog.do` | Bundled reference implementation of `selmlog` | Not called by current MESR workflow |
| `do-files/07_MESR_main.do` | Descriptives, models, diagnostics, Word and saved table inputs | Through master |
| `do-files/07_MESR_programs.do` | MESR, Word and LaTeX helper programs | Called by main estimation |
| `do-files/08_export_presentation.do` | Overleaf-ready table fragments and figures | Through master, after completed estimation |

Numbered helpers are dependencies, not separate stages to run in numerical order.

## Data and software

Use Stata 17 or later for the full workflow. Cleaning uses `winsor2` and `zscore`; install these before a clean-from-raw run. The master's optional installation block remains disabled. The MESR and presentation-export stages use built-in Stata commands.

| Local folder | Required contents |
|---|---|
| `data/01_raw/ihs/MWI_2019_IHS-V_v06_M_Stata` | IHS5 source modules and official conversion factors |
| `data/01_raw/weather` | Prepared `cru_pre_2.dta` and `cru_tmp_2.dta` climate inputs |
| `data/02_workingfiles` | Working datasets and `final esr data.dta` |
| `result` | Completed estimation results and exports |

Create the data, working and result folders before running. Survey microdata are obtained separately under the data provider's access conditions; they are not committed here. See the [IHS5 catalogue](https://microdata.worldbank.org/catalog/3818).

The climate helper retains the supplied setting `runningscript_firsttime "NO"`, which uses the prepared climate `.dta` files. To prepare these from `cru_pre_2.csv` and `cru_tmp_2.csv`, set that local to the case-sensitive value `"Yes"` for the first climate run, then return it to `"NO"`. This preprocessing can be slow.

## Results and presentation workflow

The estimation input is **`final esr data.dta`**, saved by the cleaner in **`data/02_workingfiles/`**. The main file reads `$data/final esr data.dta`, with `$data` defaulting to `$workingfiles`. You do not need to supply a separate estimation-sample dataset. The estimation file applies its sample checks to the final cleaned data and saves its own analysis outputs.

Principal outputs:

- `$result/MESR_tables_10_15.docx`: Word results.
- `$result/MNP_10_15.ster`, `MNL_10_15.ster`, `MESR_main_trap_10_15.ster`: saved models.
- `$result/latex/data/table_*.dta`: exact formatted table cells and metadata.
- `$result/latex/export_complete.txt`: completed-main-export marker.

`08_export_presentation.do` reads those saved table cells. It does **not** estimate a model, change the sample, recompute effects, or recompute significance stars. By default it writes to `$result/latex`; optionally set `$presentation` to an existing local Overleaf-project folder before running it.

Upload the generated **`tables/` and `figures/`** folders into the Overleaf project and recompile `main.tex`. Filenames match the current deck, including `objective1_summary.tex`, `eproductivitywinsr.tex`, `eHDDS.tex`, `eFCS.tex`, `regime_distribution.pdf`, `att_atu_ate_summary.pdf` and `Fig2_outcomes_10_15.png`. Keep the existing slide source, theme and conceptual-framework figure.

The effects overview retains regime bands, tinted ATT/ATU/ATE columns, a red zero reference, significance stars and a distinct colour for the largest point estimate within each outcome. Detailed effects tables retain the definitions beneath the table, bold ATE rows and spacing between regime groups. Footer definitions are controlled by the presentation's preamble, not by the exporter.

See [the output map](docs/PRESENTATION_EXPORTS.md) and [file guide](docs/FILE_GUIDE.md). The selected MNP table shows rows significant at 5% in at least one regime, retaining all three regime coefficients and reference-category labels; the full MNP table remains available for the annex.

## Version and verification

This update installs the author's final working source files. Outside `08_export_presentation.do`, executable edits are limited to filename references. Repository checks verify that preservation and the dependency/output map. Native Stata execution has not been repeated in this update; numerical reproduction requires running the supplied workflow with the author's matching inputs and Stata installation.

Earlier code is retained under `legacy/` for historical reference and is not part of the active execution sequence. Git history records previous repository versions.
