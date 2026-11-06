# File guide

Run the root master. It defines `$workingfiles`, `$result`, `$dofiles`, `$ihsv` and `$weather`, then executes enabled stages.

```text
00_master-dofile.do
  01_data_cleaning.do
    02_expenditure.do
    03_ihsvclimate.do
    04_labels.do (two label passes)
  07_MESR_main.do
    07_MESR_programs.do
  08_export_presentation.do
    reads completed result/latex/data/table_*.dta and main-run figures
```

The cleaner saves `data/02_workingfiles/final esr data.dta`; main estimation reads that exact filename. The reference `06_selmlog.do` is supplied separately and is not a dependency of `mesr_dmf` in the current helper.

Keep raw modules, conversion factors and climate inputs outside the repository. Preparation and estimation settings are in the final author-supplied sources. The master retains export-only execution by default. See the root README for stage combinations and first-run climate preparation.
