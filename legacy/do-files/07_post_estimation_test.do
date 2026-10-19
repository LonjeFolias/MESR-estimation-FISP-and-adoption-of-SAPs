/**********************************************************************
IV DIAGNOSTIC TESTS FOR MESR MODEL
Purpose:
1) Test instrument relevance in the treatment-selection equation
2) Test the exclusion restriction in the outcome equations

Treatment regimes:
1 = FISP only
2 = SAPs only
3 = FISP + SAPs
4 = Neither (reference)

Excluded instruments:
IV_fisp
IV_saps
IV_fisp_saps
IV_none
**********************************************************************/


set more off


use "${workingfiles}/final esr data.dta", clear  
*--------------------------------------------------------------------*
* 0. Survey design
*--------------------------------------------------------------------*
svyset case_id [pweight=hh_wgt], strata(ea_id) singleunit(centered)


*--------------------------------------------------------------------*
* 1. TEST OF INSTRUMENT RELEVANCE
*    (Do instruments predict treatment participation?)
*--------------------------------------------------------------------*

svy: mprobit combined_fisp_saps ///
    gender agesq educ hh_Size marital2 marital3 marital4 TLU shock ///
    off_farm FGT0 credit avr_yearly_pre2019 avr_yearly_tmp2019 ///
    type2 type3 quality2 quality3 ///
    IV_fisp IV_saps IV_fisp_saps IV_none, baseoutcome(4)

* Joint significance of excluded instruments
test IV_fisp IV_saps IV_fisp_saps IV_none

display "----------------------------------------------------"
display "IV relevance test completed"
display "----------------------------------------------------"



*--------------------------------------------------------------------*
* 2. REGIME-SPECIFIC RELEVANCE CHECKS (auxiliary binary models)
*--------------------------------------------------------------------*

gen reg1 = combined_fisp_saps==1
gen reg2 = combined_fisp_saps==2
gen reg3 = combined_fisp_saps==3

* FISP only
probit reg1 ///
    gender agesq educ hh_Size marital2 marital3 marital4 TLU shock ///
    off_farm FGT0 credit avr_yearly_pre2019 avr_yearly_tmp2019 ///
    type2 type3 quality2 quality3 ///
    IV_fisp IV_saps IV_fisp_saps  ///
    [pw=hh_wgt], vce(robust)

test IV_fisp IV_saps IV_fisp_saps 


* SAPs only
probit reg2 ///
    gender agesq educ hh_Size marital2 marital3 marital4 TLU shock ///
    off_farm FGT0 credit avr_yearly_pre2019 avr_yearly_tmp2019 ///
    type2 type3 quality2 quality3 ///
    IV_fisp IV_saps IV_fisp_saps  ///
    [pw=hh_wgt], vce(robust)

test IV_fisp IV_saps IV_fisp_saps


* FISP + SAPs
probit reg3 ///
    gender agesq educ hh_Size marital2 marital3 marital4 TLU shock ///
    off_farm FGT0 credit avr_yearly_pre2019 avr_yearly_tmp2019 ///
    type2 type3 quality2 quality3 ///
    IV_fisp IV_saps IV_fisp_saps  ///
    [pw=hh_wgt], vce(robust)

test IV_fisp IV_saps IV_fisp_saps 


display "----------------------------------------------------"
display "Regime-specific IV relevance tests completed"
display "----------------------------------------------------"



*--------------------------------------------------------------------*
* 3. TEST OF EXCLUSION RESTRICTION
*    (IVs should not directly affect outcomes)
*--------------------------------------------------------------------*

*------------------------------------------------*
* Productivity equation
*------------------------------------------------*

reg productivity ///
    gender agesq educ hh_Size marital2 marital3 marital4 TLU shock ///
    FGT0 years_village credit drought avr_yearly_pre2019 avr_yearly_tmp2019 ///
    type2 type3 quality2 quality3 mp extension   ///
    IV_fisp IV_saps IV_fisp_saps  

test IV_fisp IV_saps IV_fisp_saps 



*------------------------------------------------*
* Food Consumption Score (FCS)
*------------------------------------------------*

reg FCS ///
    gender agesq educ hh_Size marital2 marital3 marital4 TLU shock ///
    FGT0 years_village credit avr_yearly_pre2019 avr_yearly_tmp2019 ///
    mp extension   ///
    IV_fisp IV_saps IV_fisp_saps  ///
	[pw=hh_wgt], vce(robust)
	
test IV_fisp IV_saps IV_fisp_saps




display "----------------------------------------------------"
display "IV exclusion restriction tests completed"
display "----------------------------------------------------"



*--------------------------------------------------------------------*
* 4. STRONGER FALSIFICATION TEST
*    Test exclusion among non-participants only
*--------------------------------------------------------------------*

reg productivity ///
    gender agesq educ hh_Size marital2 marital3 marital4 TLU shock ///
    FGT0 years_village credit drought avr_yearly_pre2019 avr_yearly_tmp2019 ///
    type2 type3 quality2 quality3 ///
    IV_fisp IV_saps IV_fisp_saps  ///
    if combined_fisp_saps==4 

test IV_fisp IV_saps IV_fisp_saps 

reg FCS ///
    gender agesq educ hh_Size marital2 marital3 marital4 TLU shock ///
    FGT0 years_village credit avr_yearly_pre2019 avr_yearly_tmp2019 ///
    mp extension   ///
    IV_fisp IV_saps IV_fisp_saps  ///
	if combined_fisp_saps==4 
	
test IV_fisp IV_saps IV_fisp_saps



display "----------------------------------------------------"
display "Additional falsification test completed"
display "----------------------------------------------------"