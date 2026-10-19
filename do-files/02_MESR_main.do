******************************************************************************
*                                                                            *
*  Study: Farm input subsidies (FISP) and adoption of sustainable            *
*  agricultural practices in Malawi: synergies and implications on farm      *
*  productivity and household resilience to food shocks                      *
*                                                                            *
*  File: 02_MESR_main.do                                                     *
*  Role: Main estimation and manuscript tables                               *
*  Author: Lonjezo Erick Folias                                              *
*  Email: lonjefolias@hotmail.com                                            *
*  Phone: 0992 888 003                                                       *
*  Documentation revision: 19 October 2026                                   *
*                                                                            *
*  Purpose: Profiles four regimes, estimates multinomial probit              *
*  determinants and MNL-based MESR with DMF(0) correction, and exports       *
*  tables and figures.                                                       *
*                                                                            *
*  Inputs: Clean analysis data, $data or $workingfiles, $result, and         *
*  02.1_MESR_programs.do.                                                    *
*                                                                            *
*  Outputs: $result/MESR_tables_10_15.docx, figures, analysis sample,        *
*  estimates, draws and log.                                                 *
*                                                                            *
*  Run order: Run after cleaning; loads 02.1_MESR_programs.do                *
*  automatically.                                                            *
*                                                                            *
*  Notes: Preserves B=500, rerun_bootstrap=1 and effect_mode=legacy.         *
*  Existing 10_15 output filenames are retained.                             *
*                                                                            *
******************************************************************************

version 16
clear all
set more off
set linesize 200

**********************************************************************
**# PART 0: Paths, settings and variable lists
**********************************************************************

if "$data"=="" & "$workingfiles"!="" global data "$workingfiles"
if "$data"=="" | "$result"=="" {
    di as error "Define globals data (or workingfiles) and result before running."
    exit 198
}
local codefolder "$dofiles"
if "`codefolder'"=="" local codefolder "`c(pwd)'"
capture mkdir "$result"
capture log close mesrlog
log using "$result/07_MESR_main_10_15.log", text replace name(mesrlog)



* Outcome-equation covariates (X), including age and age squared.
global X  age agesq gender educ hh_Size marital2 marital3 marital4 TLU_winsr ///
          shock off_farm avr_yearly_tmp2019 avr_yearly_pre2019          ///
          type2 type3 quality2 quality3 region2 region3 credit extension
* Excluded variables (Z): included in the selection equation only.
global Z  ext_far radio_sap_strict
* Outcomes, in the order discussed in the paper
global Y  productivity_winsr HDDS FCS

do "`codefolder'/02.1_MESR_programs.do"

**********************************************************************
**# PART 1: Data preparation
**********************************************************************

local input "$data/final_esr_data.dta"
capture confirm file "`input'"
if _rc local input "$data/final esr data.dta"
use "`input'", clear
isid case_id

* Regime without value labels: 1 FISP only, 2 SAPs only, 3 FISP + SAPs, 4 neither
gen byte regime = combined_fisp_saps
assert inlist(regime,1,2,3,4)
assert regime==1 if fisp==1 & saps==0
assert regime==2 if fisp==0 & saps==1
assert regime==3 if fisp==1 & saps==1
assert regime==4 if fisp==0 & saps==0

* Instruments
egen long ea_num = group(ea_id)
gen byte ext_far = dist_extension_km>5 if !missing(dist_extension_km)
label var ext_far "Extension officer more than 5 km away (1=yes)"

* Analysis sample: complete cases on everything used
egen byte nmiss = rowmiss($X $Z $Y regime)
count if nmiss>0
di as txt "Households dropped for missing values: " r(N)
keep if nmiss==0
drop nmiss
count
local Nall = r(N)
foreach k in 1 2 3 4 {
    quietly count if regime==`k'
    local N`k' = r(N)
    local Nf`k' = strtrim(string(r(N),"%9.0fc"))
}
local Nfall = strtrim(string(`Nall',"%9.0fc"))

*--- Short labels used in Tables 5, 8, 10, 12 and A1 ------------------
local ind = uchar(160)*3
local S_age                 "Age of HH head"
local S_agesq               "Age squared"
local S_gender              "Male HH head (1=yes)"
local S_educ                "Education (years)"
local S_hh_Size             "HH size"
local S_marital2            "`ind'Separated/divorced"
local S_marital3            "`ind'Widowed"
local S_marital4            "`ind'Never married"
local S_TLU_winsr           "TLU"
local S_shock               "Drought/flood shock (1=yes)"
local S_off_farm            "Off-farm activity (1=yes)"
local S_avr_yearly_tmp2019  "Temperature (°C)"
local S_avr_yearly_pre2019  "Rainfall (mm)"
local S_type2               "`ind'Loam"
local S_type3               "`ind'Clay"
local S_quality2            "`ind'Fair"
local S_quality3            "`ind'Poor"
local S_region2             "`ind'Central"
local S_region3             "`ind'Southern"
local S_credit              "Credit access (1=yes)"
local S_extension           "Extension advice (1=yes)"
local S_ext_far             "IV: Extension officer > 5 km (1=yes)"
local S_radio_sap_strict    "IV: SAP advice via radio (1=yes)"
* group heading inserted before these variables
local G_marital2 "Marital status (base: married)"
local G_type2    "Soil type (base: sandy)"
local G_quality2 "Soil quality (base: good)"
local G_region2  "Region (base: North)"

*--- Outcome labels ---------------------------------------------------
local O_productivity_winsr "Maize productivity (kg/acre)"
local O_HDDS               "HDDS (food groups)"
local O_FCS                "FCS (points)"
local T_productivity_winsr "maize productivity (kg/acre)"
local T_HDDS               "the Household Dietary Diversity Score"
local T_FCS                "the Food Consumption Score"
local R1 "FISP only"
local R2 "SAPs only"
local R3 "FISP + SAPs"
local R4 "Neither"

local STAR "***, **, * denote significance at the 1%, 5% and 10% levels."

tempname h
putdocx clear
putdocx begin, pagesize(A4) font("Times New Roman", 11)
putdocx paragraph, style(Title)
putdocx text ("Coupling FISP with SAPs in Malawi: tables and figures (replication output)")

local B = 500                 
local rerun_bootstrap = 1     
local effect_mode "legacy"    
**********************************************************************
**# PART 2: Objective (a) - profile of the regimes
**********************************************************************

*--- Table 1: distribution of regimes ---------------------------------
quietly tab fisp saps, chi2
local chi_fs  = strtrim(string(r(chi2),"%9.1f"))
local chi_fsp = cond(r(p)<0.001,"p < 0.001","p = " + strtrim(string(r(p),"%5.3f")))
quietly summarize hh_wgt
local Wtot = r(sum)
tempfile T1
postfile `h' str60 c1 str14 c2 str14 c3 str18 c4 str18 c5 str20 c6 using "`T1'", replace
post `h' ("Regime") ("FISP coupon") ("Uses ≥1 SAP") ("Households (N)") ("Sample share (%)") ("Weighted share (%)")
local RT4 "Neither (FISP0 SAPs0), j = 4"
local RT1 "FISP only (FISP1 SAPs0), j = 1"
local RT2 "SAPs only (FISP0 SAPs1), j = 2"
local RT3 "FISP + SAPs (FISP1 SAPs1), j = 3"
local F4 "No"
local F1 "Yes"
local F2 "No"
local F3 "Yes"
local S4 "No"
local S1 "No"
local S2 "Yes"
local S3 "Yes"
foreach k in 4 1 2 3 {
    quietly summarize hh_wgt if regime==`k'
    post `h' ("`RT`k''") ("`F`k''") ("`S`k''") ("`Nf`k''") ///
        (strtrim(string(100*`N`k''/`Nall',"%6.2f"))) (strtrim(string(100*r(sum)/`Wtot',"%6.2f")))
}
post `h' ("Total") ("") ("") ("`Nfall'") ("100.00") ("100.00")
postclose `h'
pub_table using "`T1'", name(t1) tnum("Table 1.") ///
    title("Distribution of households across the four FISP–SAPs regimes") ///
    note("Weighted shares use IHS5 household sampling weights. Association between FISP participation and SAP adoption: χ²(1) = `chi_fs', `chi_fsp'.")

