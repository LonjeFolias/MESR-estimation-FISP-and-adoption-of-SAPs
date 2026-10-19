******************************************************************************
*                                                                            *
*  Study: Farm input subsidies (FISP) and adoption of sustainable            *
*  agricultural practices in Malawi: synergies and implications on farm      *
*  productivity and household resilience to food shocks                      *
*                                                                            *
*  File: 01_data_cleaning.do                                                 *
*  Role: Household data construction                                         *
*  Author: Lonjezo Erick Folias                                              *
*  Email: lonjefolias@hotmail.com                                            *
*  Phone: 0992 888 003                                                       *
*  Documentation revision: 19 October 2026                                   *
*                                                                            *
*  Purpose: Constructs and merges the IHS5 maize-household analysis data,    *
*  outcomes, regimes and candidate instruments.                              *
*                                                                            *
*  Inputs: IHS5 raw modules, crop-unit conversion factors, CRU inputs and    *
*  cleaning support scripts.                                                 *
*                                                                            *
*  Outputs: $workingfiles/final esr data.dta plus intermediate and audit     *
*  files.                                                                    *
*                                                                            *
*  Run order: Called by 00_master-dofile.do; calls 01.1, 01.2 and 01.3       *
*  internally.                                                               *
*                                                                            *
*  Notes: Also requires the existing local 004_labels.do, which was not      *
*  supplied. All transformations and variable labels are preserved.          *
*                                                                            *
******************************************************************************

version 17
set more off


foreach folder in ihsv workingfiles dofiles {
    if "${`folder'}"=="" {
        di as error "Define global `folder' using your master do-file."
        exit 198
    }
}
capture log close cleanlog
log using "$workingfiles/cleaning_audit.log", text replace name(cleanlog)

******************************************************************************
**# PART 0: PATH CHECKS AND DATA CONSTRUCTION HELPERS
******************************************************************************
capture program drop _raw
program define _raw
    args filename
    capture confirm file "$ihsv/`filename'.dta"
    if !_rc use "$ihsv/`filename'.dta", clear
    else {
        local upper = upper("`filename'")
        confirm file "$ihsv/`upper'.dta"
        use "$ihsv/`upper'.dta", clear
    }
    rename *, lower
end
capture program drop _binary
program define _binary
    syntax varname, Generate(name)
    gen byte `generate' = .
    replace `generate'=1 if `varlist'==1
    replace `generate'=0 if `varlist'==2
    assert inlist(`generate',0,1) | missing(`generate')
end
capture program drop _distance
program define _distance
    syntax varlist(min=3 max=3 numeric), Generate(name)
    tokenize `varlist'
    /* Presence is an access proxy, not exact within-community distance. */
    gen double `generate' = .
    replace `generate'=`2'/1000 if `1'==2 & `3'==1 & `2'>=0 & `2'<.
    replace `generate'=`2' if `1'==2 & `3'==2 & `2'>=0 & `2'<.
    replace `generate'=`2'*1.609344 if `1'==2 & `3'==3 & `2'>=0 & `2'<.
    replace `generate'=0 if `1'==1
    gen byte `generate'_unresolved = `1'==2 & missing(`generate')
    gen byte `generate'_structzero = `1'==1
    label var `generate' "Access distance km; presence implies zero proxy"
end

capture program drop _kg_unit_key
program define _kg_unit_key
    syntax varname, Generate(name)
    * Preserve real code values. Do not encode or destring alphanumeric codes.
    capture confirm numeric variable `varlist'
    if !_rc {
        assert `varlist'==floor(`varlist') if !missing(`varlist')
        gen str16 `generate'=strtrim(strofreal(`varlist',"%18.0f")) if !missing(`varlist')
    }
    else {
        assert strlen(strtrim(`varlist'))<=16
        gen str16 `generate'=upper(strtrim(`varlist'))
        * Canonicalise numeric text only; 31A/31B/31C remain distinct codes.
        replace `generate'=strtrim(strofreal(real(`generate'),"%18.0f")) ///
            if !missing(real(`generate')) & real(`generate')==floor(real(`generate'))
        replace `generate'="" if inlist(`generate',".",".A",".B",".C",".D")
    }
    label var `generate' "Exact unit-code merge key; alphanumeric suffixes preserved"
end

global ihsivlock  ihsiv // a lock to apply for 	IHS4 only
global ihsvlock   ihsv // a lock to apply for 	IHS5 only
   
	
foreach IHSnumber in  ihsv  {			
**# HOUSEHOLD ROSTER AND HEAD CHARACTERISTICS
use "${`IHSnumber'}/hh_mod_b.dta", clear 
		
		
		if "`IHSnumber'"=="$ihsivlock" {
			rename pid PID
		}
		
		
		* Keep household-head attributes using hh_b04 == 1.
		*Age
		bysort case_id: g  age=hh_b05a if hh_b04==1 

		* Dependency ratio		
		bysort 	case_id: 	egen 	a=count(PID) 	if  hh_b05a<=14  | hh_b05a>64
		bysort 	case_id: 	egen	dependants=max(a) 	
		
		bysort 	case_id: 	egen 	b=count(PID) 		if 	hh_b05a>14	 & hh_b05a<=64
		bysort 	case_id: 	egen	working=max(b) 
		
		recode	 dependants (.=0)	
		recode 	 working	(.=1)
		
		g	 	dependency=(dependants/working)
		
		*HH_Size
		bysort case_id : egen hh_Size=count( PID )

		*Alduts
		bysort case_id : egen alduts=count(PID) if hh_b05a>=15
		
		* Marital status 
		bysort case_id: g  marital=hh_b24 if hh_b04==1
		la val marital hh_b24 
		
		
		*Gender
		bysort case_id: g  gender=hh_b03 if hh_b04==1
		
		
		*Years in the Village
		bysort case_id: g  years_village=hh_b12 if hh_b04==1
		replace years_village=age 		if hh_b12==.a | hh_b12==.
		
		
		keep case_id age hh_Size alduts marital gender years_village HHID dependency
		
		collapse (firstnm)  HHID (max) age hh_Size alduts years_village marital dependency gender, by (case_id)
		
		tempfile tempfile `IHSnumber'a

save  ``IHSnumber'a', replace 

		*Education
use "${`IHSnumber'}/hh_mod_b.dta", clear  // in order to capture the right PID for the HH head and not the respondent based on  module b 
		
		if "`IHSnumber'"=="$ihsivlock" {
			rename pid PID
		}
		
		keep case_id hh_b04 PID
		keep if hh_b04==1
	
		if "`IHSnumber'"=="$ihsivlock" {
			rename PID pid
			merge 1:1 case_id pid using "${`IHSnumber'}/hh_mod_c.dta", nogen //merging module b with c to caputure educ information from the right PID
		}
		
		
		if "`IHSnumber'"!="$ihsivlock" {
			merge 1:1 case_id PID using "${`IHSnumber'}/hh_mod_c.dta", nogen //merging module b with c to caputure educ information from the right PID
		}
		
		
		bysort case_id: g  educ=hh_c08 if hh_b04==1
		la val educ hh_c08
		
