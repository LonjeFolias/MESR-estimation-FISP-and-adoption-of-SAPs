******************************************************************************
*                                                                            *
*  Study: Farm input subsidies (FISP) and adoption of sustainable            *
*  agricultural practices in Malawi: synergies and implications on farm      *
*  productivity and household resilience to food shocks                      *
*                                                                            *
*  File: 03_graphs.do                                                        *
*  Role: Optional outcome distribution figures                               *
*  Author: Lonjezo Erick Folias                                              *
*  Email: lonjefolias@hotmail.com                                            *
*  Phone: 0992 888 003                                                       *
*  Documentation revision: 19 October 2026                                   *
*                                                                            *
*  Purpose: Draws labelled outcome distributions for the four FISP and SAP   *
*  participation regimes.                                                    *
*                                                                            *
*  Inputs: An in-memory regime sample, or a dataset path and output-folder   *
*  argument.                                                                 *
*                                                                            *
*  Outputs: Portrait and wide Fig1_outcomes_by_regime_Manda PNG and PDF      *
*  files, plus panel PNGs.                                                   *
*                                                                            *
*  Run order: Optional after estimation. Use its saved analysis sample for   *
*  consistent sample coverage.                                               *
*                                                                            *
*  Notes: This is an alternative distribution figure. The main estimation    *
*  script already produces its own figures. Graph commands are preserved.    *
*                                                                            *
******************************************************************************