*--- Table 2: definition of explanatory variables ----------------------
tempfile T2
postfile `h' str40 c1 str80 c2 str40 c3 using "`T2'", replace
post `h' ("Variable") ("Definition") ("Expected effect")
post `h' ("Age") ("Age of the household head (years); age squared also included") ("+ (rising then falling)")
post `h' ("Age squared") ("Square of age of household head") ("−")
post `h' ("Male head") ("1 if household head is male") ("± (FISP); + (SAPs)")
post `h' ("Education") ("Highest class attended by household head") ("+")
post `h' ("Household size") ("Number of household members (family labour)") ("+")
post `h' ("Marital status") ("Separated/divorced, widowed, never married (base: married)") ("±")
post `h' ("Livestock (TLU)") ("Tropical livestock units (wealth, liquidity)") ("± (FISP); + (SAPs)")
post `h' ("Drought/flood shock") ("1 if household experienced drought or flood") ("+ (SAPs)")
post `h' ("Off-farm activity") ("1 if household runs an off-farm enterprise/activity") ("±")
post `h' ("Temperature") ("Mean monthly temperature in 2019 (°C), CRU TS") ("±")
post `h' ("Rainfall") ("Mean monthly rainfall in 2019 (mm), CRU TS") ("±")
post `h' ("Soil type") ("Loam; clay (base: sandy)") ("+ (SAPs)")
post `h' ("Soil quality") ("Fair; poor (base: good), farmer-reported") ("+ (SAPs)")
post `h' ("Region") ("Central; Southern (base: Northern)") ("±")
post `h' ("Access to credit") ("1 if household borrowed/had access to credit") ("+")
post `h' ("Extension advice") ("1 if household received agricultural advice") ("+")
post `h' ("Extension officer > 5 km (IV)") ("1 if nearest extension officer lives > 5 km from community") ("± (selection equations only)")
post `h' ("SAP advice via radio (IV)") ("1 if SAP (pit-planting) advice received mainly via radio") ("+ for SAPs (selection equations only)")
postclose `h'
pub_table using "`T2'", name(t2) tnum("Table 2.") ///
    title("Definition of explanatory variables and hypothesised effects on participation") ///
    note(`"The same variables, excluding the two instruments (IV), enter the outcome equations. "+" and "−" denote expected positive and negative effects relative to the "neither" regime; "±" denotes an ambiguous expectation."')
* first column is left-aligned by pub_table; definitions are also left-aligned
putdocx table t2(.,2), halign(left)

*--- Table 3: characteristics by regime -------------------------------
local D_productivity_winsr   "Maize productivity (kg/acre)"
local D_HDDS                 "Household Dietary Diversity Score (0–10)"
local D_FCS                  "Food Consumption Score (0–112)"
local D_box_ridges           "SAP: box/tied ridges (1=yes)"
local D_erosion_control_bunds "SAP: erosion control bunds (1=yes)"
local D_vetiver              "SAP: vetiver grass (1=yes)"
local D_plating_pits         "SAP: planting pits (1=yes)"
local D_Terraces             "SAP: terraces (1=yes)"
local D_Water_harvest_bunds  "SAP: water-harvesting bunds (1=yes)"
local D_inorganic_fertilizer "Used inorganic fertilizer (1=yes)"
local D_Plot_Area            "Maize plot area (acres)"
local D_age                  "Age of household head (years)"
local D_agesq                "Age squared"
local D_gender               "Male-headed household (1=yes)"
local D_educ                 "Education of head (highest class)"
local D_hh_Size              "Household size (persons)"
local D_marital2             "Separated/divorced head (1=yes)"
local D_marital3             "Widowed head (1=yes)"
local D_marital4             "Never-married head (1=yes)"
local D_TLU_winsr            "Livestock (TLU)"
local D_shock                "Drought/flood shock (1=yes)"
local D_off_farm             "Off-farm activity (1=yes)"
local D_avr_yearly_tmp2019   "Mean monthly temperature, 2019 (°C)"
local D_avr_yearly_pre2019   "Mean monthly rainfall, 2019 (mm)"
local D_type2                "Soil type: loam (1=yes)"
local D_type3                "Soil type: clay (1=yes)"
local D_quality2             "Soil quality: fair (1=yes)"
local D_quality3             "Soil quality: poor (1=yes)"
local D_region2              "Central region (1=yes)"
local D_region3              "Southern region (1=yes)"
local D_credit               "Access to credit (1=yes)"
local D_extension            "Access to extension advice (1=yes)"
local D_ext_far              "Extension officer > 5 km away (1=yes)"
local D_radio_sap_strict     "SAP advice received mainly via radio (1=yes)"
local DG1 "Outcome variables"
local DV1 productivity_winsr HDDS FCS
local DG2 "SAP practices and input use"
local DV2 box_ridges erosion_control_bunds vetiver plating_pits Terraces Water_harvest_bunds inorganic_fertilizer Plot_Area
local DG3 "Household characteristics"
local DV3 age agesq gender educ hh_Size marital2 marital3 marital4 TLU_winsr shock off_farm
local DG4 "Farm and climate characteristics"
local DV4 avr_yearly_tmp2019 avr_yearly_pre2019 type2 type3 quality2 quality3
local DG5 "Location and institutions"
local DV5 region2 region3 credit extension
local DG6 "Excluded instruments"
local DV6 ext_far radio_sap_strict

tempfile T3
postfile `h' str60 v str22 all str22 r4 str22 r1 str22 r2 str22 r3 str10 p using "`T3'", replace
post `h' ("Variable") ("All") ("Neither") ("FISP only") ("SAPs only") ("FISP + SAPs") ("p-value")
local row = 1
local grows ""
forvalues g = 1/6 {
    post `h' ("`DG`g''") ("") ("") ("") ("") ("") ("")
    local ++row
    local grows `grows' `row'
    foreach v of local DV`g' {
        quietly summarize `v'
        local a = strtrim(string(r(mean),"%10.2f")) + " (" + strtrim(string(r(sd),"%10.2f")) + ")"
        foreach k in 4 1 2 3 {
            quietly summarize `v' if regime==`k'
            local m`k' = strtrim(string(r(mean),"%10.2f")) + " (" + strtrim(string(r(sd),"%10.2f")) + ")"
        }
        quietly regress `v' i.regime
        local pv = Ftail(e(df_m),e(df_r),e(F))
        local pv = cond(`pv'<0.001,"<0.001",strtrim(string(`pv',"%5.3f")))
        post `h' ("`D_`v''") ("`a'") ("`m4'") ("`m1'") ("`m2'") ("`m3'") ("`pv'")
        local ++row
    }
}
post `h' ("Observations") ("`Nfall'") ("`Nf4'") ("`Nf1'") ("`Nf2'") ("`Nf3'") ("")
postclose `h'
pub_table using "`T3'", name(t3) tnum("Table 3.") fsize(8) groups(`grows') ///
    title("Household, farm and outcome characteristics by regime, mean (standard deviation)") ///
    note("p-value: F-test of equality of means across the four regimes. SAP adoption is defined as use of at least one of the six practices listed.")

*--- Table 4: unconditional differences in outcomes --------------------
tempfile T4
postfile `h' str40 c1 str16 c2 str24 c3 str24 c4 str24 c5 using "`T4'", replace
post `h' ("Outcome") ("Mean, neither") ("FISP only − neither") ("SAPs only − neither") ("FISP + SAPs − neither")
foreach y of global Y {
    quietly regress `y' ib4.regime, vce(cluster ea_num)
    local base = strtrim(string(_b[_cons],"%10.2f"))
    forvalues k = 1/3 {
        fmt_b `=_b[`k'.regime]' `=_se[`k'.regime]' 2
        local d`k' "`r(c)' `r(s)'"
    }
    post `h' ("`O_`y''") ("`base'") ("`d1'") ("`d2'") ("`d3'")
}
postclose `h'
pub_table using "`T4'", name(t4) tnum("Table 4.") ///
    title("Unconditional differences in outcomes relative to non-participants") ///
    note("Differences from OLS regressions of each outcome on regime indicators, without controls; EA-clustered standard errors in parentheses. `STAR' These are raw associations that do not account for household characteristics or selection.")

*--- Figure 2: outcome distributions by regime ------------------------
* Grey box = 25th-75th percentile; whiskers = 10th-90th percentile;
* black line = median; diamond = mean, labelled x̄.
preserve
gen byte gpos = cond(regime==4,1,cond(regime==1,2,cond(regime==2,3,4)))
local glist ""
local panel 0
foreach y of global Y {
    local ++panel
    if `panel'==1 {
        local ttl "A. Maize productivity"
        local unit "kg per acre"
        local mf "%9.1f"
    }
    if `panel'==2 {
        local ttl "B. Household dietary diversity"
        local unit "Food groups (0-10)"
        local mf "%9.2f"
    }
    if `panel'==3 {
        local ttl "C. Food Consumption Score"
        local unit "FCS points (0-112)"
        local mf "%9.1f"
    }
    capture drop q1 q2 q3 p10 p90 avg lft rgt labx tag avglab
    foreach v in q1 q2 q3 p10 p90 avg lft rgt labx {
        quietly gen double `v' = .
    }
    quietly gen str20 avglab = ""
    quietly gen byte tag = 0
    forvalues k = 1/4 {
        quietly summarize `y' if gpos==`k', detail
        quietly replace q1  = r(p25)  if gpos==`k'
        quietly replace q2  = r(p50)  if gpos==`k'
        quietly replace q3  = r(p75)  if gpos==`k'
        quietly replace p10 = r(p10)  if gpos==`k'
        quietly replace p90 = r(p90)  if gpos==`k'
        quietly replace avg = r(mean) if gpos==`k'
        quietly replace avglab = "x̄ = " + strtrim(string(r(mean),"`mf'")) if gpos==`k'
        quietly replace lft = `k' - .22 if gpos==`k'
        quietly replace rgt = `k' + .22 if gpos==`k'
        quietly replace labx = `k' + .25 if gpos==`k'
    }
    * one row per regime is enough for plotting the summary marks
    quietly bysort gpos: replace tag = (_n==1)
    twoway ///
        (rspike p10 p90 gpos if tag, lcolor(gs6) lwidth(medthin)) ///
        (rcap p10 p90 gpos if tag, msize(medlarge) lcolor(gs6) lwidth(medthin)) ///
        (rbar q1 q3 gpos if tag, barwidth(.44) fcolor(gs13) lcolor(gs5) lwidth(medthin)) ///
        (pcspike q2 lft q2 rgt if tag, lcolor(black) lwidth(thick)) ///
        (scatter avg gpos if tag, msymbol(D) msize(medium) mcolor(gs3)) ///
        (scatter avg labx if tag, msymbol(none) mlabel(avglab) mlabpos(3) mlabgap(0) mlabcolor(black) mlabsize(small)), ///
        title("`ttl'", size(medsmall) color(black) pos(11)) ///
        ytitle("`unit'", size(small)) xtitle("") ///
        xlabel(1 `""Neither" "(n = `Nf4')""' 2 `""FISP only" "(n = `Nf1')""' ///
               3 `""SAPs only" "(n = `Nf2')""' 4 `""FISP + SAPs" "(n = `Nf3')""', labsize(small) noticks) ///
        xscale(range(.5 4.75)) ylabel(, angle(horizontal) labsize(small) grid glcolor(gs15)) ///
        legend(off) graphregion(color(white)) plotregion(color(white)) ///
        scheme(s2mono) name(fig2_`panel', replace)
    local glist `glist' fig2_`panel'
}
graph combine `glist', rows(1) xsize(14) ysize(4.6) graphregion(color(white)) ///
    note("Box: 25th–75th percentile; whiskers: 10th–90th percentile; black line: median; diamond: mean (x̄). Unweighted, N = `Nfall'.", size(vsmall))
graph export "$result/Fig2_outcomes_10_15.png", replace width(3000)
restore
putdocx paragraph, halign(center)
putdocx image "$result/Fig2_outcomes_10_15.png", width(6.3)
putdocx paragraph, halign(center)
putdocx text ("Figure 2. "), bold
putdocx text ("Distribution of maize productivity, HDDS and FCS by regime")

**********************************************************************
**# PART 3: Objective (b) - multinomial probit (Table 5)
**********************************************************************

mprobit regime $X $Z, baseoutcome(4) vce(cluster ea_num) iterate(100)
if e(converged)!=1 exit 430
estimates store MNP
estimates save "$result/MNP_10_15.ster", replace
local mnp_chi2 = strtrim(string(e(chi2),"%9.2f"))
local mnp_p    = strtrim(string(e(p),"%5.3f"))
local mnp_N    = strtrim(string(e(N),"%9.0fc"))
forvalues k = 1/3 {
    quietly estimates restore MNP
    quietly margins, dydx($X $Z) predict(pr outcome(`k'))
    matrix ME`k' = r(table)
}
quietly estimates restore MNP

tempfile T5
postfile `h' str60 v str18 c1 str12 d1 str18 c2 str12 d2 str18 c3 str12 d3 using "`T5'", replace
post `h' ("Variable") ("FISP only") ("") ("SAPs only") ("") ("FISP + SAPs") ("")
post `h' ("") ("Coef.") ("dy/dx") ("Coef.") ("dy/dx") ("Coef.") ("dy/dx")
local row = 2
local grows ""
foreach v in $X $Z {
    if `"`G_`v''"' != "" {
        post `h' ("`G_`v''") ("") ("") ("") ("") ("") ("")
        local ++row
        local grows `grows' `row'
    }
    forvalues k = 1/3 {
        fmt_b `=_b[`k':`v']' `=_se[`k':`v']' 4
        local c`k' "`r(c)'"
        local s`k' "`r(s)'"
        local cn = colnumb(ME`k',"`v'")
        local d`k' = strtrim(string(ME`k'[1,`cn'],"%9.4f"))
    }
    post `h' ("`S_`v''") ("`c1'") ("`d1'") ("`c2'") ("`d2'") ("`c3'") ("`d3'")
    post `h' ("") ("`s1'") ("") ("`s2'") ("") ("`s3'") ("")
    local row = `row' + 2
}
forvalues k = 1/3 {
    fmt_b `=_b[`k':_cons]' `=_se[`k':_cons]' 4
    local c`k' "`r(c)'"
    local s`k' "`r(s)'"
}
post `h' ("Constant") ("`c1'") ("") ("`c2'") ("") ("`c3'") ("")
post `h' ("") ("`s1'") ("") ("`s2'") ("") ("`s3'") ("")
post `h' ("Observations") ("`mnp_N'") ("") ("") ("") ("") ("")
post `h' ("Wald χ²") ("`mnp_chi2'") ("") ("") ("") ("") ("")
post `h' ("Prob > χ²") ("`mnp_p'") ("") ("") ("") ("") ("")
postclose `h'
pub_table using "`T5'", name(t5) tnum("Table 5.") headrows(2) fsize(8) ///
    groups(`grows') spans("1:6:2 1:4:2 1:2:2") ///
    title("Multinomial probit estimates of the determinants of regime choice (base: neither)") ///
    note("HH = household; TLU = tropical livestock units. Standard errors in parentheses. dy/dx = average marginal effect on the probability of the regime. IV = excluded instrument (enters the selection equation only). `STAR'")

* Age turning points (quoted in the text, Table A2)
capture nlcom (tp_saps: -_b[2:age]/(2*_b[2:agesq])) (tp_coupled: -_b[3:age]/(2*_b[3:agesq]))
if !_rc {
    matrix TP = r(b)
    local tp2 = strtrim(string(TP[1,1],"%6.1f"))
    local tp3 = strtrim(string(TP[1,2],"%6.1f"))
}

**********************************************************************
**# PART 4: Instrument tests (Table 6), overlap (Figure 3, Table 7)
**********************************************************************

mlogit regime $X $Z, baseoutcome(4) vce(cluster ea_num)
estimates store MNL
estimates save "$result/MNL_10_15.ster", replace

* relevance
local tst ""
foreach z of global Z {
    forvalues k = 1/3 {
        local tst `tst' ([`k']`z'=0)
    }
}
quietly test `tst'
local rel_chi2 = strtrim(string(r(chi2),"%9.2f"))
local rel_df   = r(df)
local rel_p    = strtrim(string(r(p),"%5.3f"))
foreach z of global Z {
    quietly test ([1]`z'=0) ([2]`z'=0) ([3]`z'=0)
    local rel_`z'_chi2 = strtrim(string(r(chi2),"%9.2f"))
    local rel_`z'_df   = r(df)
    local rel_`z'_p    = strtrim(string(r(p),"%5.3f"))
}

* predicted probabilities (used for Figure 3 and Table 7)
forvalues k = 1/4 {
    quietly predict double ps`k', outcome(`k')
}

* falsification among non-participants (Di Falco et al. 2011)
foreach y of global Y {
    quietly regress `y' $X $Z if regime==4, vce(cluster ea_num)
    quietly test $Z
    local fal_`y'_F = strtrim(string(r(F),"%9.3f"))
    local fal_`y'_p = strtrim(string(r(p),"%5.3f"))
}
local FT_productivity_winsr "maize productivity"
local FT_HDDS "HDDS"
local FT_FCS "FCS"

tempfile T6
postfile `h' str100 c1 str12 c2 str10 c3 using "`T6'", replace
post `h' ("Test") ("Statistic") ("p-value")
post `h' ("Relevance: both instruments jointly in the first-stage MNL, Wald χ²(`rel_df')") ("`rel_chi2'") ("`rel_p'")
post `h' ("Relevance: extension officer > 5 km away, Wald χ²(`rel_ext_far_df')") ("`rel_ext_far_chi2'") ("`rel_ext_far_p'")
post `h' ("Relevance: SAP advice via radio, Wald χ²(`rel_radio_sap_strict_df')") ("`rel_radio_sap_strict_chi2'") ("`rel_radio_sap_strict_p'")
foreach y of global Y {
    post `h' ("Falsification: instruments in the `FT_`y'' equation of non-participants, F") ("`fal_`y'_F'") ("`fal_`y'_p'")
}
postclose `h'
pub_table using "`T6'", name(t6) tnum("Table 6.") ///
    title("Tests of the excluded instruments") ///
    note(`"Relevance tests use EA-clustered standard errors. The falsification test (Di Falco et al., 2011) regresses each outcome on all covariates and the instruments among households in the "neither" regime; a large p-value indicates no direct association between the instruments and the outcome."')

*--- Figure 3: overlap of predicted probabilities ---------------------
preserve
keep ps1 ps2 ps3 ps4 regime
gen long id = _n
reshape long ps, i(id) j(panel)
label define pan 1 "Pr(FISP only)" 2 "Pr(SAPs only)" 3 "Pr(FISP + SAPs)" 4 "Pr(Neither)"
label values panel pan
twoway (kdensity ps if regime==4, lcolor(black) lpattern(solid) lwidth(medthick)) ///
       (kdensity ps if regime==1, lcolor(gs6)   lpattern(dash)  lwidth(medthick)) ///
       (kdensity ps if regime==2, lcolor(gs9)   lpattern(dash_dot) lwidth(medthick)) ///
       (kdensity ps if regime==3, lcolor(gs3)   lpattern(shortdash) lwidth(medthick)), ///
    by(panel, cols(2) xrescale yrescale note("") graphregion(color(white)) ///
       legend(position(6))) ///
    legend(order(1 "Actual regime: Neither" 2 "Actual regime: FISP only" ///
                 3 "Actual regime: SAPs only" 4 "Actual regime: FISP + SAPs") ///
           rows(1) size(small) region(lcolor(white))) ///
    xtitle("Predicted probability") ytitle("Density") ///
    subtitle(, size(medsmall) fcolor(white) lcolor(white)) ///
    xsize(10) ysize(7) scheme(s2mono)
graph export "$result/Fig3_overlap_10_15.png", replace width(2400)
restore
putdocx paragraph, halign(center)
putdocx image "$result/Fig3_overlap_10_15.png", width(6.0)
putdocx paragraph, halign(center)
putdocx text ("Figure 3. "), bold
putdocx text ("Distribution of the predicted probability of each regime by actual regime (first-stage multinomial logit)")

*--- Table 7: common support ------------------------------------------
tempfile T7
postfile `h' str30 c1 str20 c2 str20 c3 str20 c4 str20 c5 using "`T7'", replace
post `h' ("Predicted probability") ("Neither") ("FISP only") ("SAPs only") ("FISP + SAPs")
foreach k in 4 1 2 3 {
    foreach j in 4 1 2 3 {
        quietly summarize ps`k' if regime==`j'
        local r`j' = strtrim(string(r(min),"%5.3f")) + "–" + strtrim(string(r(max),"%5.3f"))
    }
    post `h' ("Pr(`R`k'')") ("`r4'") ("`r1'") ("`r2'") ("`r3'")
}
postclose `h'
pub_table using "`T7'", name(t7) tnum("Table 7.") ///
    title("Common support: range of predicted regime probabilities by actual regime") ///
    note("Minimum–maximum of each predicted probability (first-stage MNL) within each actual regime.")
drop ps1 ps2 ps3 ps4

**********************************************************************
**# PART 5: Objective (c) - MESR with DMF(0) selection correction
**********************************************************************

char _dta[mesr_X] "$X"
char _dta[mesr_Z] "$Z"
char _dta[mesr_Y] "$Y"
char _dta[mesr_effects] "`effect_mode'"
save "$result/MESR_analysis_sample_10_15.dta", replace
quietly estimates restore MNL
matrix MESR_start = e(b)

local loaded = 0
if !`rerun_bootstrap' {
    capture confirm file "$result/MESR_main_trap_10_15.ster"
    if !_rc {
        estimates use "$result/MESR_main_trap_10_15.ster"
        local loaded = 1
        di as result "Reusing saved MESR bootstrap results."
    }
}
if !`loaded' {
    bootstrap _b, reps(`B') seed(20261013) cluster(ea_num) ///
        saving("$result/MESR_main_draws_10_15.dta", replace): ///
        mesr_dmf, out($Y) x($X) z($Z) r(regime) start(MESR_start) effects(`effect_mode')
    estimates save "$result/MESR_main_trap_10_15.ster", replace
}
estimates store MESR
local Breps = e(N_reps)
if missing(`Breps') local Breps = `B'

**********************************************************************
**# PART 6: Tables 8-15
**********************************************************************

local OUTNOTE "HH = household; TLU = tropical livestock units. λ1–λ4 = selection-correction terms (Bourguignon et al., 2007) and ρ1–ρ4 = implied correlations between the outcome error and the choice error, for regime 1 (FISP only), 2 (SAPs only), 3 (FISP + SAPs) and 4 (neither); σ = standard deviation of the outcome error; “–” = not defined for the own regime. Standard errors (`Breps' EA-cluster replications of the full two-step procedure) in parentheses. `STAR'"
local ATTNOTE "Standard errors in parentheses. ATT = effect for households in the regime; ATU = effect the regime would have for current non-participants; ATE = effect for all households. BH1 and BH2 = base heterogeneity; TH = transitional heterogeneity (ATT − ATU). % change is relative to the counterfactual. `STAR'"

local tabno = 8
foreach y of global Y {
    local o = subinstr("`y'","_","",.)
    quietly estimates restore MESR

    *------------- second-stage outcome equations (landscape) ----------
    tempfile TM
    postfile `h' str60 v str20 c4 str10 z4 str20 c1 str10 z1 ///
                 str20 c2 str10 z2 str20 c3 str10 z3 using "`TM'", replace
    post `h' ("Variables") ("FISP0 SAPs0") ("") ("FISP1 SAPs0") ("") ///
             ("FISP0 SAPs1") ("") ("FISP1 SAPs1") ("")
    post `h' ("") ("Coef.") ("Z-value") ("Coef.") ("Z-value") ///
             ("Coef.") ("Z-value") ("Coef.") ("Z-value")
    local row = 2
    local grows ""
    foreach v of global X {
        if `"`G_`v''"' != "" {
            post `h' ("`G_`v''") ("") ("") ("") ("") ("") ("") ("") ("")
            local ++row
            local grows `grows' `row'
        }
        foreach j in 4 1 2 3 {
            fmt_b `=_b[`o'_r`j':`v']' `=_se[`o'_r`j':`v']' 4
            local c`j' "`r(c)'"
            local s`j' "`r(s)'"
            local z`j' "`r(z)'"
        }
        post `h' ("`S_`v''") ("`c4'") ("`z4'") ("`c1'") ("`z1'") ("`c2'") ("`z2'") ("`c3'") ("`z3'")
        post `h' ("") ("`s4'") ("") ("`s1'") ("") ("`s2'") ("") ("`s3'") ("")
        local row = `row' + 2
    }
    forvalues l = 1/4 {
        foreach j in 4 1 2 3 {
            local c`j' "–"
            local s`j' ""
            local z`j' ""
            if `l' != `j' {
                fmt_b `=_b[`o'_r`j':lam`l']' `=_se[`o'_r`j':lam`l']' 4
                local c`j' "`r(c)'"
                local s`j' "`r(s)'"
                local z`j' "`r(z)'"
            }
        }
        post `h' ("λ`l'") ("`c4'") ("`z4'") ("`c1'") ("`z1'") ("`c2'") ("`z2'") ("`c3'") ("`z3'")
        post `h' ("") ("`s4'") ("") ("`s1'") ("") ("`s2'") ("") ("`s3'") ("")
    }
    foreach j in 4 1 2 3 {
        fmt_b `=_b[`o'_r`j':_cons]' `=_se[`o'_r`j':_cons]' 4
        local c`j' "`r(c)'"
        local s`j' "`r(s)'"
        local z`j' "`r(z)'"
    }
    post `h' ("Constant") ("`c4'") ("`z4'") ("`c1'") ("`z1'") ("`c2'") ("`z2'") ("`c3'") ("`z3'")
    post `h' ("") ("`s4'") ("") ("`s1'") ("") ("`s2'") ("") ("`s3'") ("")
    foreach j in 4 1 2 3 {
        fmt_b `=_b[`o'_anc`j':sigma]' `=_se[`o'_anc`j':sigma]' 4
        local c`j' "`r(c)'"
        local s`j' "`r(s)'"
        local z`j' "`r(z)'"
    }
    post `h' ("σ") ("`c4'") ("`z4'") ("`c1'") ("`z1'") ("`c2'") ("`z2'") ("`c3'") ("`z3'")
    post `h' ("") ("`s4'") ("") ("`s1'") ("") ("`s2'") ("") ("`s3'") ("")
    forvalues l = 1/4 {
        foreach j in 4 1 2 3 {
            local c`j' "–"
            local s`j' ""
            local z`j' ""
            if `l' != `j' {
                fmt_b `=_b[`o'_anc`j':rho`l']' `=_se[`o'_anc`j':rho`l']' 4
                local c`j' "`r(c)'"
                local s`j' "`r(s)'"
                local z`j' "`r(z)'"
            }
        }
        post `h' ("ρ`l'") ("`c4'") ("`z4'") ("`c1'") ("`z1'") ("`c2'") ("`z2'") ("`c3'") ("`z3'")
        post `h' ("") ("`s4'") ("") ("`s1'") ("") ("`s2'") ("") ("`s3'") ("")
    }
    post `h' ("Observations") ("`Nf4'") ("") ("`Nf1'") ("") ("`Nf2'") ("") ("`Nf3'") ("")
    postclose `h'
    capture putdocx sectionbreak, landscape
    pub_table using "`TM'", name(m`o') tnum("Table `tabno'.") headrows(2) fsize(8.5) ///
        groups(`grows') spans("1:8:2 1:6:2 1:4:2 1:2:2") ///
        title("MESR second-stage estimates: determinants of `T_`y'' by regime") ///
        note("`OUTNOTE'")
    capture putdocx sectionbreak
    local ++tabno

    *------------- treatment effects ------------------------------------
    tempfile TE
    postfile `h' str20 c1 str30 c2 str18 c3 str20 c4 str26 c5 str10 c6 using "`TE'", replace
    post `h' ("Regime") ("Households") ("In regime j") ("In neither (j = 4)") ("Treatment effect") ("% change")
    forvalues j = 1/3 {
        local TR = _b[`o'_te:TR`j']
        local CF = _b[`o'_te:CF`j']
        local CU = _b[`o'_te:CU`j']
        local UA = _b[`o'_te:UA`j']
        fmt_b `=_b[`o'_te:ATT`j']' `=_se[`o'_te:ATT`j']' 2
        local att "`r(c)' `r(s)'"
        fmt_b `=_b[`o'_te:ATU`j']' `=_se[`o'_te:ATU`j']' 2
        local atu "`r(c)' `r(s)'"
        fmt_b `=_b[`o'_te:ATE`j']' `=_se[`o'_te:ATE`j']' 2
        local ate "`r(c)' `r(s)'"
        quietly lincom [`o'_te]TR`j' - [`o'_te]CU`j'
        fmt_b `r(estimate)' `r(se)' 2
        local bh1 "BH1 = `r(c)'"
        quietly lincom [`o'_te]CF`j' - [`o'_te]UA`j'
        fmt_b `r(estimate)' `r(se)' 2
        local bh2 "BH2 = `r(c)'"
        quietly lincom [`o'_te]ATT`j' - [`o'_te]ATU`j'
        fmt_b `r(estimate)' `r(se)' 2
        local th "TH = `r(c)'"
        local pct  = strtrim(string(100*(`TR'-`CF')/`CF',"%8.2f"))
        local pctu = strtrim(string(100*(`CU'-`UA')/`UA',"%8.2f"))
        post `h' ("`R`j''") ("Participants (ATT)") (strtrim(string(`TR',"%10.2f"))) (strtrim(string(`CF',"%10.2f"))) ("`att'") ("`pct'")
        post `h' ("") ("Non-participants (ATU)") (strtrim(string(`CU',"%10.2f"))) (strtrim(string(`UA',"%10.2f"))) ("`atu'") ("`pctu'")
        post `h' ("") ("Heterogeneity") ("`bh1'") ("`bh2'") ("`th'") ("")
        post `h' ("") ("All households (ATE)") ("") ("") ("`ate'") ("")
    }
    postclose `h'
    pub_table using "`TE'", name(e`o') tnum("Table `tabno'.") fsize(8.5) ///
        title("Average treatment effects of the regimes on `T_`y'' (reference: neither)") ///
        note("`ATTNOTE'")
    local ++tabno
}

