# Multinomial Endogenous Switching regression estimation

This repository provides a complete empirical framework to evaluate the synergistic effects of FISP participation and SAP adoption on:

•	Agricultural productivity

•	Food security outcomes (Food Consumption Score – FCS, and Household Dietary Diversity Score – HDDS)

The analysis is implemented using a Multinomial Endogenous Switching Regression (MESR) model to account for selection bias arising from households self-selecting into different treatment regimes.

## Overview

The codebase is organized around a replication-style workflow that:
1. prepares folder globals and project settings,
2. cleans and merges source data,
3. constructs variables,
4. estimates multinomial treatment-selection and MESR models, and
5. runs post-estimation instrument diagnostics.

## Research focus

The empirical setup evaluates four treatment regimes:
- FISP only
- SAPs only
- FISP + SAPs
- Neither FISP nor SAPs (reference category)

The main outcomes are:
- agricultural productivity,
- Food Consumption Score (FCS), and
- Household Dietary Diversity Score (HDDS).

## Repository structure

```text
.
├── 00_master-dofile.do
└── do-files/
    ├── 01_data_cleaning.do
    ├── 02_expenditure.do
    ├── 03_ihsvclimate.do
    ├── 04_var_labels.do
    ├── 05_model_estimation.do
    ├── 06_selmlog.do
    └── 07_post_estimation_test.do
```

### File guide

#### `00_master-dofile.do`
Main entry point. Sets project globals, defines user-specific local paths, and runs the main workflow scripts.

#### `do-files/01_data_cleaning.do`
Builds the analytical dataset from LSMS/IHS household and agricultural modules. Based on the script contents, it:

- constructs household-head characteristics,
- computes household composition and dependency measures,
- merges education, location, community, and shock data,
- builds food security indicators such as FCS and HDDS,
- merges expenditure aggregates from `02_expenditure.do`,
- prepares extension, credit, subsidy, land, and livestock variables, and
- saves intermediate working files.

#### `do-files/02_expenditure.do`
Constructs expenditure aggregates from multiple household consumption modules, including food, weekly non-food, monthly non-food, quarterly non-food, annual expenditures, durable goods, farm machinery, education, health, and housing.

#### `do-files/03_ihsvclimate.do`
Processes climate data derived from CRU time-series files. The script documentation notes restructuring precipitation and temperature data, creating climate variables, and aligning longitude/latitude structure with LSMS household geovariables.

#### `do-files/04_var_labels.do`
Appears to prepare regime-specific variables and supporting labels for the estimation stage.

#### `do-files/05_model_estimation.do`
Core estimation file. It:
- estimates a multinomial probit treatment-selection model,
- prepares a custom formatted multinomial probit results table with coefficients, standard errors, z-values, and marginal effects,
- calls the user-written `selmlog` routine for MESR estimation, and
- computes treatment-effect quantities such as ATT, ATU, and related heterogeneity terms.

#### `do-files/06_selmlog.do`
Contains the user-written `selmlog` program used to estimate the switching-regression framework.

#### `do-files/07_post_estimation_test.do`
Runs IV diagnostics after estimation. The file includes:
- a relevance test for excluded instruments in the treatment-selection equation,
- auxiliary regime-specific binary relevance checks,
- exclusion-restriction tests in the outcome equations, and
- stronger falsification checks among non-participants only.

## Data requirements

The repository does **not** include raw data. From the master and cleaning scripts, the code expects local access to:
- Malawi IHS/LSMS-style household and agricultural data,
- CRU-based climate data converted to CSV,
- a local working-data folder structure under a project directory, and
- a local clone path used to point Stata to the `do-files` folder.

Before running the code, update the user-specific path globals in `00_master-dofile.do` so that `projectfolder`, `github`, `rawdata`, `workingfiles`, `finaldata`, `weather`, and `dofiles` point to valid locations on your machine.

## Contact
**Lonjezo Erick Folias**  
Email: lonjefolias@hotmail.com

---

If you use this repository, cite the underlying paper/project and describe any local path or data adjustments you made for reproducibility.