******************************************************************************
**# PART 0: INPUTS AND GRAPH SETTINGS
******************************************************************************
version 16
set graphics on
args input out
local outcomes "$Y"
if `"`outcomes'"'=="" local outcomes "productivity_winsr HDDS FCS"
if `"`out'"'=="" local out "$result"
if `"`out'"'=="" local out "graph_results"
capture mkdir "`out'"
* Usage in memory: do "$dofiles/03_graphs.do"
* Usage with data: do "$dofiles/03_graphs.do" "<analysis data.dta>" "<results>"
preserve
if `"`input'"'!="" {
    use "`input'", clear
    capture drop regime
    clonevar regime=combined_fisp_saps
}
capture confirm variable regime
if _rc {
    di as error "Load your estimation sample with regime, or supply an input file."
    restore
    exit 111
}
assert inlist(regime,1,2,3,4) if !missing(regime)
* Check the FISP part of the mapping; never silently use mesr_regime.
capture confirm variable fisp
if !_rc assert fisp==inlist(regime,1,3) if !missing(regime,fisp)
foreach y of local outcomes {
    confirm numeric variable `y'
}
tempvar gpos original_order
gen long `original_order'=_n
gen byte `gpos'=cond(regime==4,1,cond(regime==1,2,cond(regime==2,3,4))) if !missing(regime)

******************************************************************************
**# PART 1: REGIME PANELS AND SUMMARY MARKS
******************************************************************************
local glist ""
local panel 0
foreach y of local outcomes {
    local ++panel
    local letter=char(64+`panel')
    local title : variable label `y'
    if "`title'"=="" local title "`y'"
    local unit "Outcome value"
    local tick "ylabel(, angle(horizontal) labsize(small) grid glcolor(gs15) glwidth(vthin))"
    if strpos("`y'","productivity") {
        local title "Maize productivity"
        local unit "kg per acre"
        quietly summarize `y' if !missing(`gpos'), meanonly
        local top=max(500,ceil(r(max)/500)*500)
        local tick "ylabel(, format(%9.0fc) angle(horizontal) labsize(small) grid glcolor(gs15) glwidth(vthin))"
    }
    if "`y'"=="HDDS" {
        local title "Household dietary diversity"
        local unit "Diversity proxy score (0-10)"
        local tick "ylabel(3(1)10, angle(horizontal) labsize(small) grid glcolor(gs15) glwidth(vthin)) yscale(range(2.8 10.2))"
    }
    if "`y'"=="FCS" {
        local title "Food Consumption Score"
        local unit "FCS points (0-112)"
        local tick "ylabel(, angle(horizontal) labsize(small) grid glcolor(gs15) glwidth(vthin))"
    }
    tempvar rank nobs xpos q1 q2 q3 avg left right mleft mright tag p10 p90 avglab labx
    * Deterministic rank spread: dots move left to right from low to high.
    * Ties are spread horizontally; their outcome values remain unchanged.
    sort `gpos' `y' `original_order'
    quietly by `gpos': gen long `rank'=_n if !missing(`y',`gpos')
    quietly by `gpos': egen long `nobs'=count(`y')
    quietly gen double `xpos'=`gpos'-.34+.68*(`rank'-.5)/`nobs' if !missing(`rank')
    foreach v in q1 q2 q3 avg left right mleft mright p10 p90 labx {
        quietly gen double ``v''=.
    }
    quietly gen str12 `avglab'=""
    quietly gen byte `tag'=0
    forvalues k=1/4 {
        quietly summarize `y' if `gpos'==`k', detail
        local n`k'=strtrim(string(r(N),"%9.0fc"))
        local Q1=r(p25)
        local Q2=r(p50)
        local Q3=r(p75)
        local MEAN=r(mean)
        local P10=r(p10)
        local P90=r(p90)
        quietly replace `p10'=`P10' if `gpos'==`k'
        quietly replace `p90'=`P90' if `gpos'==`k'
        local mfmt "%9.1f"
        if "`y'"=="HDDS" local mfmt "%9.2f"
        if strpos("`y'","productivity") local mfmt "%9.0f"
        quietly replace `avglab'="x̄=" + strtrim(string(`MEAN',"`mfmt'")) if `gpos'==`k'
        quietly replace `q1'=`Q1' if `gpos'==`k'
        quietly replace `q2'=`Q2' if `gpos'==`k'
        quietly replace `q3'=`Q3' if `gpos'==`k'
        quietly replace `avg'=`MEAN' if `gpos'==`k'
        quietly replace `left'=`k'-.22 if `gpos'==`k'
        quietly replace `right'=`k'+.22 if `gpos'==`k'
        quietly replace `mleft'=`k'-.36 if `gpos'==`k'
        quietly replace `mright'=`k'+.36 if `gpos'==`k'
        quietly replace `tag'=1 if `gpos'==`k' & `rank'==1
    }
    * One common design for all outcomes (grayscale): 10th-90th percentile
    * whisker, 25th-75th percentile box, median line, mean diamond with value.
    quietly replace `labx'=`gpos'+.21 if `tag'
    twoway ///
        (rspike `p10' `p90' `gpos' if `tag', lcolor(gs6) lwidth(medthin)) ///
        (rcap `p10' `p90' `gpos' if `tag', msize(large) lcolor(gs6) lwidth(medthin)) ///
        (rbar `q1' `q3' `gpos' if `tag', barwidth(.40) fcolor(gs13) lcolor(gs5) lwidth(medium)) ///
        (pcspike `q2' `left' `q2' `right' if `tag', lcolor(black) lwidth(thick)) ///
        (scatter `avg' `gpos' if `tag', msymbol(D) msize(medium) mcolor(gs3) mlcolor(white) mlwidth(thin)) ///
        (scatter `avg' `labx' if `tag', msymbol(none) mlabel(`avglab') mlabpos(3) mlabgap(*1) mlabcolor(gs2) mlabsize(small)), ///
        title("`letter'. `title'", size(medsmall) color(black) pos(11)) ///
        ytitle("`unit'", size(small)) xtitle("") ///
        xlabel(1 `""Neither" "(n = `n1')""' ///
               2 `""FISP only" "(n = `n2')""' ///
               3 `""SAPs only" "(n = `n3')""' ///
               4 `""FISP + SAPs" "(n = `n4')""', labsize(small) noticks) ///
        xscale(range(.5 4.5) noline) `tick' ///
        legend(off) graphregion(color(white) margin(small)) ///
        plotregion(color(white) margin(small)) ///
        scheme(s2mono) xsize(7.5) ysize(3.25) name(manda`panel', replace)
    * export the graph just drawn (it is the current graph) - no window lookup
    quietly graph export "`out'/Fig1_panel`panel'.png", replace width(2400)
    quietly graph export "`out'/Fig1_panel`panel'.pdf", replace
    local glist "`glist' manda`panel'"
    drop `rank' `nobs' `xpos' `q1' `q2' `q3' `avg' `left' `right' `mleft' `mright' `tag' `p10' `p90' `avglab' `labx'
}

******************************************************************************
**# PART 2: PORTRAIT AND WIDE FIGURE EXPORTS
******************************************************************************
* Portrait layout: readable at full text width in Word.
graph combine `glist', cols(1) xsize(7.5) ysize(10.5) ///
    imargin(2 2 2 2) graphregion(color(white) margin(small)) ///
    title("Outcome distributions by participation regime", size(medsmall)) ///
    note("Box: 25th-75th percentiles; black line: median; whiskers: 10th and 90th percentiles; diamond: mean (value shown)." ///
         "Unweighted descriptive distributions; n = households.", size(vsmall)) ///
    name(fig1_manda, replace)
graph export "`out'/Fig1_outcomes_by_regime_Manda.png", replace width(3000)
graph export "`out'/Fig1_outcomes_by_regime_Manda.pdf", replace
graph save "`out'/Fig1_outcomes_by_regime_Manda.gph", replace
* Also export a wide layout for slides / landscape pages.
graph combine `glist', rows(1) xsize(15) ysize(5.5) ///
    imargin(2 2 2 2) graphregion(color(white)) ///
    note("Box: 25th-75th percentiles; black line: median; whiskers: 10th-90th percentiles; diamond: x̄ (mean).", size(vsmall)) ///
    name(fig1_manda_wide, replace)
graph export "`out'/Fig1_outcomes_by_regime_Manda_wide.png", replace width(4500)
graph export "`out'/Fig1_outcomes_by_regime_Manda_wide.pdf", replace
restore

******************************************************************************
**# PART 3: OPTIONAL INSERTION INTO AN OPEN WORD DOCUMENT
******************************************************************************
* Append only if the caller has an active putdocx document.
capture putdocx paragraph, halign(center)
if !_rc {
    putdocx image "`out'/Fig1_outcomes_by_regime_Manda.png", width(6.3)
    putdocx paragraph
    putdocx text ("Figure 1. Outcome distributions by FISP and SAP participation regime. Boxes show the 25th-75th percentiles, black lines the median, whiskers the 10th and 90th percentiles, and diamonds the mean, with its value shown. Sample counts are outcome-specific. These are unadjusted descriptive distributions, not treatment effects.")
}
di as result "Saved Figure 1, wide version, individual panels, PDF and editable GPH in: `out'"