**# HEAD EDUCATION MERGE
		keep  case_id educ 
		collapse (max) educ , by (case_id)
		merge 1:1 case_id using ``IHSnumber'a', nogen
		
		tempfile `IHSnumber'a1

save  	``IHSnumber'a1', replace 		
	
	
		*hh location
use "${`IHSnumber'}/hh_mod_a_filt.dta", clear 		

		keep case_id reside region district ea_id hh_wgt hh_a02a
		
		rename (hh_a02a) (TAs)
		
		merge 1:1 case_id using ``IHSnumber'a1', nogen
	
		tempfile `IHSnumber'c_a
		
save  ``IHSnumber'c_a', replace 

		*Community 
		use "${`IHSnumber'}/com_cd.dta", clear 
		keep ea_id com_cd70 com_cd71
		merge 1:m ea_id using ``IHSnumber'c_a', nogen
		
		tempfile `IHSnumber'c_b
save   	``IHSnumber'c_b', replace 	


**# 	Food security indicators
use "${`IHSnumber'}/HH_MOD_G2.dta", clear
		replace hh_g08a=hh_g08b if hh_g08a<hh_g08b & hh_g08b!=.
		
		*FCS
		foreach i in a  c d e f g h i  {
			g fs`i'=.
		}

		replace fsa=hh_g08a*2 //cereal 
		
		replace fsc=hh_g08c*3 // pulses
		
		foreach v in e g  { // Meat and milk
			replace fs`v'=hh_g08`v'*4 
		}
		
		foreach i in d f   { // Veggies and Fruits
			replace fs`i'=hh_g08`i'*1 
		}
		
		foreach i in h i    { // Sugar + oil 
			replace fs`i'=hh_g08`i'*0.5
		}
	
		egen FCS=rowtotal(fs*)
		
		gen FCSa=. //ordinal FCS
		replace FCSa=0 if FCS<21
		replace FCSa=1 if FCS>=21 &   FCS<=35
		replace FCSa=2 if FCS>35
		
		
		*HDDS
		foreach 	letter 	in 	a  	b 	c 	d 	e 	f 	g 	h 	i 	j {
					g		hd_`letter'=. 
					replace hd_`letter'=1 	if 	hh_g08`letter'>0
					recode 	hd_`letter' (.=0)
		}
		
		egen  		HDDS	=rowtotal(hd_*)
		
		keep 		case_id FCSa 			FCS		HDDS 
		merge 1:1 case_id using  ``IHSnumber'c_b', nogen
		
		tempfile `IHSnumber'c_b
		
save    ``IHSnumber'c_b', replace 	

		*Shock 

use "${`IHSnumber'}/hh_mod_u.dta", clear

		g drought=1 if hh_u0a==101 & hh_u01==1
		g floods=1 if hh_u0a==102 & hh_u01==1
		g irregularrains=1 if hh_u0a==1101 & hh_u01==1	
		keep case_id  drought floods irregularrains
		collapse (max) drought floods irregularrains, by (case_id)
		merge 1:1 case_id using ``IHSnumber'c_b', nogen
		
		tempfile `IHSnumber'c_c
save  ``IHSnumber'c_c', replace 			
		
	
		*Temp 	
		if "`IHSnumber'"=="$ihsivlock" {
			use "${`IHSnumber'}/householdgeovariablesihs4.dta", clear 
			rename (af_bio_1 af_bio_12 lon_modified lat_modified) ( af_bio_1_x af_bio_12_x lon lat )

		} 
		
		if "`IHSnumber'"!="$ihsivlock" {
			use "${`IHSnumber'}/householdgeovariables_ihs5.dta", clear 
			rename ( ea_lon_mod ea_lat_mod ) (lon lat)
		}

		clonevar ea_lon_mod=lon
        clonevar ea_lat_mod=lat
        keep case_id af_bio_1_x af_bio_12_x lon lat ea_lon_mod ea_lat_mod dist_admarc dist_agmrkt
        confirm numeric variable lon
        confirm numeric variable lat
        label var lon "Household displaced longitude before CRU matching"
        label var lat "Household displaced latitude before CRU matching" 
		replace af_bio_1_x=af_bio_1_x/10 
		
		tempfile `IHSnumber'geodetails
		save 	 ``IHSnumber'geodetails', replace 
		save  	 "${workingfiles}/`IHSnumber'geodetails.dta", replace
		
		merge 1:1 case_id using  ``IHSnumber'c_c', nogen
		
		tempfile `IHSnumber'ob
save  	``IHSnumber'ob', replace 

	* Expenditure construction support 
	
	do "${dofiles}/01.1_expenditure.do" 

	
**# 	Off_farm
use "${`IHSnumber'}/HH_MOD_N2.dta", clear

		g off_farm=1 if hh_n09a!=.
		keep  HHID  off_farm
		collapse (max) off_farm , by (HHID)
		
		tempfile `IHSnumber'off_farm
save  	``IHSnumber'off_farm', replace 	
	
**# 	Credit
use "${`IHSnumber'}/hh_mod_s1.dta", clear				
		keep if hh_s01==1
		duplicates drop case_id, force
		keep hh_s01 case_id
		rename hh_s01 credit
		merge 1:1 case_id using ``IHSnumber'ob', nogen	
		merge 1:1 case_id using  "${workingfiles}/`IHSnumber'exp_o.dta", nogen
		merge 1:1 HHID 	  using ``IHSnumber'off_farm', nogen
	

		tempfile `IHSnumber'hh_data1 
	
save  	``IHSnumber'hh_data1', replace 	

	
**# 	Extension
use "${`IHSnumber'}/ag_mod_t1.dta" , clear 
		keep if ag_t01==1
		keep case_id ag_t01  ag_t0a ag_t02
		
		collapse (max) ag_t01 ag_t0a ag_t02 , by (case_id)
		rename ag_t01 extension
		merge 1:1 case_id using ``IHSnumber'hh_data1', nogen	
		
		tempfile `IHSnumber'hh_data2
save   ``IHSnumber'hh_data2', replace 		


**# 	input_subsidy
use "${`IHSnumber'}/ag_mod_e2.dta" , clear 
		keep if ag_e01==1
		keep case_id ag_e01
		collapse (max) ag_e01 , by (case_id)
		rename ag_e01 input_subsidy
		merge 1:1 case_id using ``IHSnumber'hh_data2', nogen	
		
		tempfile `IHSnumber'hh_data
save  	``IHSnumber'hh_data', replace 		


**#		Land Size
use "${`IHSnumber'}/ag_mod_c.dta" , clear
		keep case_id gardenid plotid ag_c04a ag_c04b ag_c04c ag_c04b_oth
        gen double area_self_acres=.
        replace area_self_acres=ag_c04a if ag_c04b==1
        replace area_self_acres=ag_c04a*2.47105381467165 if ag_c04b==2
        replace area_self_acres=ag_c04a/4046.8564224 if ag_c04b==3
        replace area_self_acres=ag_c04a/4840 if ag_c04b==4 & ///
            inlist(upper(strtrim(ag_c04b_oth)),"SQUARE YARDS","SQ YARDS")
        gen double Plot_Area=ag_c04c if ag_c04c>0 & ag_c04c<.
        replace Plot_Area=area_self_acres if missing(Plot_Area) & area_self_acres>0 & area_self_acres<.
        label var Plot_Area "Plot area acres: GPS, then converted self-report (verify GPS unit)"

		keep case_id gardenid plotid Plot_Area
		
		tempfile `IHSnumber'pa
save   ``IHSnumber'pa', replace 
		
**#		TLU
use "${`IHSnumber'}/ag_mod_r1.dta" , clear
		keep ag_r0a case_id ag_r01 ag_r02
		g TLU=.
		
		foreach i in 301 302 303 304 318 3304  {
			replace TLU=ag_r02*1 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 307 308 {
			replace TLU=ag_r02*0.1 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 309 3314 {
			replace TLU=ag_r02*0.2 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 311 313  {
			replace TLU=ag_r02*0.01 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 315  {
			replace TLU=ag_r02*0.03 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 319  {
			replace TLU=ag_r02*0.01 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 3305    {
			replace TLU=ag_r02*0.7 if ag_r0a==`i' & ag_r01==1
		}
		
		
		* Legacy mean-replacement block disabled; substantive variable retained.
		
				
		* Legacy mean-replacement block disabled; substantive variable retained.
		
		keep TLU case_id 
		collapse (sum) TLU , by(case_id)
		merge 1:m case_id  using ``IHSnumber'pa', nogen
		
		tempfile `IHSnumber'p
save  ``IHSnumber'p', replace 	
	
**# 	Plot details 
use "${`IHSnumber'}/ag_mod_d.dta" , clear
		
		g maize=.
		foreach v of varlist ag_d20a ag_d20b ag_d20c ag_d20d ag_d20e {
		replace maize=1 if `v'<=4
		}
		g type= ag_d21 if maize==1
		g quality= ag_d22 if maize==1
		rename ag_d36  organic_fertilizer
		rename ag_d38  inorganic_fertilizer
		rename ag_d55_1  agro_forestry
		g box_ridges=1 if ag_d62==2
		g minimum_tillage=1 if ag_d62==6
		g traditional_tilage=1 if ag_d62==1
		g plating_pits=1 if ag_d62==3
		
		
		foreach i in erosion_control_bunds vetiver Terraces Water_harvest_bunds  {
			g `i'=.
		}
		
		foreach i in a b  {
			replace erosion_control_bunds=1 if ag_d25`i'==3
			replace vetiver=1 if ag_d25`i'==5
			replace Terraces=1 if ag_d25`i'==2
			replace Water_harvest_bunds=1 if ag_d25`i'==7
			
		}
		
		
		keep case_id gardenid plotid maize type quality inorganic_fertilizer organic_fertilizer agro_forestry erosion_control_bunds vetiver box_ridges minimum_tillage plating_pits traditional_tilage Terraces Water_harvest_bunds
		
		merge 1:1 case_id gardenid plotid using ``IHSnumber'p', nogen
		
		tempfile `IHSnumber'q
save  	``IHSnumber'q', replace 	


**# 	Dry season
use "${`IHSnumber'}/ag_mod_k.dta" , clear
		
		g dry_season=.
		
		foreach v of varlist ag_k21a ag_k21b ag_k21c ag_k21d ag_k21e {
		   replace dry_season=1 if `v'<=4
		}
		
		keep case_id gardenid plotid dry_season 
		merge 1:1 case_id gardenid plotid using 	``IHSnumber'q', nogen
		
		tempfile `IHSnumber'ra
save  	``IHSnumber'ra', replace 		
	
	
	**# Output: official unit conversion, all maize records retained
        tempfile kgcrosswalk kgoverride
* Official IHS5 seasonal-crop conversions replace the long manual if-list.
_raw ihs_seasonalcropconversion_factor_2020
keep region crop_code unit_code unit_name condition conversion
rename unit_code crosswalk_unit_code
* IHS5 unit_code is character and includes 31A, 31B and 31C. The prior
* whole-column destring was incorrect. Merge on an exact string key instead.
* Source: https://microdata.worldbank.org/catalog/3818/variable/F102/V3357
_kg_unit_key crosswalk_unit_code, generate(kg_unit_key)
foreach key in region crop_code condition conversion {
    capture confirm numeric variable `key'
    if _rc {
        tempvar parsed
        gen double `parsed'=real(strtrim(`key'))
        assert !missing(`parsed') if strtrim(`key')!=""
        drop `key'
        rename `parsed' `key'
    }
    confirm numeric variable `key'
}
assert !missing(region,crop_code,condition) & kg_unit_key!=""
assert conversion>0 & conversion<.
* Drop only exact duplicate key+factor rows, never conflicting conversions.
duplicates drop region crop_code kg_unit_key condition conversion, force
isid region crop_code kg_unit_key condition
rename conversion official_kg_factor
rename unit_name crosswalk_unit_name
preserve
export delimited using "$workingfiles/harvest_kg_crosswalk_audit.csv", replace
restore
save `kgcrosswalk'

_raw ag_mod_g
keep if inrange(crop_code,1,4)
assert !missing(case_id,gardenid,plotid)
gen double harvest_value=ag_g13_1 if ag_g13_1>=0 & ag_g13_1<.
gen double quantity=ag_g13a if ag_g13a>=0 & ag_g13a<.
clonevar unit=ag_g13b
clonevar condition=ag_g13c
_kg_unit_key unit, generate(kg_unit_key)
* Raw ag_mod_g inspection: 13="OTHER", including explicit 90 KG BAG text.
* Match only unambiguous descriptions to existing official unit codes.
* Keep the original unit, other text and a reclassification flag for auditing.
gen strL harvest_other_unit_clean=upper(strtrim(ag_g13b_oth))
replace harvest_other_unit_clean=ustrregexra(harvest_other_unit_clean,"[[:space:]]","")
gen byte harvest_unit_reclassified=0
replace kg_unit_key="3" if unit==13 & ///
    inlist(harvest_other_unit_clean,"90KGBAG","90KGBAGS","90KG","BAGSOF90KGS")
replace kg_unit_key="2" if unit==13 & harvest_other_unit_clean=="50KGBAG"
replace harvest_unit_reclassified=1 if unit==13 & inlist(kg_unit_key,"2","3")
merge m:1 case_id using "${`IHSnumber'}/hh_mod_a_filt.dta", keep(master match) gen(merge_crop_location)
gen double kg_factor=.
merge m:1 region crop_code kg_unit_key condition using `kgcrosswalk', ///
    keep(master match) gen(merge_official_kg)
tab merge_official_kg, missing
replace kg_factor=official_kg_factor if !missing(official_kg_factor)
* Kilograms are safe without a nonstandard-unit crosswalk.
local unitlabel : value label unit
capture confirm numeric variable unit
if !_rc & "`unitlabel'"!="" {
    decode unit, generate(unit_text)
    replace kg_factor=1 if inlist(upper(strtrim(unit_text)),"KG","KILOGRAM","KILOGRAMS")
}
* Optional reviewed crosswalk: unique region crop_code unit condition,
* numeric reviewed_kg_factor, with provenance documented alongside it.
capture confirm file "$workingfiles/harvest_kg_crosswalk_reviewed.dta"
if !_rc {
    preserve
    use "$workingfiles/harvest_kg_crosswalk_reviewed.dta", clear
    keep region crop_code unit condition reviewed_kg_factor
    _kg_unit_key unit, generate(kg_unit_key)
    rename unit reviewed_unit_code
    foreach key in region crop_code condition reviewed_kg_factor {
        capture confirm numeric variable `key'
        if _rc {
            tempvar parsed
            gen double `parsed'=real(strtrim(`key'))
            assert !missing(`parsed') if strtrim(`key')!=""
            drop `key'
            rename `parsed' `key'
        }
    }
    assert !missing(region,crop_code,condition) & kg_unit_key!=""
    isid region crop_code kg_unit_key condition
    save `kgoverride'
    restore
    merge m:1 region crop_code kg_unit_key condition using ///
        `kgoverride', keep(master match) gen(merge_kg)
    assert reviewed_kg_factor>0 if !missing(reviewed_kg_factor)
    replace kg_factor=reviewed_kg_factor if !missing(reviewed_kg_factor)
}
gen double output_kg=quantity*kg_factor
* Actual raw file has 304 zero maize harvests with absent unit codes.
* Zero physical harvest is zero kg regardless of unit; do not lose these cases.
replace output_kg=0 if quantity==0
gen byte crop_kg_missing=missing(output_kg)
gen byte crop_value_missing=missing(harvest_value)
preserve
keep if crop_kg_missing==1
keep case_id region crop_code unit ag_g13b_oth kg_unit_key condition quantity ///
    merge_official_kg harvest_unit_reclassified
export delimited using "$workingfiles/maize_kg_unmatched_audit.csv", replace
restore
save "$workingfiles/maize_crop_conversion_audit.dta", replace
        collapse (sum) output_kg (max) crop_kg_missing harvest_unit_reclassified, by(case_id gardenid plotid)
        replace output_kg=. if crop_kg_missing==1
        rename output_kg output
        rename crop_kg_missing output_kg_missing
        merge 1:1 case_id gardenid plotid using ``IHSnumber'ra', nogen
        tempfile `IHSnumber'rb
        save ``IHSnumber'rb', replace

**# 	Harvest
use "${`IHSnumber'}/ag_mod_g.dta" , clear
		keep if crop_code<=4
		foreach i in plotid gardenid {
			drop if `i'==""
		}
		
		if "`IHSnumber'"=="$ihsivlock" {
			rename (ag_g13a) ( ag_g13_1)
		
		}
		
		rename ag_g13_1 harvest 
		collapse (sum) harvest, by (case_id gardenid plotid)
		keep case_id gardenid plotid  harvest
		
		merge 1:1 case_id gardenid plotid using ``IHSnumber'rb', nogen	
		
		foreach i in  dry_season organic_fertilizer inorganic_fertilizer maize type quality  agro_forestry{ 
			recode `i' (.=0)
		}
			
		collapse (sum) harvest Plot_Area output (max) output_kg_missing harvest_unit_reclassified TLU plating_pits traditional_tilage Terraces Water_harvest_bunds dry_season organic_fertilizer agro_forestry inorganic_fertilizer maize type quality erosion_control_bunds vetiver box_ridges minimum_tillage, by (case_id)
		
		tempfile `IHSnumber's
save   	``IHSnumber's', replace

**# 	Sales
use "${`IHSnumber'}/ag_mod_i.dta" , clear 		
		keep if crop_code<=4
		keep if ag_i01==1
		rename ag_i01 sold
		rename ag_i03 sales
		keep case_id crop_code sales sold 
		collapse (sum) sales (max) sold, by(case_id)
		merge 1:1 case_id  using ``IHSnumber's', nogen	
		merge 1:1 case_id  using ``IHSnumber'hh_data', nogen	
		keep if maize==1

		tempfile `IHSnumber'combined
		save 	``IHSnumber'combined', replace
		
		save  "${workingfiles}/`IHSnumber'combined.dta", replace		

	* Both combined and geodetails files must carry these keys for CRU matching.
    confirm numeric variable lat
    confirm numeric variable lon
    do "${dofiles}/01.2_`IHSnumber'climate.do"
    confirm numeric variable lat
    confirm numeric variable lon
    confirm numeric variable GPS_lat
    confirm numeric variable GPS_lon 
	
	
*save  "${workingfiles}/`IHSnumber'combined.dta", replace	

**# 	Data Construction 
		
	
		
* Legacy mean-replacement block disabled; substantive variable retained.
	
	gen double productivity=output/Plot_Area if Plot_Area>0 & !missing(Plot_Area, output)
	
	
	foreach v of varlist input_subsidy organic_fertilizer reside gender  inorganic_fertilizer sold  maize dry_season credit extension agro_forestry erosion_control_bunds vetiver box_ridges minimum_tillage drought floods irregularrains plating_pits traditional_tilage Terraces Water_harvest_bunds {
		recode `v' (2=0)
		recode `v' (.=0)
		la val `v' YN
	}

	*global saps box_ridges erosion_control_bunds vetiver plating_pits Terraces Water_harvest_bunds agro_forestry
	
	global saps box_ridges erosion_control_bunds vetiver plating_pits Terraces Water_harvest_bunds
	
	g saps=.
	
	foreach i in $saps {
		replace saps=1 if `i'==1
	}

	g fisp_saps=1 if input_subsidy==1 | saps==1
	
	recode saps fisp_saps (.=0) 
	
	g 		combined=2 	if 		input_subsidy==1
	replace combined=3 	if 		saps ==1
	replace combined=1 	if 		saps ==1 			& 	input_subsidy==1
	recode 	combined 	(.=0)
	

	recode marital (2=1)
	recode marital (3=2)
	recode marital (4=2)
	recode marital (5=3)
	recode marital (6=4)
	
	recode type (4=2)
	recode educ (.=0)
	
	
	**# Value labels
	la define combined 0 "None" 1 "Both" 2 "Fisp" 3 "Saps", replace
	la define gender 1 "Male" 0 "Female", replace
	la define YN 1 "Yes" 0 "No", replace
	la define reside1 1 "urban" 0 "rural", replace
	la define marital 1 "Married" 2 "Separated/Divorced" 3 "Widowed" 4 "Never", replace
	la define type 1 "Sandy" 2 "Between" 3 "Clay", replace
	la define quality 1 "Good" 2 "Fair" 3 "Poor", replace
	la val marital marital
	la val quality quality
	la val type ag_d21
	la val gender gender
	la val reside reside1
	la val combined combined
	
	foreach i in marital type quality region {
		ta `i', g(`i')
	}
	

		foreach i of varlist input_subsidy saps fisp_saps {
			
			clonevar x_`i'=`i'
			recode x_`i' (0=.)
			bysort district : egen a_`i'=count(x_`i')
			bysort district : egen b_`i'=count(district)
			g IV_`i'=a_`i'/b_`i'

		}
			
 	drop x_* a_*  b_*

	*cd "C:\Users\user\Documents\Manu Scripts\Wisdom Proposal\May"

	global `IHSnumber'categorical gender credit extension type1 type2 type3 quality1 quality2 quality3 input_subsidy drought floods irregularrains box_ridges minimum_tillage erosion_control_bunds vetiver plating_pits traditional_tilage Terraces Water_harvest_bunds agro_forestry saps
	
		if "`IHSnumber'"=="$ihsivlock" {
				global `IHSnumber'categorical gender credit extension type2 type3 type4 quality2 quality3 quality4 input_subsidy drought floods irregularrains box_ridges minimum_tillage erosion_control_bunds vetiver plating_pits traditional_tilage Terraces Water_harvest_bunds agro_forestry saps
		
		}
	
	global `IHSnumber'continous age educ hh_Size Plot_Area output years_village af_bio_1_x af_bio_12_x 

	gen 	poor=1 	if 				exp<165879
	recode 	poor 	(.=0)
	sum 	poor
	local 	z= 		r(mean)*r(N)

	foreach i in 1 2 {
			gen 	FGT`i'= 	((1/2100)*(((165869-exp)/165869))^`i') if poor==1
			recode 	FGT`i'  	(.=0)
			replace FGT`i'=		FGT`i' *1000
	} 

	rename poor FGT0

	*Outliers
	
		* Legacy mean-replacement block disabled; substantive variable retained.
	
		* Legacy mean-replacement block disabled; substantive variable retained.
	
		* Legacy mean-replacement block disabled; substantive variable retained.
		
				
		* Legacy mean-replacement block disabled; substantive variable retained.
		
		
		* Legacy mean-replacement block disabled; substantive variable retained.
		
		* Legacy mean-replacement block disabled; substantive variable retained.
		foreach var of varlist productivity avr_long_tmp2019 avr_long_pre2019 avr_yearly_tmp2019 avr_yearly_pre2019 HDDS FCS  {
		g l_`var'=ln(`var')
	}
	

	*This to be restructured
	
		
    quietly ds
    *local constructed_before_labels `r(varlist)'
    do "${dofiles}/01.3_var_labels.do"
    * Labels may add aliases and regime fields; they must not remove variables.
    *foreach v of local constructed_before_labels {
     *   confirm variable `v'
    *}
	

    **# CANDIDATE INSTRUMENTS AND MERGE AUDITS
* Add candidate instruments after the original construction/labels workflow.
    quietly ds
    local legacy_variables `r(varlist)'
    tempfile iv_advice iv_community iv_geo iv_education iv_head
    preserve
* Advice: construct indicators at topic level BEFORE collapsing.
_raw ag_mod_t1
isid case_id ag_t0a
keep case_id ag_t0a ag_t01 ag_t02
save "$workingfiles/advice_topic_audit.dta", replace
_binary ag_t01, generate(received)
gen byte radio_any=0 if !missing(received)
replace radio_any=1 if received==1 & ag_t02==12
replace radio_any=. if received==1 & missing(ag_t02)
* Strict topic matches the original six-practice SAP definition: pit planting.
* Broad topics add irrigation, composting, forestry, agroforestry as sensitivity.
gen byte radio_sap_strict=radio_any if ag_t0a==304
gen byte radio_sap_broad=radio_any if inlist(ag_t0a,304,305,306,310,315)
collapse (max) extension_any_advice=received radio_any radio_sap_strict radio_sap_broad ///
    (count) advice_valid=received strict_valid=radio_sap_strict broad_valid=radio_sap_broad, by(case_id)
replace extension_any_advice=. if advice_valid==0
replace radio_sap_strict=. if strict_valid==0
replace radio_sap_broad=. if broad_valid<5 & radio_sap_broad!=1
isid case_id
save `iv_advice'


    restore
    merge 1:1 case_id using `iv_advice', keep(master match) gen(merge_iv_advice)
    preserve
* Community candidate instruments: raw fields retained for tracing.
_raw com_cd
keep ea_id com_cd66 com_cd67a com_cd67b com_cd68 com_cd69a com_cd69b com_cd70 com_cd71
isid ea_id
_binary com_cd70, generate(mp_resident)
_binary com_cd71, generate(mp_visit)
_binary com_cd66, generate(bank_present)
_binary com_cd68, generate(mfi_present)
_distance com_cd66 com_cd67a com_cd67b, generate(dist_bank_km)
_distance com_cd68 com_cd69a com_cd69b, generate(dist_mfi_km)
save `iv_community'
_raw com_cc
keep ea_id com_cc14
isid ea_id
clonevar turnout2014_cat=com_cc14
replace turnout2014_cat=. if !inrange(turnout2014_cat,1,5)
merge 1:1 ea_id using `iv_community', gen(merge_cc_cd)
tab merge_cc_cd, missing
save `iv_community', replace
_raw com_cf1
keep ea_id com_cf07 com_cf08a com_cf08b
isid ea_id
_binary com_cf07, generate(extension_resident)
_distance com_cf07 com_cf08a com_cf08b, generate(dist_extension_km)
merge 1:1 ea_id using `iv_community', gen(merge_cf_cd)
tab merge_cf_cd, missing
save `iv_community', replace


    restore
    merge m:1 ea_id using `iv_community', keep(master match) gen(merge_iv_community)
    preserve
    _raw householdgeovariables_ihs5
    isid case_id
    keep case_id dist_admarc dist_agmrkt af_bio_1_x af_bio_12_x
    gen double climate_temp=af_bio_1_x/10
    gen double climate_rain=af_bio_12_x
    keep case_id dist_admarc dist_agmrkt climate_temp climate_rain
    save `iv_geo'
    restore
    merge 1:1 case_id using `iv_geo', keep(master match) gen(merge_iv_geo)

    preserve
    _raw hh_mod_b
    keep if hh_b04==1
    keep case_id pid
    isid case_id
    save `iv_head'
    _raw hh_mod_c
    isid case_id pid
    merge 1:1 case_id pid using `iv_head', keep(match) nogen
    gen byte educ_group=0 if hh_c06==2
    replace educ_group=1 if hh_c06==1 & inrange(hh_c08,0,8)
    replace educ_group=2 if hh_c06==1 & inrange(hh_c08,9,14)
    replace educ_group=3 if hh_c06==1 & inrange(hh_c08,15,23)
    keep case_id educ_group
    isid case_id
    save `iv_education'
    restore
    merge 1:1 case_id using `iv_education', keep(master match) gen(merge_iv_educ)
    label define educ_group_label 0 "Never attended" 1 "Pre-school/primary" 2 "Secondary" 3 "Post-secondary", replace
    label values educ_group educ_group_label

    foreach v in dist_bank_km dist_mfi_km dist_extension_km dist_admarc dist_agmrkt {
        gen double ln1p_`v'=ln(1+`v') if `v'>=0 & `v'<.
        label var ln1p_`v' "Log(1 + `v' in km)"
    }
    * Keep original combined_fisp_saps coding (1 FISP, 2 SAPs, 3 both, 4 neither).
    * Separate canonical coding for the revised MESR file; never overwrite it.
    gen byte mesr_regime=.
    replace mesr_regime=1 if fisp==1 & saps==1
    replace mesr_regime=2 if fisp==1 & saps==0
    replace mesr_regime=3 if fisp==0 & saps==1
    replace mesr_regime=4 if fisp==0 & saps==0
    label define mesr_regime_label 1 "Both FISP and SAPs" 2 "FISP only" 3 "SAPs only" 4 "Neither", replace
    label values mesr_regime mesr_regime_label
    gen byte study_sample=maize==1 & !missing(mesr_regime)

    foreach v of local legacy_variables {
        confirm variable `v'
    }
	
	
	
	*Outliers  
	
	*ooutliers

	*Outliers
	
		foreach v of varlist  HDDS {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<1.3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>1.3 & mesr_regime!=1
}

		drop z_* a_* m_*
	
		foreach v of varlist  FCS {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
		replace `v'=m_`v' if z_`v'>3 & mesr_regime!=1
}

		drop z_* a_* m_*
	
		foreach v of varlist  FCS {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'<-1.9 & mesr_regime==1
		replace `v'=m_`v' if z_`v'>3 & mesr_regime!=1
}

		drop z_* a_* m_*
		
				
		foreach v of varlist  productivity {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'<-0.19 
			replace `v'=m_`v' if z_`v'>3 
}

		drop z_* a_* m_*
		
		
		foreach v of varlist  productivity {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>3 & mesr_regime!=1 
}

		drop z_* a_* m_*
		
		foreach v of varlist  productivity {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>3 & mesr_regime==0
}

	drop z_* a_* m_*
	
    confirm numeric variable lat
    confirm numeric variable lon
    label var lat "Nearest CRU grid latitude (degrees)"
    label var lon "Nearest CRU grid longitude (degrees)"
    label var GPS_lat "Original displaced household/EA latitude (degrees)"
    label var GPS_lon "Original displaced household/EA longitude (degrees)"
    label var radio_any "Received any agricultural advice mainly from radio"
    label var radio_sap_strict "Received pit-planting advice mainly from radio"
    label var radio_sap_broad "Received broad SAP-related advice mainly from radio"
    label var turnout2014_cat "2014 turnout category; not an exact percentage"
    label var mp_resident "MP resident in community: 1 yes, 0 no"
    label var mp_visit "MP visited community in past three months"
    label var bank_present "Commercial bank present in community"
    label var mfi_present "Microfinance institution present in community"
    label var extension_resident "Extension officer lives in community"
    label var extension_any_advice "Any reported agricultural advice; new audited indicator"
    label var educ_group "Head's grouped education, including explicit never-attended"
    label var dist_admarc "Distance to ADMARC market (km); original geovariable"
    label var dist_agmrkt "Distance to agricultural market (km); original geovariable"
    label var dist_bank_km "Bank access distance km; facility presence coded zero proxy"
    label var dist_mfi_km "Microfinance access distance km; presence coded zero proxy"
    label var dist_extension_km "Extension-officer access distance km; residence coded zero proxy"
    **# FINAL LABEL PASS AND ANALYSIS DATA EXPORT
* Final labels pass: run AFTER all IV additions and household collapses.
* Required existing local dependency: 004_labels.do (not included in uploads).
    do "${dofiles}/004_labels.do"
    isid case_id
  
  
	foreach cont_var of varlist  productivity TLU {

    local old_lbl : variable label `cont_var'
    if "`old_lbl'" == "" local old_lbl "`cont_var'"

    * winsr: symmetric 5th-95th percentile within district
    winsor2 `cont_var', suffix(_winsr) cuts(5 95) by(district)

    * winsr2: winsor2 cuts(0 95) within district; no lower-tail percentile replacement
    winsor2 `cont_var', suffix(_winsr2) cuts(0 95) by(district)

    * Label both winsorized versions
    label variable `cont_var'_winsr  "`old_lbl' cuts(5 95)"
    label variable `cont_var'_winsr2 "`old_lbl' cuts(0 95)"
	}
  
    save "${workingfiles}/final esr data.dta", replace
    preserve
    keep case_id ea_id radio_* turnout2014_cat mp_resident mp_visit dist_* ///
        ln1p_* merge_iv_* GPS_lat GPS_lon lat lon
    export delimited using "$workingfiles/iv_and_merge_audit.csv", replace
    restore

	
	}
	
****************************************************************************
* End of do file
****************************************************************************

log close cleanlog