*--- Table 14: coupled versus standalone ------------------------------
quietly estimates restore MESR
tempfile TC
postfile `h' str40 c1 str16 c2 str14 c3 str22 c4 str14 c5 str22 c6 using "`TC'", replace
post `h' ("Outcome") ("Actual (coupled)") ("If FISP only") ("Coupled − FISP only") ("If SAPs only") ("Coupled − SAPs only")
foreach y of global Y {
    local o = subinstr("`y'","_","",.)
    fmt_b `=_b[`o'_te:BvF]' `=_se[`o'_te:BvF]' 2
    local bvf "`r(c)' `r(s)'"
    fmt_b `=_b[`o'_te:BvS]' `=_se[`o'_te:BvS]' 2
    local bvs "`r(c)' `r(s)'"
    post `h' ("`O_`y''") (strtrim(string(_b[`o'_te:BOTH],"%10.2f"))) (strtrim(string(_b[`o'_te:CFF],"%10.2f"))) ///
        ("`bvf'") (strtrim(string(_b[`o'_te:CFS],"%10.2f"))) ("`bvs'")
}
postclose `h'
pub_table using "`TC'", name(tc) tnum("Table 14.") ///
    title("Gain from coupling FISP with SAPs relative to each standalone intervention (coupled households)") ///
    note("Expected outcomes of the `Nf3' coupled households under the coupled regime and, counterfactually, under each standalone regime. Standard errors in parentheses. `STAR'")

*--- Table 15: summary of treatment effects ---------------------------
tempfile TS
postfile `h' str40 c1 str16 c2 str22 c3 str22 c4 str22 c5 using "`TS'", replace
post `h' ("Outcome") ("Regime") ("ATT") ("ATU") ("ATE")
foreach y of global Y {
    local o = subinstr("`y'","_","",.)
    forvalues j = 1/3 {
        foreach e in ATT ATU ATE {
            fmt_b `=_b[`o'_te:`e'`j']' `=_se[`o'_te:`e'`j']' 2
            local `e' "`r(c)' `r(s)'"
        }
        local lab ""
        if `j'==1 local lab "`O_`y''"
        post `h' ("`lab'") ("`R`j''") ("`ATT'") ("`ATU'") ("`ATE'")
    }
}
postclose `h'
pub_table using "`TS'", name(ts) tnum("Table 15.") ///
    title("Summary of treatment effects (reference: neither)") ///
    note("Standard errors in parentheses. `STAR'")

**********************************************************************
**# PART 7: Appendix tables
**********************************************************************

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Appendix")

*--- Table A1: MESR first-stage multinomial logit ---------------------
quietly estimates restore MNL
local mnl_N  = strtrim(string(e(N),"%9.0fc"))
local mnl_r2 = strtrim(string(e(r2_p),"%6.4f"))
tempfile TA1
postfile `h' str60 v str18 c1 str18 c2 str18 c3 using "`TA1'", replace
post `h' ("Variable") ("FISP only") ("SAPs only") ("FISP + SAPs")
local row = 1
local grows ""
foreach v in $X $Z {
    if `"`G_`v''"' != "" {
        post `h' ("`G_`v''") ("") ("") ("")
        local ++row
        local grows `grows' `row'
    }
    forvalues k = 1/3 {
        fmt_b `=_b[`k':`v']' `=_se[`k':`v']' 4
        local c`k' "`r(c)'"
        local s`k' "`r(s)'"
    }
    post `h' ("`S_`v''") ("`c1'") ("`c2'") ("`c3'")
    post `h' ("") ("`s1'") ("`s2'") ("`s3'")
    local row = `row' + 2
}
forvalues k = 1/3 {
    fmt_b `=_b[`k':_cons]' `=_se[`k':_cons]' 4
    local c`k' "`r(c)'"
    local s`k' "`r(s)'"
}
post `h' ("Constant") ("`c1'") ("`c2'") ("`c3'")
post `h' ("") ("`s1'") ("`s2'") ("`s3'")
post `h' ("Observations") ("`mnl_N'") ("") ("")
post `h' ("Pseudo R²") ("`mnl_r2'") ("") ("")
postclose `h'
pub_table using "`TA1'", name(ta1) tnum("Table A1.") fsize(8) groups(`grows') ///
    title("MESR first stage: multinomial logit used to build the selection-correction terms (base: neither)") ///
    note("EA-clustered standard errors in parentheses. `STAR'")

