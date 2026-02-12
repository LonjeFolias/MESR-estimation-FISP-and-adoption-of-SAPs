   /******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
		Data cleans and manages expenditure data
		This do-file loops over IHS IV and IHS V so that the cleaning 
		can be performed simultaneously.
   *               														  *                                
   *				Author : Lonjezo Erick Folias                         *
   *				Number : 0992 888 003   							  *
   *				Email  : lonjefolias@hotmail.com					  *
   * ******************************************************************** *
   * ******************************************************************** */
	
 
global ihsivlock ihsiv // a lock to apply for IHS4 only, 
///in instances where there are different variable or datafile names


foreach IHSnumber in ihsv {	
	
	**# 	Food expenditure	
	use 	"${`IHSnumber'}/HH_MOD_G1.dta", clear
			keep  		case_id 	hh_g05  		hh_g02
			reshape 	wide 		hh_g05, 		i (case_id) j (hh_g02)
			egen 		food_exp=	rowtotal(hh_g*)
			keep 		case_id 	food_exp
			
			tempfile `IHSnumber'exp_a
	save  	``IHSnumber'exp_a', replace 	
			
	**# 	Non-Food Week Expenditure		
	use 	"${`IHSnumber'}/HH_MOD_I1.dta", clear
			keep 		case_id 	hh_i02 			hh_i03 
			reshape		wide 		hh_i03, 		i (case_id) j (hh_i02)
			egen 		week_exp=	rowtotal(hh_i*)
			replace 	week_exp=	week_exp*4*12 	// An average annual expenditure !
			keep 		case_id 	week_exp
			merge 		1:1 		case_id 		using ``IHSnumber'exp_a', nogen
			
			tempfile `IHSnumber'exp_b
	save  	``IHSnumber'exp_b', replace 	
			
			
	**# 	Non-Food Month Expenditure	
	use 	"${`IHSnumber'}/HH_MOD_I2.dta", clear
			keep 		case_id 	hh_i05 			hh_i06
			reshape 	wide 		hh_i06, 		i (case_id) j (hh_i05)
			egen 		month_exp=	rowtotal(hh_i*)
			keep 		case_id 	month_exp
			replace 	month_exp=	month_exp*12  // An average annual expenditure !
			merge 		1:1 		case_id using  ``IHSnumber'exp_b', nogen
			
			tempfile `IHSnumber'exp_c
	save  	``IHSnumber'exp_c', replace 

	**# 	Non-Food 3-Month  Expenditure	
	use "${`IHSnumber'}/HH_MOD_J.dta", clear
			keep 		case_id 	hh_j02 		hh_j03 
			reshape 	wide 		hh_j03 , 	i (case_id) j (hh_j02)
			egen 		quater_exp=	rowtotal(hh_j*)
			replace 	quater_exp=	quater_exp*4 // An average annual expendJture !
			keep 		case_id 	quater_exp
			merge 		1:1 		case_id  using 	``IHSnumber'exp_c', nogen
			
			tempfile `IHSnumber'exp_d
	save  ``IHSnumber'exp_d', replace 	
			
	**#12-Month  Expenditure
	use "${`IHSnumber'}/HH_MOD_K1.dta", clear
			keep 		case_id 	hh_k02 		hh_k03
			reshape 	wide 		hh_k03, i 	(case_id) j (hh_k02)
			egen 		annual_exp=	rowtotal(hh_k*)
			keep 		case_id 	annual_exp
			merge 		1:1 		case_id  using 	``IHSnumber'exp_d', nogen
			
			
			tempfile `IHSnumber'exp_f
			
	save  	``IHSnumber'exp_f', replace 	
			
			**#12-Month  Expenditure
	use "${`IHSnumber'}/HH_MOD_K2.dta", clear
			keep 		case_id 	hh_k02 		hh_k04
			reshape 	wide 		hh_k04, i 	(case_id) j (hh_k02)
			egen 		annual2_exp=rowtotal(hh_k*)
			keep 		case_id 	annual2_exp
			merge 		1:1 		case_id using	``IHSnumber'exp_f', nogen
			
			tempfile `IHSnumber'exp_g
	save   	``IHSnumber'exp_g', replace 	
			
			
			**#durable 12-Month  Expenditure
	use "${`IHSnumber'}/HH_MOD_L.dta", clear
			keep 		case_id 	hh_l02 		hh_l07
			reshape 	wide 		hh_l07, 	i (case_id) j (hh_l02)
			egen 		durable_exp=rowtotal(hh_l*)
			keep 		case_id 	durable_exp
			merge 		1:1 		case_id 	using 	``IHSnumber'exp_g', nogen
			
			tempfile `IHSnumber'exp_h
	save  	``IHSnumber'exp_h', replace 	
			
			**#farm machinary 12-Month  Expenditure
	use "${`IHSnumber'}/HH_MOD_M.dta", clear	
			egen 		exp=		rowtotal(hh_m09 hh_m06)
			keep 		case_id 	hh_m0b 		case_id  exp
			reshape 	wide exp, i (case_id) 	j (hh_m0b)
			egen 		m_exp=		rowtotal(exp*)
			keep 		case_id 	m_exp
			merge 		1:1 		case_id 	using ``IHSnumber'exp_h', nogen
			
			
			tempfile `IHSnumber'exp_j
	save  	``IHSnumber'exp_j', replace 		
			
			
			*iF NECCESSARY ADD HH enterprises please !!!!
			
			**#Education 12-Month  Expenditure
	use "${`IHSnumber'}/hh_mod_c.dta", clear		
			keep 		hh_c22j 	case_id 	PID
			reshape 	wide 		hh_c22j, 	i(case_id) j (PID)
			egen 		edu_exp=	rowtotal(hh_c*)
			keep 		case_id 	edu_exp
			merge 		1:1 		case_id 	using ``IHSnumber'exp_j', nogen
			
			tempfile `IHSnumber'exp_k
	save  	``IHSnumber'exp_k', replace 		
			
			
			**#Health   Expenditure
	use "${`IHSnumber'}/hh_mod_d.dta", clear		
			
			foreach i 		of 		varlist 	hh_d11 	hh_d12 {
					replace `i'=`i'	*12
			}
			
			egen 	health_exp		=rowtotal( hh_d11 hh_d12  hh_d12_1 hh_d14 hh_d15 hh_d16 hh_d19 hh_d10 hh_d21 hh_d48)
			keep 	health_exp 		case_id PID
			reshape wide health_exp,i(case_id) j (PID)
			egen 	health_exp=		rowtotal(health_exp*)
			keep 	case_id 		health_exp
			
			merge 1:1 case_id using ``IHSnumber'exp_k', nogen
				
			tempfile `IHSnumber'exp_l
	save  	``IHSnumber'exp_l', replace 		
						
			*egen exp=rowtotal( health_exp edu_exp m_exp durable_exp annual2_exp annual_exp quater_exp month_exp week_exp food_exp)
			*p
			*#Housing   Expenditure
			
	use "${`IHSnumber'}/hh_mod_f.dta", clear	
		
			replace hh_f04a= 	hh_f04a
			replace hh_f04a= 	hh_f04a*365 	if 		hh_f04b==3
			replace hh_f04a= 	hh_f04a*12 		if 		hh_f04b==5
				
			replace hh_f18=		hh_f18*4*12
				
			replace hh_f25=		((360/hh_f26a)*	hh_f25) if  		hh_f26b==3
			replace hh_f25=		((48/hh_f26a)*	hh_f25) if  		hh_f26b==4
			replace hh_f25=		((12/hh_f26a)*	hh_f25) if  		hh_f26b==5

			replace hh_f32=		((360/hh_f33a)*	hh_f32) if  		hh_f33b==3
			replace hh_f32=		((48/hh_f33a)*	hh_f32) if  		hh_f33b==4
			replace hh_f32=		((12/hh_f33a)*	hh_f32) if  		hh_f33b==5
			
			replace hh_f35=		hh_f35*12 
			egen housing_exp=	rowtotal( hh_f04a hh_f04_4 hh_f04_6 hh_f18 hh_f25 hh_f32 hh_f35)
			keep case_id 		housing_exp
			
			merge 1:1 case_id using ``IHSnumber'exp_l', nogen
			
			egen exp=rowtotal(housing_exp health_exp edu_exp m_exp durable_exp annual2_exp annual_exp quater_exp month_exp week_exp food_exp)
			drop *_exp
			
			tempfile `IHSnumber'exp_o
	save  	``IHSnumber'exp_o', replace 	
	save "${workingfiles}/`IHSnumber'exp_o.dta", replace 
	
}
