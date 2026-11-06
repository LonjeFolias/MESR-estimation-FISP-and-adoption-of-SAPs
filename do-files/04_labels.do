/* Complete variable labels, audited against 8,084 households and 232 fields.
   Run on an already constructed dataset, or at the END of 01_data_cleaning.do.
   Safe to rerun. Values, missing values, storage types and variable order stay intact.
   Legacy regime suffixes: 1=FISP only, 2=SAPs only, 3=both, 4=neither.
*/
version 17
capture confirm variable case_id
if !_rc label variable case_id "Unique household identifier"
capture confirm variable HHID
if !_rc label variable HHID "Survey Solutions household identifier"
capture confirm variable ea_id
if !_rc label variable ea_id "Enumeration area identifier"
capture confirm variable sales
if !_rc label variable sales "Total reported maize sales value (MK)"
capture confirm variable sold
if !_rc label variable sold "Household sold maize (1=yes)"
capture confirm variable harvest
if !_rc label variable harvest "Total reported maize harvest value (MK)"
capture confirm variable Plot_Area
if !_rc label variable Plot_Area "Total plot area in original household construction (acres)"
capture confirm variable output
if !_rc label variable output "Total physical maize harvest (kg)"
capture confirm variable output_kg_missing
if !_rc label variable output_kg_missing "At least one maize record lacks usable kg output (1=yes)"
capture confirm variable harvest_unit_reclassified
if !_rc label variable harvest_unit_reclassified "At least one harvest unit description reclassified (1=yes)"
capture confirm variable TLU
if !_rc label variable TLU "Household livestock holdings (tropical livestock units)"
capture confirm variable plating_pits
if !_rc label variable plating_pits "Household used planting pits (1=yes)"
capture confirm variable traditional_tilage
if !_rc label variable traditional_tilage "Household used traditional ridging (1=yes)"
capture confirm variable Terraces
if !_rc label variable Terraces "Household used terraces (1=yes)"
capture confirm variable Water_harvest_bunds
if !_rc label variable Water_harvest_bunds "Household used water-harvesting bunds (1=yes)"
capture confirm variable dry_season
if !_rc label variable dry_season "Household cultivated maize in the dry season (1=yes)"
capture confirm variable organic_fertilizer
if !_rc label variable organic_fertilizer "Household used organic fertilizer (1=yes)"
capture confirm variable agro_forestry
if !_rc label variable agro_forestry "Household practised agroforestry (1=yes)"
capture confirm variable inorganic_fertilizer
if !_rc label variable inorganic_fertilizer "Household used inorganic fertilizer (1=yes)"
capture confirm variable maize
if !_rc label variable maize "Household cultivated maize (1=yes)"
capture confirm variable type
if !_rc label variable type "Household soil-type category (legacy plot aggregation)"
capture confirm variable quality
if !_rc label variable quality "Household soil-quality category (legacy plot aggregation)"
capture confirm variable erosion_control_bunds
if !_rc label variable erosion_control_bunds "Household used erosion-control bunds (1=yes)"
capture confirm variable vetiver
if !_rc label variable vetiver "Household used vetiver grass for erosion control (1=yes)"
capture confirm variable box_ridges
if !_rc label variable box_ridges "Household used tied or box ridges (1=yes)"
capture confirm variable minimum_tillage
if !_rc label variable minimum_tillage "Household used minimum tillage (1=yes)"
capture confirm variable fisp
if !_rc label variable fisp "Household received input subsidy coupons (1=yes)"
capture confirm variable input_subsidy
if !_rc label variable input_subsidy "Household received input subsidy coupons (1=yes)"
capture confirm variable extension
if !_rc label variable extension "Received agricultural advice (legacy indicator; 1=yes)"
capture confirm variable ag_t0a
if !_rc label variable ag_t0a "Highest advice-topic code reported (legacy max aggregation)"
capture confirm variable ag_t02
if !_rc label variable ag_t02 "Highest advice-source code reported (legacy max aggregation)"
capture confirm variable credit
if !_rc label variable credit "Household reported borrowing on credit (1=yes)"
capture confirm variable dist_agmrkt
if !_rc label variable dist_agmrkt "Distance to agricultural market (km)"
capture confirm variable dist_admarc
if !_rc label variable dist_admarc "Distance to ADMARC market (km)"
capture confirm variable af_bio_1_x
if !_rc label variable af_bio_1_x "Annual mean temperature (degrees Celsius; already divided by 10)"
capture confirm variable af_bio_12_x
if !_rc label variable af_bio_12_x "Annual precipitation from IHS5 geovariables (mm)"
capture confirm variable GPS_lat
if !_rc label variable GPS_lat "Original displaced household/EA latitude (degrees)"
capture confirm variable GPS_lon
if !_rc label variable GPS_lon "Original displaced household/EA longitude (degrees)"
capture confirm variable ea_lon_mod
if !_rc label variable ea_lon_mod "Original modified EA longitude from geovariables (degrees)"
capture confirm variable ea_lat_mod
if !_rc label variable ea_lat_mod "Original modified EA latitude from geovariables (degrees)"
capture confirm variable drought
if !_rc label variable drought "Reported drought shock in original shock module (1=yes)"
capture confirm variable floods
if !_rc label variable floods "Reported flood shock in original shock module (1=yes)"
capture confirm variable irregularrains
if !_rc label variable irregularrains "Reported irregular-rainfall shock (legacy construction; 1=yes)"
capture confirm variable FCS
if !_rc label variable FCS "Food consumption score from seven-day food frequencies"
capture confirm variable HDDS
if !_rc label variable HDDS "Ten-group seven-day food-diversity proxy (not standard 24h HDDS)"
capture confirm variable FCSa
if !_rc label variable FCSa "Food consumption score category (legacy thresholds)"
capture confirm variable mp
if !_rc label variable mp "MP residence: legacy 1=yes, 2=no, 0=missing recoded"
capture confirm variable com_cd71
if !_rc label variable com_cd71 "MP visit in past 3 months: legacy 1=yes, 2=no, 0=missing recoded"
capture confirm variable region
if !_rc label variable region "Household region"
capture confirm variable district
if !_rc label variable district "Household district"
capture confirm variable reside
if !_rc label variable reside "Household residence: 1=urban, 0=rural"
capture confirm variable hh_wgt
if !_rc label variable hh_wgt "Household sampling weight"
capture confirm variable TAs
if !_rc label variable TAs "Traditional authority code"
capture confirm variable educ
if !_rc label variable educ "Head highest class attended (legacy code; 0 also includes missing)"
capture confirm variable age
if !_rc label variable age "Household head age (years)"
capture confirm variable agesq
if !_rc label variable agesq "Household head age squared (years squared)"
capture confirm variable hh_Size
if !_rc label variable hh_Size "Number of household members"
capture confirm variable alduts
if !_rc label variable alduts "Number of household members aged 15 or older (legacy name)"
capture confirm variable years_village
if !_rc label variable years_village "Head years living in village (legacy age fallback applied)"
capture confirm variable marital
if !_rc label variable marital "Household head marital-status category"
capture confirm variable dependency
if !_rc label variable dependency "Members aged 0-14 or 65+ divided by members aged 15-64"
capture confirm variable gender
if !_rc label variable gender "Household head sex: 1=male, 0=female"
capture confirm variable exp
if !_rc label variable exp "Legacy total expenditure aggregate (MK; original construction)"
capture confirm variable off_farm
if !_rc label variable off_farm "Household off-farm enterprise/activity indicator (1=yes)"
capture confirm variable lat
if !_rc label variable lat "Nearest CRU climate-grid latitude (degrees)"
capture confirm variable lon
if !_rc label variable lon "Nearest CRU climate-grid longitude (degrees)"
capture confirm variable avr_long_tmp2019
if !_rc label variable avr_long_tmp2019 "2015-2022 mean monthly temperature (CRU; degrees Celsius)"
capture confirm variable avr_long_pre2019
if !_rc label variable avr_long_pre2019 "2015-2022 mean monthly precipitation (CRU; mm)"
capture confirm variable avr_yearly_tmp2019
if !_rc label variable avr_yearly_tmp2019 "2019 mean monthly temperature (CRU; degrees Celsius)"
capture confirm variable avr_yearly_pre2019
if !_rc label variable avr_yearly_pre2019 "2019 mean monthly precipitation (CRU; mm)"
capture confirm variable productivity
if !_rc label variable productivity "Physical maize harvest divided by plot area (kg/acre)"
capture confirm variable saps
if !_rc label variable saps "Household used at least one of the six defined SAPs (1=yes)"
capture confirm variable fisp_saps
if !_rc label variable fisp_saps "Household used FISP or SAPs, including both (1=yes)"
capture confirm variable combined
if !_rc label variable combined "Original regime: 0=neither, 1=both, 2=FISP, 3=SAPs"
capture confirm variable marital1
if !_rc label variable marital1 "Head marital status: married (1=yes)"
capture confirm variable marital2
if !_rc label variable marital2 "Head marital status: separated or divorced (1=yes)"
capture confirm variable marital3
if !_rc label variable marital3 "Head marital status: widowed (1=yes)"
capture confirm variable marital4
if !_rc label variable marital4 "Head marital status: never married (1=yes)"
capture confirm variable type1
if !_rc label variable type1 "Soil type: sandy (1=yes)"
capture confirm variable type2
if !_rc label variable type2 "Soil type: intermediate/loam (legacy category; 1=yes)"
capture confirm variable type3
if !_rc label variable type3 "Soil type: clay (1=yes)"
capture confirm variable quality1
if !_rc label variable quality1 "Soil quality: good (1=yes)"
capture confirm variable quality2
if !_rc label variable quality2 "Soil quality: fair (1=yes)"
capture confirm variable quality3
if !_rc label variable quality3 "Soil quality: poor (1=yes)"
capture confirm variable region1
if !_rc label variable region1 "Household located in Northern region (1=yes)"
capture confirm variable region2
if !_rc label variable region2 "Household located in Central region (1=yes)"
capture confirm variable region3
if !_rc label variable region3 "Household located in Southern region (1=yes)"
capture confirm variable IV_fisp
if !_rc label variable IV_fisp "District share of households using FISP (legacy candidate)"
capture confirm variable IV_input_subsidy
if !_rc label variable IV_input_subsidy "District share of households using FISP (legacy candidate)"
capture confirm variable IV_saps
if !_rc label variable IV_saps "District share of households using SAPs (legacy candidate)"
capture confirm variable IV_fisp_saps
if !_rc label variable IV_fisp_saps "District share using FISP or SAPs, including both (legacy candidate)"
capture confirm variable IV_none
if !_rc label variable IV_none "District share using neither FISP nor SAPs (legacy candidate)"
capture confirm variable FGT0
if !_rc label variable FGT0 "Expenditure below legacy threshold of MK 165879 (1=yes)"
capture confirm variable FGT1
if !_rc label variable FGT1 "Legacy poverty-gap contribution, scaled by 1000/2100"
capture confirm variable FGT2
if !_rc label variable FGT2 "Legacy squared poverty-gap contribution, scaled by 1000/2100"
capture confirm variable combined_fisp_saps
if !_rc label variable combined_fisp_saps "Legacy regime: 1=FISP only, 2=SAPs only, 3=both, 4=neither"
capture confirm variable none
if !_rc label variable none "Household used neither FISP nor SAPs (1=yes)"
capture confirm variable shock
if !_rc label variable shock "Reported drought or flood shock (1=yes)"
capture confirm variable extension_any_advice
if !_rc label variable extension_any_advice "Any agricultural advice reported in topic roster (1=yes)"
capture confirm variable radio_any
if !_rc label variable radio_any "Any agricultural advice mainly received from radio (1=yes)"
capture confirm variable radio_sap_strict
if !_rc label variable radio_sap_strict "Pit-planting advice mainly received from radio (1=yes)"
capture confirm variable radio_sap_broad
if !_rc label variable radio_sap_broad "Broad SAP-related advice mainly received from radio (1=yes)"
capture confirm variable advice_valid
if !_rc label variable advice_valid "Number of advice topics with valid received-advice responses"
capture confirm variable strict_valid
if !_rc label variable strict_valid "Number of valid pit-planting radio-advice indicators"
capture confirm variable broad_valid
if !_rc label variable broad_valid "Number of valid broad SAP radio-advice topic indicators"
capture confirm variable merge_iv_advice
if !_rc label variable merge_iv_advice "Merge result: household analysis data and advice indicators"
capture confirm variable com_cf07
if !_rc label variable com_cf07 "Raw response: extension officer lives in community (1=yes, 2=no)"
capture confirm variable com_cf08a
if !_rc label variable com_cf08a "Raw distance to nearest extension officer (see com_cf08b unit)"
capture confirm variable com_cf08b
if !_rc label variable com_cf08b "Raw extension distance unit: 1=metre, 2=km, 3=mile"
capture confirm variable extension_resident
if !_rc label variable extension_resident "Extension officer lives in community (1=yes, 0=no)"
capture confirm variable dist_extension_km
if !_rc label variable dist_extension_km "Extension access distance (km; resident officer coded zero proxy)"
capture confirm variable dist_extension_km_unresolved
if !_rc label variable dist_extension_km_unresolved "Officer nonresident but access distance unresolved (1=yes)"
capture confirm variable dist_extension_km_structzero
if !_rc label variable dist_extension_km_structzero "Officer resident; access distance set to zero proxy (1=yes)"
capture confirm variable com_cc14
if !_rc label variable com_cc14 "Raw 2014 voter-turnout category: 1=almost none to 5=almost all"
capture confirm variable turnout2014_cat
if !_rc label variable turnout2014_cat "2014 voter-turnout category: 1=almost none to 5=almost all"
capture confirm variable com_cd66
if !_rc label variable com_cd66 "Raw response: commercial bank present (1=yes, 2=no)"
capture confirm variable com_cd67a
if !_rc label variable com_cd67a "Raw bank distance (see com_cd67b for distance unit)"
capture confirm variable com_cd67b
if !_rc label variable com_cd67b "Raw bank distance unit: 1=metre, 2=km, 3=mile"
capture confirm variable com_cd68
if !_rc label variable com_cd68 "Raw response: microfinance institution present (1=yes, 2=no)"
capture confirm variable com_cd69a
if !_rc label variable com_cd69a "Raw microfinance distance (see com_cd69b for distance unit)"
capture confirm variable com_cd69b
if !_rc label variable com_cd69b "Raw microfinance distance unit: 1=metre, 2=km, 3=mile"
capture confirm variable com_cd70
if !_rc label variable com_cd70 "Raw response: MP is community resident (1=yes, 2=no)"
capture confirm variable mp_resident
if !_rc label variable mp_resident "MP is community resident (1=yes, 0=no)"
capture confirm variable mp_visit
if !_rc label variable mp_visit "MP visited community in past three months (1=yes, 0=no)"
capture confirm variable bank_present
if !_rc label variable bank_present "Commercial bank present in community (1=yes, 0=no)"
capture confirm variable mfi_present
if !_rc label variable mfi_present "Microfinance institution present in community (1=yes, 0=no)"
capture confirm variable dist_bank_km
if !_rc label variable dist_bank_km "Bank access distance (km; bank presence coded zero proxy)"
capture confirm variable dist_bank_km_unresolved
if !_rc label variable dist_bank_km_unresolved "Bank absent but access distance unresolved (1=yes)"
capture confirm variable dist_bank_km_structzero
if !_rc label variable dist_bank_km_structzero "Bank present; access distance set to zero proxy (1=yes)"
capture confirm variable dist_mfi_km
if !_rc label variable dist_mfi_km "Microfinance access distance (km; presence coded zero proxy)"
capture confirm variable dist_mfi_km_unresolved
if !_rc label variable dist_mfi_km_unresolved "Microfinance absent but access distance unresolved (1=yes)"
capture confirm variable dist_mfi_km_structzero
if !_rc label variable dist_mfi_km_structzero "Microfinance present; distance set to zero proxy (1=yes)"
capture confirm variable merge_cc_cd
if !_rc label variable merge_cc_cd "Merge result: turnout and community-service modules"
capture confirm variable merge_cf_cd
if !_rc label variable merge_cf_cd "Merge result: extension and community-service modules"
capture confirm variable merge_iv_community
if !_rc label variable merge_iv_community "Merge result: household analysis data and community indicators"
capture confirm variable climate_temp
if !_rc label variable climate_temp "Annual mean temperature alias (degrees Celsius)"
capture confirm variable climate_rain
if !_rc label variable climate_rain "Annual precipitation alias from geovariables (mm)"
capture confirm variable merge_iv_geo
if !_rc label variable merge_iv_geo "Merge result: household analysis data and geovariables"
capture confirm variable educ_group
if !_rc label variable educ_group "Head education group: never, primary, secondary or post-secondary"
capture confirm variable merge_iv_educ
if !_rc label variable merge_iv_educ "Merge result: household analysis data and head education group"
capture confirm variable ln1p_dist_bank_km
if !_rc label variable ln1p_dist_bank_km "Natural log of (1 + bank access distance in km)"
capture confirm variable ln1p_dist_mfi_km
if !_rc label variable ln1p_dist_mfi_km "Natural log of (1 + microfinance access distance in km)"
capture confirm variable ln1p_dist_extension_km
if !_rc label variable ln1p_dist_extension_km "Natural log of (1 + extension access distance in km)"
capture confirm variable ln1p_dist_admarc
if !_rc label variable ln1p_dist_admarc "Natural log of (1 + ADMARC market distance in km)"
capture confirm variable ln1p_dist_agmrkt
if !_rc label variable ln1p_dist_agmrkt "Natural log of (1 + agricultural market distance in km)"
capture confirm variable mesr_regime
if !_rc label variable mesr_regime "MESR regime: 1=both, 2=FISP only, 3=SAPs only, 4=neither"
capture confirm variable study_sample
if !_rc label variable study_sample "Maize household with valid MESR regime (1=in analysis sample)"
capture confirm variable l_productivity
if !_rc label variable l_productivity "Natural log: Physical maize harvest divided by plot area (kg/acre)"
capture confirm variable l_avr_long_tmp2019
if !_rc label variable l_avr_long_tmp2019 "Natural log: 2015-22 mean monthly temperature (CRU; degrees Celsius)"
capture confirm variable l_avr_long_pre2019
if !_rc label variable l_avr_long_pre2019 "Natural log: 2015-22 mean monthly precipitation (CRU; mm)"
capture confirm variable l_avr_yearly_tmp2019
if !_rc label variable l_avr_yearly_tmp2019 "Natural log: 2019 mean monthly temperature (CRU; degrees Celsius)"
capture confirm variable l_avr_yearly_pre2019
if !_rc label variable l_avr_yearly_pre2019 "Natural log: 2019 mean monthly precipitation (CRU; mm)"
capture confirm variable l_HDDS
if !_rc label variable l_HDDS "Natural log: Ten-group seven-day food-diversity proxy (not standard 24h HDDS)"
capture confirm variable l_FCS
if !_rc label variable l_FCS "Natural log: Food consumption score from seven-day food frequencies"
capture confirm variable l_harvest
if !_rc label variable l_harvest "Natural log: Total reported maize harvest value (MK)"
capture confirm variable productivity1
if !_rc label variable productivity1 "Maize productivity (kg/acre); FISP only households"
capture confirm variable l_productivity1
if !_rc label variable l_productivity1 "Natural log: Maize productivity (kg/acre); FISP only households"
capture confirm variable productivity2
if !_rc label variable productivity2 "Maize productivity (kg/acre); SAPs only households"
capture confirm variable l_productivity2
if !_rc label variable l_productivity2 "Natural log: Maize productivity (kg/acre); SAPs only households"
capture confirm variable productivity3
if !_rc label variable productivity3 "Maize productivity (kg/acre); both FISP and SAPs households"
capture confirm variable l_productivity3
if !_rc label variable l_productivity3 "Natural log: Maize productivity (kg/acre); both FISP and SAPs households"
capture confirm variable productivity4
if !_rc label variable productivity4 "Maize productivity (kg/acre); neither FISP nor SAPs households"
capture confirm variable l_productivity4
if !_rc label variable l_productivity4 "Natural log: Maize productivity (kg/acre); neither FISP nor SAPs households"
capture confirm variable FCS1
if !_rc label variable FCS1 "Food consumption score; FISP only households"
capture confirm variable l_FCS1
if !_rc label variable l_FCS1 "Natural log: Food consumption score; FISP only households"
capture confirm variable FCS2
if !_rc label variable FCS2 "Food consumption score; SAPs only households"
capture confirm variable l_FCS2
if !_rc label variable l_FCS2 "Natural log: Food consumption score; SAPs only households"
capture confirm variable FCS3
if !_rc label variable FCS3 "Food consumption score; both FISP and SAPs households"
capture confirm variable l_FCS3
if !_rc label variable l_FCS3 "Natural log: Food consumption score; both FISP and SAPs households"
capture confirm variable FCS4
if !_rc label variable FCS4 "Food consumption score; neither FISP nor SAPs households"
capture confirm variable l_FCS4
if !_rc label variable l_FCS4 "Natural log: Food consumption score; neither FISP nor SAPs households"
capture confirm variable HDDS1
if !_rc label variable HDDS1 "Seven-day food-diversity proxy; FISP only households"
capture confirm variable l_HDDS1
if !_rc label variable l_HDDS1 "Natural log: Seven-day food-diversity proxy; FISP only households"
capture confirm variable HDDS2
if !_rc label variable HDDS2 "Seven-day food-diversity proxy; SAPs only households"
capture confirm variable l_HDDS2
if !_rc label variable l_HDDS2 "Natural log: Seven-day food-diversity proxy; SAPs only households"
capture confirm variable HDDS3
if !_rc label variable HDDS3 "Seven-day food-diversity proxy; both FISP and SAPs households"
capture confirm variable l_HDDS3
if !_rc label variable l_HDDS3 "Natural log: Seven-day food-diversity proxy; both FISP and SAPs households"
capture confirm variable HDDS4
if !_rc label variable HDDS4 "Seven-day food-diversity proxy; neither FISP nor SAPs households"
capture confirm variable l_HDDS4
if !_rc label variable l_HDDS4 "Natural log: Seven-day food-diversity proxy; neither FISP nor SAPs households"
capture confirm variable harvest1
if !_rc label variable harvest1 "Maize harvest value (MK); FISP only households"
capture confirm variable l_harvest1
if !_rc label variable l_harvest1 "Natural log: Maize harvest value (MK); FISP only households"
capture confirm variable harvest2
if !_rc label variable harvest2 "Maize harvest value (MK); SAPs only households"
capture confirm variable l_harvest2
if !_rc label variable l_harvest2 "Natural log: Maize harvest value (MK); SAPs only households"
capture confirm variable harvest3
if !_rc label variable harvest3 "Maize harvest value (MK); both FISP and SAPs households"
capture confirm variable l_harvest3
if !_rc label variable l_harvest3 "Natural log: Maize harvest value (MK); both FISP and SAPs households"
capture confirm variable harvest4
if !_rc label variable harvest4 "Maize harvest value (MK); neither FISP nor SAPs households"
capture confirm variable l_harvest4
if !_rc label variable l_harvest4 "Natural log: Maize harvest value (MK); neither FISP nor SAPs households"
capture confirm variable age1
if !_rc label variable age1 "Head age (years); FISP only households"
capture confirm variable age2
if !_rc label variable age2 "Head age (years); SAPs only households"
capture confirm variable age3
if !_rc label variable age3 "Head age (years); both FISP and SAPs households"
capture confirm variable age4
if !_rc label variable age4 "Head age (years); neither FISP nor SAPs households"
capture confirm variable gender1
if !_rc label variable gender1 "Head sex (1=male, 0=female); FISP only households"
capture confirm variable gender2
if !_rc label variable gender2 "Head sex (1=male, 0=female); SAPs only households"
capture confirm variable gender3
if !_rc label variable gender3 "Head sex (1=male, 0=female); both FISP and SAPs households"
capture confirm variable gender4
if !_rc label variable gender4 "Head sex (1=male, 0=female); neither FISP nor SAPs households"
capture confirm variable educ1
if !_rc label variable educ1 "Head highest class attended (legacy code); FISP only households"
capture confirm variable educ2
if !_rc label variable educ2 "Head highest class attended (legacy code); SAPs only households"
capture confirm variable educ3
if !_rc label variable educ3 "Head highest class attended (legacy code); both FISP and SAPs households"
capture confirm variable educ4
if !_rc label variable educ4 "Head highest class attended (legacy code); neither FISP nor SAPs households"
capture confirm variable hh_Size1
if !_rc label variable hh_Size1 "Household size; FISP only households"
capture confirm variable hh_Size2
if !_rc label variable hh_Size2 "Household size; SAPs only households"
capture confirm variable hh_Size3
if !_rc label variable hh_Size3 "Household size; both FISP and SAPs households"
capture confirm variable hh_Size4
if !_rc label variable hh_Size4 "Household size; neither FISP nor SAPs households"
capture confirm variable extension1
if !_rc label variable extension1 "Agricultural advice (legacy indicator); FISP only households"
capture confirm variable extension2
if !_rc label variable extension2 "Agricultural advice (legacy indicator); SAPs only households"
capture confirm variable extension3
if !_rc label variable extension3 "Agricultural advice (legacy indicator); both FISP and SAPs households"
capture confirm variable extension4
if !_rc label variable extension4 "Agricultural advice (legacy indicator); neither FISP nor SAPs households"
capture confirm variable credit1
if !_rc label variable credit1 "Borrowing indicator; FISP only households"
capture confirm variable credit2
if !_rc label variable credit2 "Borrowing indicator; SAPs only households"
capture confirm variable credit3
if !_rc label variable credit3 "Borrowing indicator; both FISP and SAPs households"
capture confirm variable credit4
if !_rc label variable credit4 "Borrowing indicator; neither FISP nor SAPs households"
capture confirm variable type21
if !_rc label variable type21 "Intermediate/loam soil indicator; FISP only households"
capture confirm variable type22
if !_rc label variable type22 "Intermediate/loam soil indicator; SAPs only households"
capture confirm variable type23
if !_rc label variable type23 "Intermediate/loam soil indicator; both FISP and SAPs households"
capture confirm variable type24
if !_rc label variable type24 "Intermediate/loam soil indicator; neither FISP nor SAPs households"
capture confirm variable type31
if !_rc label variable type31 "Clay soil indicator; FISP only households"
capture confirm variable type32
if !_rc label variable type32 "Clay soil indicator; SAPs only households"
capture confirm variable type33
if !_rc label variable type33 "Clay soil indicator; both FISP and SAPs households"
capture confirm variable type34
if !_rc label variable type34 "Clay soil indicator; neither FISP nor SAPs households"
capture confirm variable quality21
if !_rc label variable quality21 "Fair soil-quality indicator; FISP only households"
capture confirm variable quality22
if !_rc label variable quality22 "Fair soil-quality indicator; SAPs only households"
capture confirm variable quality23
if !_rc label variable quality23 "Fair soil-quality indicator; both FISP and SAPs households"
capture confirm variable quality24
if !_rc label variable quality24 "Fair soil-quality indicator; neither FISP nor SAPs households"
capture confirm variable quality31
if !_rc label variable quality31 "Poor soil-quality indicator; FISP only households"
capture confirm variable quality32
if !_rc label variable quality32 "Poor soil-quality indicator; SAPs only households"
capture confirm variable quality33
if !_rc label variable quality33 "Poor soil-quality indicator; both FISP and SAPs households"
capture confirm variable quality34
if !_rc label variable quality34 "Poor soil-quality indicator; neither FISP nor SAPs households"
capture confirm variable l_avr_yearly_tmp20191
if !_rc label variable l_avr_yearly_tmp20191 "Log 2019 mean monthly temperature; FISP only households"
capture confirm variable l_avr_yearly_tmp20192
if !_rc label variable l_avr_yearly_tmp20192 "Log 2019 mean monthly temperature; SAPs only households"
capture confirm variable l_avr_yearly_tmp20193
if !_rc label variable l_avr_yearly_tmp20193 "Log 2019 mean monthly temperature; both FISP and SAPs households"
capture confirm variable l_avr_yearly_tmp20194
if !_rc label variable l_avr_yearly_tmp20194 "Log 2019 mean monthly temperature; neither FISP nor SAPs households"
capture confirm variable l_avr_yearly_pre20191
if !_rc label variable l_avr_yearly_pre20191 "Log 2019 mean monthly precipitation; FISP only households"
capture confirm variable l_avr_yearly_pre20192
if !_rc label variable l_avr_yearly_pre20192 "Log 2019 mean monthly precipitation; SAPs only households"
capture confirm variable l_avr_yearly_pre20193
if !_rc label variable l_avr_yearly_pre20193 "Log 2019 mean monthly precipitation; both FISP and SAPs households"
capture confirm variable l_avr_yearly_pre20194
if !_rc label variable l_avr_yearly_pre20194 "Log 2019 mean monthly precipitation; neither FISP nor SAPs households"

* Flag any future variable that still needs a substantive label.
quietly ds
local all_label_variables `r(varlist)'
local label_problems 0
foreach v of local all_label_variables {
    local description : variable label `v'
    if strtrim(`"`description'"')=="" | ///
        regexm(`"`description'"',"^\((sum|max|count|firstnm|mean)\)") {
        di as error "Missing or collapse-generated variable label: `v'"
        local ++label_problems
    }
}
if `label_problems'>0 {
    di as error "Complete labels required for `label_problems' variables; no data were changed."
    exit 459
}
di as result "All variables have nonblank labels; no collapse-generated labels remain."
