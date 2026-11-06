# Verification

The November 2026 package uses the author's supplied final working do-files. Checks in `tools/check_package.py` compare executable cleaning/estimation/helper lines with those uploads, allowing only documented filename substitutions, and check active file links and required presentation export names.

The substantive exporter change adds the selected MNP table, exact current figure aliases, output validation, current reference labels and presentation styling. It reads completed model tables; it does not rerun estimation.

Stata is not installed in the update environment. These checks establish source preservation and package connections, not a new Stata execution or numerical equivalence of a fresh estimation run. Run the master with the matching project data in Stata to perform that validation. The supplied scripts retain their existing sample checks and logging.
