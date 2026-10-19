# Verification of documentation changes

19 October 2026.

All eight active scripts retain their executable lines after removing comments and reversing only the allowed call-filename substitutions. Executable labels, tables and graph commands are included in the comparison.

| Active file | Executable lines compared | Result |
|---|---:|---|
| `00_master-dofile.do` | 31 | Preserved |
| `do-files/01_data_cleaning.do` | 675 | Preserved |
| `do-files/02_MESR_main.do` | 733 | Preserved |
| `do-files/02.1_MESR_programs.do` | 276 | Preserved |
| `do-files/03_graphs.do` | 136 | Preserved |
| `do-files/01.1_expenditure.do` | 111 | Preserved |
| `do-files/01.2_ihsvclimate.do` | 270 | Preserved |
| `do-files/01.3_var_labels.do` | 123 | Preserved |

All five archived do-files are byte-identical to their pre-update repository sources. README relative file links resolve.

## Calls checked

| Caller | Dependency | Status |
|---|---|---|
| `00_master-dofile.do` | `01_data_cleaning.do` | Present |
| `00_master-dofile.do` | `02_MESR_main.do` | Present |
| `do-files/01_data_cleaning.do` | `01.1_expenditure.do` | Present |
| `do-files/01_data_cleaning.do` | `01.2_ihsvclimate.do` | Present |
| `do-files/01_data_cleaning.do` | `01.3_var_labels.do` | Present |
| `do-files/01_data_cleaning.do` | `004_labels.do` | Required local file, not supplied |
| `do-files/02_MESR_main.do` | `02.1_MESR_programs.do` | Present |

## Limit

Stata was not available for a native run. These checks establish code preservation and package references; they do not establish a successful data run, dependency compatibility or econometric validity. The required `004_labels.do` remains missing.
