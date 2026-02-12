   * ******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
   *               Lonjezo Folias, lonjefolias@hotmail.com                *
   *               Climate Data Do file            						  *
   *																	  *
   *     Project Title : 												  *
   *     Farm Input Subsidies and Adoption of Sustainable Agricultural    *
   *     Practices in Malawi: Synergies and Implications on Farm          * 
   *     Productivity and Household Food Security                         *
   * ******************************************************************** *
   * ******************************************************************** *

   
          /*
       ** PURPOSE:      To clean climate data download from Climatic Research Unit
						https://data.ceda.ac.uk/badc/cru/data/cru_ts/cru_ts_4.07
						The data was download in an .nc format and converted into 
						.cvs format using the ncdf4 package in R

            
		** OUTLINE: 	PART 1: Restructuring preceptetion data based on time
                        PART 2: Restructuring temperature data based on time
						PART 3: Constructing climate variables
						PART 4: Restructuring lon and lat variables to match LSMS data
						
						
       ** WRITTEN BY:   Lonjezo Folias, lonjefolias@hotmail.com   

       ** Last date modified: 5 February 2026
       */
	   

**# PART 2: Restructuring preceptetion data based on time  
	
	*NOTE : Lines 41 to 51 will consume much of your time by loading large CSV files. You only need to run them once, the first time. 
	
	*ARE YOU RUNNING THIS SCRIPT FOR THE FIRST TIME? YES/NO
	*INDICATE "Yes" OR "No" IF THE "RUNNINGSCRIPT_FIRSTTIME" LOCAL in line 47
	
	local runningscript_firsttime "Yes"
	
	if  "`runningscript_firsttime'"=="Yes" {
		
		foreach csv in pre tmp {
			import 	delimited 	"${weather}/cru_`csv'_2.csv", clear 
			compress 
			
			tempfile 	cru_`csv'_2
			save  		`cru_`csv'_2', replace
		}	
		
	}
	
	
	*import 	delimited 	"${weather}/cru_pre_2.csv", clear 
	use `cru_pre_2', clear
	local 	nv = 1
	
	
forvalues y = 1901/2022 {
	forvalues m = 1/12 {
		local ma = `m'
		if `m'<10 local ma = "0`m'"
		local pre_`nv' = "t`ma'_`y'"
		dis  "`pre_`nv''"
		local nv = `nv' + 1
	}
	
}

local nv = 1
	foreach var of varlist prejan-v1466 {
		rename 	`var' 	`pre_`nv''
		lab 	 var 	`pre_`nv'' "Time_`pre_`nv''"
		local 	 nv = `nv' + 1
	}

	
*Keeping lon and lat which cover Malawi and relevant years: 
*lon ( 31.75 to 36.5)  lat (-17.75 to -8.25 )
	keep  	lon lat 	t01_2015-t12_2022
	keep 	if 	lon>=31.75
	keep 	if 	lon<=36.5
	keep 	if 	lat>=-17.75
	keep 	if 	lat<=-8.25
	des
	tab 	lon
	local 	nlo=`r(r)'
	tab 	lat
	local 	nla=`r(r)'

	local 	ncomb=`nlo'*`nla'

	local 	robs= `ncomb'*12*8  ///nlo: number of the different 
	///combinations of lat & lon //12 mounths //8  year(2015 to 2022)
	
	dis 	`robs'

	set 	obs 	`robs'
	gen 	llon = .
	gen 	llat = .
	gen 	lmonth = .
	gen 	lyear = .
	gen 	lpre = .
	local 	nv = 1
	local 	pos=1
	local 	posa = 1


	foreach var of varlist t01_2015-t12_2022 {
		forvalues 	i=1/`ncomb' {
			qui 	replace 	llon = lon[`i'] in `posa'
			qui 	replace 	llat = lat[`i'] in `posa'
			local 	m = substr("`var'",2,2)
			local 	y = substr("`var'",5,4)
			qui 	replace  	lmonth = `m' in `posa'
			qui 	replace  	lyear  = `y' in `posa'
			qui		replace  	lpre = `var'[`i'] in `posa'
			local 	posa= `posa' +1
		}

	}
	sum ll*

	keep 	llon 	llat 	lmonth 	lyear 	lpre
	rename 	llon 	lon
	rename 	llat 	lat
	rename 	lmonth 	mounth
	rename 	lyear 	year
	rename 	lpre 	pre
	
	tempfile cru_pre_malawi_f
	save `cru_pre_malawi_f', replace


**# PART 3: Restructuring temperature data based on time
	
	*import delimited "${weather}/cru_tmp_2.csv", clear 
	use `cru_tmp_2', clear
	local nv = 1
	forvalues y = 1901/2022 {
		forvalues m = 1/12 {
			local ma = `m'
			if `m'<10 local ma = "0`m'"
			local tmp_`nv' = "t`ma'_`y'"
			dis  "`tmp_`nv''"
			local nv = `nv' + 1
		}
		
	}


	local nv = 1
	foreach var of varlist tmpjan-v1466 {
		rename `var' `tmp_`nv''
		lab var `tmp_`nv'' "Time_`tmp_`nv''"
		local nv = `nv' + 1
	}

*Keeping lon and lat which cover Malawi and relevant years: 
*lon ( 31.75 to 36.5)  lat (-17.75 to -8.25 )
	keep  	lon 	lat 		t01_2015-t12_2022
	keep 	if 		lon>=31.75
	keep 	if 		lon<=36.5
	keep 	if 		lat>=-17.75
	keep 	if 		lat<=-8.25
	des
	tab 	lon
	local 	nlo= `r(r)'
	tab 	lat
	local 	nla= `r(r)'

	local 	ncomb = `nlo'*`nla'
	keep	lon 	lat  		t01_2015-t12_2022
	local 	robs = `ncomb'*12*8 // nlo: number of the different 
	*combinations of lat & lon // 12 mounths // 8 years (2015 to 2022)
	dis		`robs'

	set 	obs `robs'
	gen 	llon = .
	gen 	llat = .
	gen 	lmonth = .
	gen 	lyear = .
	gen 	ltmp = .
	local 	nv = 1
	local 	pos=1
	local 	posa = 1

	foreach var of varlist t01_2015-t12_2022 {
		forvalues i=1/`ncomb' {
			qui 	replace 	llon = lon[`i'] in `posa'
			qui 	replace 	llat = lat[`i'] in `posa'
			local 	m = substr("`var'",2,2)
			local 	y = substr("`var'",5,4)
			qui 	replace  	lmonth = `m' in `posa'
			qui 	replace  	lyear  = `y' in `posa'
			qui 	replace  	ltmp = `var'[`i'] in `posa'
			local 	posa= `posa' +1
		}

	}
	sum ll*

	keep 	llon 	llat lmonth lyear ltmp
	rename	llon	lon
	rename	llat 	lat
	rename 	lmonth 	mounth
	rename	lyear	year
	rename 	ltmp 	tmp
	
	tempfile cru_tmp_malawi_f
save `cru_tmp_malawi_f', replace

	isid 	lon 	lat mounth year

	merge 1:1 lon lat mounth year using `cru_pre_malawi_f', nogenerate

	tempfile climate_data_malawi
save `climate_data_malawi', replace


**# PART 4: Construct climate variables

    /* 
	In this programe, we can construct climate variables, for instance, average temperature by year, climate chocks etc. : by combinations of CRU lat and lon.
	You must update this file to compute the climate shocks. 
	 */ 
	

	use 		`climate_data_malawi', clear

	**Example1: for each geo localisation, we compute the long terme average tmp and pre
	gen 		avr_long_tmp =0
	gen 		avr_long_pre  =0

	forvalues r	= 31.75(0.5)36.75 {
		forvalues s	= -17.75(0.5)-8.25 {
	    qui 	qui sum tmp                    if  lon == `r' & lat == `s'
		qui 	replace avr_long_tmp = r(mean) if  lon == `r' & lat == `s'
		
		qui 	qui sum pre                    if  lon == `r' & lat == `s'
		qui 	replace avr_long_pre = r(mean) if  lon == `r' & lat == `s'
	}
	}

	**Example2: for each geo localisation, we compute the yearly average tmp and pre
	
	gen 		avr_yearly_tmp =0
	gen 		avr_yearly_pre  =0
   
 
   forvalues y=2015/2022 {
	forvalues r	= 31.75(0.5)36.75 {
		forvalues s	= -17.75(0.5)-8.25 {
			
	    qui 	qui sum tmp                      if  lon == `r' & lat == `s' & year == `y'
		qui 	replace avr_yearly_tmp = r(mean) if  lon == `r' & lat == `s' & year == `y'
		
		qui 	qui sum pre                      if  lon == `r' & lat == `s' & year == `y'
		qui 	replace avr_yearly_pre = r(mean) if  lon == `r' & lat == `s' & year == `y'
		

	}
	}
		
   }

	**We simplify the data to be  at year level and in wide fomart */

	collapse  	(mean)   	avr_*  , 	by(year  lon  lat )
	reshape		wide 		avr_*  , 	i (lon lat) 	j (year)
	

	keep lon lat *2019
	**Save
	
	tempfile 	cru_clim_vars
	save 		`cru_clim_vars', replace
	
***************

**# PART 5: Restructuring lon and lat variables
/*
This program enables to match the CRU vars  with the HH survey
*/

foreach IHSnumber in ihsv  {
	
use "${workingfiles}/`IHSnumber'geodetails.dta", clear 

	*rename 	_Latitude_latitude 	lat
	*rename 	_Latitude_longitude lon

	keep 		case_id  		lon
	sort 		lon
	collapse 	(first) 	case_id , by(lon)
	cap 		drop 		llong 
	gen 		llong = .
	
#delimit ;
local lista
31.75
32.25
32.75
33.25
33.75
34.25
34.75
35.25
35.75
36.25
36.75
;

#delimit cr


drop if lon==. 
drop if lon==0
count


global lonje = r(N)

forvalues i = 1/$lonje {
    local dif 10
    local val 31.75
    // Assuming `lista` is already defined elsewhere in the script
    foreach v of local lista {
        local tmp = min(abs(lon[`i'] - `v'), `dif')
        if (`tmp' < `dif') {
            local dif = abs(lon[`i'] - `v')
            local vala = `v'
        }
    }
	drop if lon==.
    qui replace llong = `vala' in `i'
}

	tempfile `IHSnumber'llong

save ``IHSnumber'llong', replace


use "${workingfiles}/`IHSnumber'geodetails.dta", clear 

keep case_id  lat
sort lat
collapse (first) case_id , by(lat)
cap drop llat 
gen llat = .
#delimit ;
local lista
-17.75
-17.25
-16.75
-16.25
-15.75
-15.25
-14.75
-14.25
-13.75
-13.25
-12.75
-12.25
-11.75
-11.25
-10.75
-10.25
-9.75
-9.25
-8.75
-8.25
;

#delimit cr

drop if lat==. 
drop if lat==0 

count

global lonje = r(N)

forvalues i = 1/$lonje {
	local dif = 15
	local val = -17.75
	foreach val of local lista {
		local tmp = min((abs(lat[`i']-`val')) , `dif')
		if  (`tmp'< `dif') {
			local dif = abs(lat[`i']-`val')
			local vala = `val'
		}
	}
	
	qui replace llat = `vala' in `i'
	
}
	tempfile `IHSnumber'llat
	
save ``IHSnumber'llat', replace

}

use "${workingfiles}/ihsvcombined.dta", clear 

count


merge m:1 lat using 	`ihsvllat'
count
keep if _merge == 3
cap drop _merge
merge m:1 lon using 	`ihsvllong'
count
keep if _merge == 3
cap drop _merge

rename lon GPS_lon
rename lat GPS_lat

rename llat lat
rename llong lon


merge m:1 lon lat  using 	``IHSnumber'cru_clim_vars'
keep if _merge == 3
drop _merge