*--- Table A2: statistics quoted in the text --------------------------
quietly {
    egen byte _eatag = tag(ea_id)
    count if _eatag
    local nEA = r(N)
    egen byte _dtag = tag(district)
    count if _dtag
    local nDist = r(N)
    summarize fisp
    local sh_fisp = 100*r(mean)
    summarize saps
    local sh_saps = 100*r(mean)
    summarize saps if fisp==1
    local saps_f1 = 100*r(mean)
    summarize saps if fisp==0
    local saps_f0 = 100*r(mean)
    summarize fisp if saps==1
    local nofisp_saps = 100*(1-r(mean))
    egen byte _nsap = rowtotal(box_ridges erosion_control_bunds vetiver plating_pits Terraces Water_harvest_bunds)
    gen byte _multi = _nsap>1 if saps==1
    summarize _multi
    local multi = 100*r(mean)
    summarize radio_sap_strict
    local radio = 100*r(mean)
    summarize productivity_winsr
    local pmax = r(max)
    gen byte _fpoor = FCS<=21
    gen byte _fborder = FCS>21 & FCS<=35
    gen byte _faccept = FCS>35
}
tempfile TA2
postfile `h' str90 c1 str30 c2 using "`TA2'", replace
post `h' ("Statistic") ("Value")
post `h' ("Analysis sample (maize-growing households)") ("`Nfall'")
post `h' ("Enumeration areas / districts in the sample") ("`nEA' / `nDist'")
post `h' ("Households receiving FISP coupons (%)") (strtrim(string(`sh_fisp',"%5.1f")))
post `h' ("Households using at least one SAP (%)") (strtrim(string(`sh_saps',"%5.1f")))
post `h' ("FISP beneficiaries using at least one SAP (%)") (strtrim(string(`saps_f1',"%5.1f")))
post `h' ("Non-beneficiaries using at least one SAP (%)") (strtrim(string(`saps_f0',"%5.1f")))
post `h' ("Association FISP × SAPs, χ²(1)") ("`chi_fs' (`chi_fsp')")
post `h' ("SAP adopters not receiving FISP (%)") (strtrim(string(`nofisp_saps',"%5.1f")))
post `h' ("SAP adopters using more than one practice (%)") (strtrim(string(`multi',"%5.1f")))
post `h' ("Households receiving SAP advice mainly via radio (%)") (strtrim(string(`radio',"%5.1f")))
post `h' ("Largest retained maize productivity value (kg/acre)") (strtrim(string(`pmax',"%9.0fc")))
foreach k in 4 1 2 3 {
    quietly summarize _fpoor if regime==`k'
    local a = strtrim(string(100*r(mean),"%5.1f"))
    quietly summarize _fborder if regime==`k'
    local b = strtrim(string(100*r(mean),"%5.1f"))
    quietly summarize _faccept if regime==`k'
    local c = strtrim(string(100*r(mean),"%5.1f"))
    post `h' ("FCS poor / borderline / acceptable (%), `R`k''") ("`a' / `b' / `c'")
}
if "`tp2'" != "" {
    post `h' ("Age turning point, SAPs only (MNP, years)") ("`tp2'")
    post `h' ("Age turning point, FISP + SAPs (MNP, years)") ("`tp3'")
}
postclose `h'
pub_table using "`TA2'", name(ta2) tnum("Table A2.") ///
    title("Statistics quoted in the text") ///
    note("FCS categories use the standard thresholds of 21 and 35 (WFP, 2008). Turning point = −β(age)/(2β(age²)) from the multinomial probit (Table 5).")
drop _eatag _dtag _nsap _multi _fpoor _fborder _faccept

putdocx save "$result/MESR_tables_10_15.docx", replace
di as result "All tables and figures written to: $result/MESR_tables_10_15.docx"
log close mesrlog
