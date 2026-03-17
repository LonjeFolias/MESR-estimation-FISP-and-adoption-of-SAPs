

global socio 		age 		gender 		educ 					hh_Size
global insitutional extension 	credit	
global farmlevel 	type2 		type3 		quality2 				quality3
global weather  	l_avr_yearly_tmp2019   	l_avr_yearly_pre2019
global selection	
global eq			$socio		$insitutional		$farmlevel		$weather 	
  
	foreach command of local user_commands {
		   cap which `command'
		   if _rc == 111 {
			   ssc install `command'
		   }
	 }

*use "${workingfiles}/IHSVProposal_Data.dta", clear

g 		combined_fisp_saps=4 if combined==0 

replace combined_fisp_saps=1 if combined==2
replace combined_fisp_saps=2 if combined==3
replace combined_fisp_saps=3 if combined==1


	

la define new 1 "Fisp" 2 "Saps" 3 "Both" 4 "None"
la val combined_fisp_saps new

rename ( input_subsidy IV_input_subsidy) ( fisp IV_fisp  )
g l_harvest =ln(harvest)

	foreach dependent in productivity FCS HDDS  harvest {
		foreach class in  1 2 3 4 {
			g		`dependent'`class'=`dependent' 		if `class'==combined_fisp_saps
			replace `dependent'`class'=. 				if `class'!=combined_fisp_saps
			g		l_`dependent'`class'=l_`dependent' 	if `class'==combined_fisp_saps
			replace l_`dependent'`class'=. 				if `class'!=combined_fisp_saps
		}
	}


save "${workingfiles}/working data.dta", replace 


use "${workingfiles}/working data.dta", clear




*Creating variables for each regime
	
	foreach i in socio insitutional farmlevel selection 	weather {

	foreach var of global `i'		 {

			forvalues category = 1/4 {
				g  `var'`category'=`var' if combined_fisp_saps==`category'
				replace `var'`category'=. if combined_fisp_saps!=`category'
		}

	}	

}

g agesq=age*age


foreach i in plating_pits traditional_tilage Terraces Water_harvest_bunds dry_season organic_fertilizer agro_forestry inorganic_fertilizer erosion_control_bunds vetiver box_ridges minimum_tillage {
	la var `i' "if the household used `i'"
}

   

foreach outcome in productivity FCS HDDS {
	foreach category in 1 2 3 4 {
		if `category'==1 {
			la var `outcome'`category' " `outcome' score for fisp beneficiaries"
		}
		
		if `category'==2 {
			la var `outcome'`category' " `outcome' score for saps users"
		}
		
		if `category'==3 {
			la var `outcome'`category' " `outcome' score for HHs that are both fisp beneficiaries & saps users"
		}
		
		if `category'==4 {
			la var `outcome'`category' " `outcome' score for HHs that are neither fisp beneficiaries  nor saps users"
		}	
		
	}
}




foreach outcome in productivity FCS HDDS {
	la var `outcome' "HH `outcome' score"
}

*la define type 1 "Sandy" 2 "Loam" 3 "Clay" 
*ta la define quality 1 "Good" 2 "Fair" 3 "Poor" 
la val type type
la val quality quality

la var drought "if the household exprienced drought in the past 3 farming seasons"
la var fisp "if the household was a fisp beneficiary"
la var educ "years spent on formal education by the HH head"
la var hh_Size "HH size"
la var saps "if the household used saps"
la var type "Predominant Soil Type on Plot"
la var quality "Soil quality of Plot"
la var type1 "Predominant Soil = Sandy"
la var type2 "Predominant Soil = Loam"
la var type3 "Predominant Soil = Clay"
la var quality1 "Soil quality = Good"
la var quality2 "Soil quality = Fair"
la var quality3 "Soil quality = Poor"
la var IV_fisp  "Proportional of fisp HH beneficieries in the EA"
la var IV_saps  "Proportional of sap HH users in the EA"
la var IV_fisp_saps  "Proportional of HH who are  are both fisp beneficiaries & saps users in the EA"



foreach i in age gender {
		la var `i' "`i' of the HH head"
}

foreach i in off_farm TLU com_cd70{
	recode `i' (.=0)
}

rename com_cd70 mp

g none=1 if  combined_fisp_saps==4

recode none (.=0)

		foreach i of varlist none {
			
			clonevar x_`i'=`i'
			recode x_`i' (0=.)
			bysort district : egen a_`i'=count(x_`i')
			bysort district : egen b_`i'=count(district)
			g IV_`i'=a_`i'/b_`i'

		}
		
 	drop x_* a_*  b_*

la var none "HHs that were neither fisp beneficiaries  nor saps users"
la var combined "HH that were  both fisp beneficiaries & saps users"
la var l_avr_yearly_tmp2019  "log for yearly average temp"
la var l_avr_yearly_pre2019 "log for yearly average prec"
la var FGT0 "Poverty headcount"
la var extension "Access to agricultural extension services"
la var IV_none "Proportional of HH who are neither fisp beneficiaries nor saps users in the EA"

drop FCSa

la var agesq "Age squared"
la var TLU "Tropical Livestock Unit"
la var off_farm "Off farm actoivities"

recode  com_cd71 (.=0)

/*
g combined=1 	if 		combined_fisp_saps==3

foreach i in combined fisp saps none {
		recode `i' (.=0)
}
*/

la var combined "if the HH is both a fisp beneficiary and use saps "



		g shock=.
		
		foreach i in drought floods {
			replace shock=1 if `i'==1
		}

		recode shock (.=0)
		
		
keep case_id hh_wgt ea_id gender $FoodSecurity_eq  $mprobit productivity* FCS* HDDS* region district reside hh_wgt TAs fisp  saps type1 type2 type3 quality1 quality2 quality3 IV_fisp IV_saps IV_fisp_saps FGT0 $selection plating_pits traditional_tilage Terraces Water_harvest_bunds dry_season organic_fertilizer agro_forestry inorganic_fertilizer erosion_control_bunds vetiver box_ridges minimum_tillage type quality Plot_Area output 	avr_yearly_tmp2019 avr_yearly_pre2019 fisp_saps none IV_none $eq1 $eq2 $eq3 $eq4 l_* mp com_cd71 years_village harves* TLU off_farm FCS age* dependency drought floods FGT1  $saps  combined_fisp_saps marital1 marital2 marital3  marital4 shock extension dependency educ hh_Size  $insitutional $eq

la var shock "if the HH exprienced shock in the past 3 agri. seasons"

save "${workingfiles}/final esr data.dta", replace







iecodebook template "${workingfiles}/final esr data.dta" ///
    using "$result/codebook.xlsx" ///
    , surveys( hh_level_data ) replace
	
iecodebook export ///
    using "$result/codebook.xlsx", ///
    replace 
	
	
	