   /******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
		Data cleaning and management do-file. 
		This do-file loops over IHS IV and IHS V so that the cleaning 
		can be performed simultaneously.
   *               														  *                                
   *				Author : Lonjezo Erick Folias                         *
   *				Number : 0992 888 003   							  *
   *				Email  : lonjefolias@hotmail.com					  *
   * ******************************************************************** *
   * ******************************************************************** */

global ihsivlock  ihsiv // a lock to apply for 	IHS4 only
global ihsvlock   ihsv // a lock to apply for 	IHS5 only
   
	
foreach IHSnumber in  ihsv  {			
**# 										 Household Charecters
use "${`IHSnumber'}/hh_mod_b.dta", clear 
		
		
		if "`IHSnumber'"=="$ihsivlock" {
			rename pid PID
		}
		
		
		*Line 30 to 46 keeps attributes of the hh head whose value is 1 in hh_b04
		*Age
		bysort case_id: g  age=hh_b05a if hh_b04==1 

		*Dependancy ratio		
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
		
		*Maritial 
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
		la val hh_c08 educ
		
**# Bookmark #1
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
		use "${`IHSnumber'}/com_cd.dta" 
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

		keep case_id af_bio_1_x af_bio_12_x   lon lat 
		replace af_bio_1_x=af_bio_1_x/10 
		
		tempfile `IHSnumber'geodetails
		save 	 ``IHSnumber'geodetails', replace 
		save  	 "${workingfiles}/`IHSnumber'geodetails.dta", replace
		
		merge 1:1 case_id using  ``IHSnumber'c_c', nogen
		
		tempfile `IHSnumber'ob
save  	``IHSnumber'ob', replace 



	*Ependiture do file 
	
	do "${dofiles}/02_expenditure.do" 

	
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
		keep case_id ag_t01
		collapse (max) ag_t01 , by (case_id)
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
		replace ag_c04a=ag_c04a*2.4711 if ag_c04b==2
		replace ag_c04a=ag_c04a*000024710538146717 if ag_c04b==3
		replace ag_c04a=ag_c04a*0.0002066115903 if ag_c04b_oth=="YARDS"
		replace ag_c04a=ag_c04a*000024710538146717 if ag_c04b_oth=="METERS"
		replace ag_c04c=ag_c04b if ag_c04c==. | ag_c04c==0
		rename ag_c04c Plot_Area
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
		
		
		foreach v of varlist  TLU {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			*replace `v'=m_`v' if `v'<50
			replace `v'=m_`v' if z_`v'>3
			replace `v'=m_`v' if z_`v'<-0.1
}
		drop z_* a_* m_*
		
				
		foreach v of varlist  TLU {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			*replace `v'=m_`v' if `v'<50
			replace `v'=m_`v' if z_`v'>3
			replace `v'=m_`v' if z_`v'<-0.1
}
		drop z_* a_* m_*
		
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
	
	
	**# 	output
use  "${`IHSnumber'}/ag_mod_g.dta" , clear 	
	
	merge m:1 case_id  using "${`IHSnumber'}/hh_mod_a_filt.dta" 
	
	keep if _merge ==3
	rename ag_g13a output
	rename ag_g13b unit 
	rename ag_g13c condition
	
	
	*keep if crop_code<=4
**# Bookmark #1
	
	replace output=output*51.6    if region==1  & crop_code==1  & unit==2   & condition==1
	replace output=output*46.07   if region==1  & crop_code==1  & unit==2   & condition>=2
	replace output=output*99.9    if region==1  & crop_code==1  & unit==3   & condition==1
	replace output=output*82.92   if region==1  & crop_code==1  & unit==3   & condition>=2
	replace output=output*4.45    if region==1  & crop_code==1  & unit==4   & condition==1
	replace output=output*18.7    if region==1  & crop_code==1  & unit==5   & condition==1
	replace output=output*14.98   if region==1  & crop_code==1  & unit==5   & condition>=2
	replace output=output*468     if region==1  & crop_code==1  & unit==12  & condition==1
	replace output=output*388.44  if region==1  & crop_code==1  & unit==12  & condition>=2
	replace output=output*10      if region==1  & crop_code==1  & unit==14  & condition==1
	replace output=output*51.6    if region==1  & crop_code==2  & unit==2   & condition==1
	replace output=output*46.07   if region==1  & crop_code==2  & unit==2   & condition>=2
	replace output=output*99.9    if region==1  & crop_code==2  & unit==3   & condition==1
	replace output=output*82.92   if region==1  & crop_code==2  & unit==3   & condition>=2
	replace output=output*4.45    if region==1  & crop_code==2  & unit==4   & condition==1
	replace output=output*18.7    if region==1  & crop_code==2  & unit==5   & condition==1
	replace output=output*14.98   if region==1  & crop_code==2  & unit==5   & condition>=2
	replace output=output*468     if region==1  & crop_code==2  & unit==12  & condition==1
	replace output=output*388.44  if region==1  & crop_code==2  & unit==12  & condition>=2
	replace output=output*10      if region==1  & crop_code==2  & unit==14  & condition==1
	replace output=output*51.6    if region==1  & crop_code==3  & unit==2   & condition==1
	replace output=output*46.07   if region==1  & crop_code==3  & unit==2   & condition>=2
	replace output=output*99.9    if region==1  & crop_code==3  & unit==3   & condition==1
	replace output=output*82.92   if region==1  & crop_code==3  & unit==3   & condition>=2
	replace output=output*4.45    if region==1  & crop_code==3  & unit==4   & condition==1
	replace output=output*18.7    if region==1  & crop_code==3  & unit==5   & condition==1
	replace output=output*14.98   if region==1  & crop_code==3  & unit==5   & condition>=2
	replace output=output*468     if region==1  & crop_code==3  & unit==12  & condition==1
	replace output=output*388.44  if region==1  & crop_code==3  & unit==12  & condition>=2
	replace output=output*10      if region==1  & crop_code==3  & unit==14  & condition==1
	replace output=output*51.6    if region==1  & crop_code==4  & unit==2   & condition==1
	replace output=output*46.07   if region==1  & crop_code==4  & unit==2   & condition>=2
	replace output=output*99.9    if region==1  & crop_code==4  & unit==3   & condition==1
	replace output=output*82.92   if region==1  & crop_code==4  & unit==3   & condition>=2
	replace output=output*4.45    if region==1  & crop_code==4  & unit==4   & condition==1
	replace output=output*18.7    if region==1  & crop_code==4  & unit==5   & condition==1
	replace output=output*14.98   if region==1  & crop_code==4  & unit==5   & condition>=2
	replace output=output*468     if region==1  & crop_code==4  & unit==12  & condition==1
	replace output=output*388.44  if region==1  & crop_code==4  & unit==12  & condition>=2
	replace output=output*10      if region==1  & crop_code==4  & unit==14  & condition==1
	replace output=output*50      if region==2  & crop_code==1  & unit==2   & condition==1
	replace output=output*44.23   if region==2  & crop_code==1  & unit==2   & condition>=2
	replace output=output*95.93   if region==2  & crop_code==1  & unit==3   & condition==1
	replace output=output*79.62   if region==2  & crop_code==1  & unit==3   & condition>=2
	replace output=output*5.29    if region==2  & crop_code==1  & unit==4   & condition==1
	replace output=output*3.83    if region==2  & crop_code==1  & unit==4   & condition>=2
	replace output=output*16.69   if region==2  & crop_code==1  & unit==5   & condition==1
	replace output=output*14.39   if region==2  & crop_code==1  & unit==5   & condition>=2
	replace output=output*468     if region==2  & crop_code==1  & unit==12  & condition==1
	replace output=output*682     if region==2  & crop_code==1  & unit==12  & condition>=2
	replace output=output*8.05    if region==2  & crop_code==1  & unit==14  & condition==1
	replace output=output*50      if region==2  & crop_code==2  & unit==2   & condition==1
	replace output=output*44.23   if region==2  & crop_code==2  & unit==2   & condition>=2
	replace output=output*95.93   if region==2  & crop_code==2  & unit==3   & condition==1
	replace output=output*79.62   if region==2  & crop_code==2  & unit==3   & condition>=2
	replace output=output*5.29    if region==2  & crop_code==2  & unit==4   & condition==1
	replace output=output*3.83    if region==2  & crop_code==2  & unit==4   & condition>=2
	replace output=output*16.69   if region==2  & crop_code==2  & unit==5   & condition==1
	replace output=output*14.39   if region==2  & crop_code==2  & unit==5   & condition>=2
	replace output=output*468     if region==2  & crop_code==2  & unit==12  & condition==1
	replace output=output*682     if region==2  & crop_code==2  & unit==12  & condition>=2
	replace output=output*8.05    if region==2  & crop_code==2  & unit==14  & condition==1
	replace output=output*50      if region==2  & crop_code==3  & unit==2   & condition==1
	replace output=output*44.23   if region==2  & crop_code==3  & unit==2   & condition>=2
	replace output=output*95.93   if region==2  & crop_code==3  & unit==3   & condition==1
	replace output=output*79.62   if region==2  & crop_code==3  & unit==3   & condition>=2
	replace output=output*5.29    if region==2  & crop_code==3  & unit==4   & condition==1
	replace output=output*3.83    if region==2  & crop_code==3  & unit==4   & condition>=2
	replace output=output*16.69   if region==2  & crop_code==3  & unit==5   & condition==1
	replace output=output*14.39   if region==2  & crop_code==3  & unit==5   & condition>=2
	replace output=output*468     if region==2  & crop_code==3  & unit==12  & condition==1
	replace output=output*682     if region==2  & crop_code==3  & unit==12  & condition>=2
	replace output=output*8.05    if region==2  & crop_code==3  & unit==14  & condition==1
	replace output=output*50      if region==2  & crop_code==4  & unit==2   & condition==1
	replace output=output*44.23   if region==2  & crop_code==4  & unit==2   & condition>=2
	replace output=output*95.93   if region==2  & crop_code==4  & unit==3   & condition==1
	replace output=output*79.62   if region==2  & crop_code==4  & unit==3   & condition>=2
	replace output=output*5.29    if region==2  & crop_code==4  & unit==4   & condition==1
	replace output=output*3.83    if region==2  & crop_code==4  & unit==4   & condition>=2
	replace output=output*16.69   if region==2  & crop_code==4  & unit==5   & condition==1
	replace output=output*14.39   if region==2  & crop_code==4  & unit==5   & condition>=2
	replace output=output*468     if region==2  & crop_code==4  & unit==12  & condition==1
	replace output=output*682     if region==2  & crop_code==4  & unit==12  & condition>=2
	replace output=output*8.05    if region==2  & crop_code==4  & unit==14  & condition==1
	replace output=output*51      if region==3  & crop_code==1  & unit==2   & condition==1
	replace output=output*44.27   if region==3  & crop_code==1  & unit==2   & condition>=2
	replace output=output*96.02   if region==3  & crop_code==1  & unit==3   & condition==1
	replace output=output*79.69   if region==3  & crop_code==1  & unit==3   & condition>=2
	replace output=output*5.25    if region==3  & crop_code==1  & unit==4   & condition==1
	replace output=output*18      if region==3  & crop_code==1  & unit==5   & condition==1
	replace output=output*14.73   if region==3  & crop_code==1  & unit==5   & condition>=2
	replace output=output*468     if region==3  & crop_code==1  & unit==12  & condition==1
	replace output=output*388.44  if region==3  & crop_code==1  & unit==12  & condition>=2
	replace output=output*8.94    if region==3  & crop_code==1  & unit==14  & condition==1
	replace output=output*51      if region==3  & crop_code==2  & unit==2   & condition==1
	replace output=output*44.27   if region==3  & crop_code==2  & unit==2   & condition>=2
	replace output=output*96.02   if region==3  & crop_code==2  & unit==3   & condition==1
	replace output=output*79.69   if region==3  & crop_code==2  & unit==3   & condition>=2
	replace output=output*5.25    if region==3  & crop_code==2  & unit==4   & condition==1
	replace output=output*18      if region==3  & crop_code==2  & unit==5   & condition==1
	replace output=output*14.73   if region==3  & crop_code==2  & unit==5   & condition>=2
	replace output=output*468     if region==3  & crop_code==2  & unit==12  & condition==1
	replace output=output*388.44  if region==3  & crop_code==2  & unit==12  & condition>=2
	replace output=output*8.94    if region==3  & crop_code==2  & unit==14  & condition==1
	replace output=output*51      if region==3  & crop_code==3  & unit==2   & condition==1
	replace output=output*44.27   if region==3  & crop_code==3  & unit==2   & condition>=2
	replace output=output*96.02   if region==3  & crop_code==3  & unit==3   & condition==1
	replace output=output*79.69   if region==3  & crop_code==3  & unit==3   & condition>=2
	replace output=output*5.25    if region==3  & crop_code==3  & unit==4   & condition==1
	replace output=output*18      if region==3  & crop_code==3  & unit==5   & condition==1
	replace output=output*14.73   if region==3  & crop_code==3  & unit==5   & condition>=2
	replace output=output*468     if region==3  & crop_code==3  & unit==12  & condition==1
	replace output=output*388.44  if region==3  & crop_code==3  & unit==12  & condition>=2
	replace output=output*8.94    if region==3  & crop_code==3  & unit==14  & condition==1
	replace output=output*51      if region==3  & crop_code==4  & unit==2   & condition==1
	replace output=output*44.27   if region==3  & crop_code==4  & unit==2   & condition>=2
	replace output=output*96.02   if region==3  & crop_code==4  & unit==3   & condition==1
	replace output=output*79.69   if region==3  & crop_code==4  & unit==3   & condition>=2
	replace output=output*5.25    if region==3  & crop_code==4  & unit==4   & condition==1
	replace output=output*18      if region==3  & crop_code==4  & unit==5   & condition==1
	replace output=output*14.73   if region==3  & crop_code==4  & unit==5   & condition>=2
	replace output=output*468     if region==3  & crop_code==4  & unit==12  & condition==1
	replace output=output*388.44  if region==3  & crop_code==4  & unit==12  & condition>=2
	replace output=output*8.94    if region==3  & crop_code==4  & unit==14  & condition==1

		keep case_id output gardenid plotid
		duplicates drop  case_id gardenid plotid, force 
		merge 1:1 case_id gardenid plotid using ``IHSnumber'ra', nogen
		
		tempfile `IHSnumber'rb
save   ``IHSnumber'rb', replace 


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
			
		collapse (sum) harvest Plot_Area output (max) TLU plating_pits traditional_tilage Terraces Water_harvest_bunds dry_season organic_fertilizer agro_forestry inorganic_fertilizer maize type quality erosion_control_bunds vetiver box_ridges minimum_tillage, by (case_id)
		
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
		



		tempfile save  `IHSnumber'combined
		save 	``IHSnumber'combined', replace
		
		save  "${workingfiles}/`IHSnumber'combined.dta", replace		

	


	do "${dofiles}/03_`IHSnumber'climate.do" 
	
	
*save  "${workingfiles}/`IHSnumber'combined.dta", replace	

**# 	Data Construction 
		
*ooutliers
		foreach v of varlist  output {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if `v'<50
			replace `v'=m_`v' if z_`v'>3
			replace `v'=m_`v' if z_`v'<-0.02
}
		drop z_* a_* m_*
		
		
foreach v of varlist  output {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if `v'<50
			replace `v'=m_`v' if z_`v'>3
			*replace `v'=m_`v' if z_`v'<-0.1
}
		drop z_* a_* m_*
	
	g productivity=output/Plot_Area
	
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
	la define combined 0 "None" 1 "Both" 2 "Fisp" 3 "Saps"
	la define gender 1 "Male" 0 "Female"
	la define YN 1 "Yes" 0 "No"
	la define reside1 1 "urban" 0 "rural"
	la define marital 1 "Married" 2 "Separated/Divorced" 3 "Widowed" 4 "Never"
	la define type 1 "Sandy" 2 "Between" 3 "Clay"
	la define quality 1 "Good" 2 "Fair" 3 "Poor"
	
	
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
	
	/*
	foreach i in `IHSnumber'continous {
			table  ( var) (), statistic(mean $`i') statistic(sd $`i')  nformat(%9.2fc mean sd )  sformat("(%s)" sd)  
			collect preview
			collect style header result, level(hide)
			collect style showbase off
			collect style putdocx, layout(autofitcontents)
			collect export `i'.docx, as(docx) replace
	}


		foreach i in `IHSnumber'categorical  {
			table  ( var) (), statistic(fvfrequency $`i') statistic(fvpercent $`i')  nformat(%9.0fc fvfrequency  ) ///
			nformat(%9.2fc fvpercent )sformat("(%s)" sd)   sformat("%s%%" fvpercent)
			collect preview
			collect style showbase off
			collect style header result, level(hide)
			collect style putdocx, layout(autofitcontents)
			collect export `i'.docx, as(docx) replace
	}

	

			
	foreach category in fisp_saps input_subsidy saps {
		
			foreach i in `IHSnumber'continous {
					table  ( var) () if `category'==1, statistic(mean $`i')  nformat(%9.2fc mean )  
					collect preview
					collect style header result, level(hide)
					collect style showbase off
					collect style putdocx, layout(autofitcontents)
					collect export `category'_`IHSnumber'continous.docx, as(docx) replace
			}


		foreach i in `IHSnumber'categorical  {
					table  ( var) () if `category'==1,  statistic(fvpercent $`i')   ///
					nformat(%9.2fc fvpercent )  sformat("%s%%" fvpercent)
					collect preview
					collect style showbase off
					collect style header result, level(hide)
					collect style showbase off
					collect preview
					collect style putdocx, layout(autofitcontents)
					collect export `category'_`IHSnumber'categorical.docx, as(docx) replace
			}
	 	}	

		*/
		
		
		/*Instructions from Venkatanarayana Motkuri Centre for Economic and Social Studies) were used


Consider a population of persons (or households ...), i = 1,...,n, 
with income y_i, and weight w_i. Let f_i = w_i/N, where 
    i=n
N = SUM(w_i). When the data are unweighted, w_i = 1 and N = n. 
    i=1
The poverty line is z, and the poverty gap for person i is max(0, z-y_i). 
Suppose there is an exhaustive partition of the population into 
mutually-exclusive subgroups k = 1,...,K.

The FGT class of poverty indices is given by
                  
                   i=n             
        FGT(a) =   SUM (f_i).(I_i).[(z-y_i)/z)]^a
                   i=1             

where I_i = 1 if y_i < z and I_i = 0 otherwise.
*/

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
	
		foreach v of varlist  HDDS {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<1.3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>1.3 & combined!=1
}

		drop z_* a_* m_*
	
		foreach v of varlist  FCS {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
		replace `v'=m_`v' if z_`v'>3 & combined!=1
}

		drop z_* a_* m_*
	
		foreach v of varlist  FCS {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'<-1.9 & combined==1
		replace `v'=m_`v' if z_`v'>3 & combined!=1
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
			replace `v'=m_`v' if z_`v'>3 & combined!=1 
}

		drop z_* a_* m_*
		
		foreach v of varlist  productivity {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>3 & combined==0
}

		drop z_* a_* m_*
		foreach var of varlist productivity avr_long_tmp2019 avr_long_pre2019 avr_yearly_tmp2019 avr_yearly_pre2019 HDDS FCS  {
		g l_`var'=ln(`var')
	}
	

	*This to be restructured
	
	/*foreach dependent in productivity FCS HDDS  {
		foreach class in  0 1 2 3 {
			g		`dependent'`class'=`dependent' 		if `class'==combined
			replace `dependent'`class'=. 				if `class'!=combined
			g		l_`dependent'`class'=l_`dependent' 	if `class'==combined
			replace l_`dependent'`class'=. 				if `class'!=combined
		}
	}
	*/	
	do "${dofiles}/04_var_labels.do" 	
	
	save "${workingfiles}/`IHSnumber'Proposal_Data.dta",replace
	
	}
	
****************************************************************************
* End of do file
****************************************************************************