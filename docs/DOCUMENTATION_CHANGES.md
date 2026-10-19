# Documentation and file organisation update

Date: 19 October 2026.

Changes to Stata source are limited to comment headers, explanatory comments, navigation bookmarks, filenames and calls to renamed files. Executable labels, table strings, transformations, sample restrictions, covariates, instruments, model formulas, treatment effects, graphs, seeds, bootstrap settings and output filenames are preserved against their respective source files.

The uploaded cleaning and estimation scripts are newer than the former repository versions. Differences between those versions originate in the author's supplied files, not in econometric revisions made during this documentation update.

## Source mapping

| Source | Current path |
|---|---|
| Uploaded `00_master-dofile.do` | `00_master-dofile.do` |
| Uploaded `001_data_cleaning.do` | `do-files/01_data_cleaning.do` |
| Uploaded `07_MESR_main.do` | `do-files/02_MESR_main.do` |
| Uploaded `07_MESR_programs.do` | `do-files/02.1_MESR_programs.do` |
| Uploaded `graph.do` | `do-files/03_graphs.do` |
| Repository `02_expenditure.do` | `do-files/01.1_expenditure.do` |
| Repository `03_ihsvclimate.do` | `do-files/01.2_ihsvclimate.do` |
| Repository `04_var_labels.do` | `do-files/01.3_var_labels.do` |

The dynamic climate call now uses the `01.2_` prefix in place of `03_`; the active IHSnumber loop remains `ihsv`.

Each active file now states its study, author/contact, filename, role, purpose, inputs, outputs, execution order and dependencies. Header terminology distinguishes the descriptive multinomial probit from the multinomial-logit-based switching regression for continuous outcomes. The former “switching probit” description was corrected in comments only.

An old comment described winsorisation as occurring by EA, although its actual command uses `by(district)`. The comment now says district. The `cuts(0 95)` comment now describes no lower-tail percentile replacement rather than a literal zero floor. Neither command changed.

## Preserved settings

- Master installation off, cleaning on, estimation off.
- Bootstrap repetitions 500; rerun_bootstrap 1; effect_mode `legacy`.
- Existing output and cache names, executable labels and Word table content unchanged.

## Dependencies and limits

The cleaner calls `004_labels.do`, which was not attached, present in the repository or found by the connected-file search. Its call remains unchanged. No substitute or empty placeholder was created. Supply the author's actual file locally before full cleaning.

The expenditure, climate and intermediate labelling helpers are the pre-existing repository versions, renamed and documented without changing commands. Their compatibility with the newly supplied cleaner has not been verified by running Stata.

The master does not create every expected directory. Its installation block is disabled and its older command list does not include every cleaning dependency. README explains setup instead of changing executable setup behavior.

## Verification method

Source comparison removes comments, normalizes only the explicit do-file call renames and compares the remaining executable lines. Historical copies are checked byte-for-byte. File-reference checks distinguish the missing local `004_labels.do` from bundled dependencies.

No Stata installation was available for native execution. This verifies organization and preservation of supplied commands, not successful data replication or the scientific identification assumptions.
