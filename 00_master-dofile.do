******************************************************************************
*                                                                            *
*  Study: Farm input subsidies (FISP) and adoption of sustainable            *
*  agricultural practices in Malawi: synergies and implications on farm      *
*  productivity and household resilience to food shocks                      *
*                                                                            *
*  File: 00_master-dofile.do                                                 *
*  Role: Master entry point                                                  *
*  Author: Lonjezo Erick Folias                                              *
*  Email: lonjefolias@hotmail.com                                            *
*  Phone: 0992 888 003                                                       *
*  Documentation revision: 19 October 2026                                   *
*                                                                            *
*  Purpose: Defines user paths and controls which project stages run.        *
*                                                                            *
*  Inputs: Local project folder, GitHub clone and required source files.     *
*                                                                            *
*  Outputs: Folder globals; execution of enabled stages.                     *
*                                                                            *
*  Run order: Run first. Cleaning is enabled; estimation is disabled in      *
*  this supplied version.                                                    *
*                                                                            *
*  Notes: Installation block remains disabled. See README for prerequisites  *
*  and stage switches.                                                       *
*                                                                            *
******************************************************************************

******************************************************************************
**# PART 0: OPTIONAL PACKAGE INSTALLATION
******************************************************************************
* Supplied installation block is disabled; see README for dependencies.
if (0) {
   local user_commands winsor factortest ietoolkit iefieldkit 	movestay asdoc rbiprobit  estout  ///
   codebookout ietoolkit iefieldkit geoplot schemepack palettes ///
   colrspace moremata scto //Fill this list will all user-written commands this project requires
   
   foreach command of local user_commands {
       cap which `command'
       if _rc == 111 {
           ssc install `command'
       }
   }
   
}
   
   

   * ******************************************************************** *
   *
   **#       PART 1: PROJECT AND DATA PATH GLOBALS
   *
   *           - Set projectfolder to the local data project root
   *            on each collaborator's computer.
   *           - Set github to the directory containing the repository clone.
   *
   * ******************************************************************** *


	*User 							Number:
	* 	Lonjezo Folias 				1  
	* 	Mwayi 	Mambosasa			2
	* 	Wisdom 	Mgomezulu			3
   

   *Set this value to the user currently using this file
   global user  1

   * Root folder globals
   * ---------------------

  
   
      if $user == 1 {
       global projectfolder "C:/Users/wb643670/OneDrive/Documents/Manu Scripts/Wisdom Proposal/AERC 2026"  // Enter the file path to the project folder for Lonje user here
	   
	   global github "C:/Users/wb643670/GitHub"  // Enter the file path to git local folder here (with all the do files)
	   
   }
   
* These lines are used to test that the name is not already used (do not edit manually)
*round**************************************************************************
*untObs*validation*targeting*baseline*******************************************
*subFld*************************************************************************
*folder will not work properly if the lines above are edited


   * Project folder globals
   * ---------------------

   global dataWorkFolder         	"$projectfolder/data"
   global result		        	"$projectfolder/result"

*folder*1*FolderGlobals*subfolder*********************************************
*folder will not work properly if the line above is edited
	
	

*folder*1*FolderGlobals*master************************************************
*folder will not work properly if the line above is edited

   global rawdata               	"$dataWorkFolder/01_raw" 
   global workingfiles				"$dataWorkFolder/02_workingfiles"
   global finaldata         		"$dataWorkFolder/03_final" 
   

   global ihsfolder		          	"$rawdata/ihs"
   global ihsv		          		"$rawdata/ihs/MWI_2019_IHS-V_v06_M_Stata"
   global weather					"$rawdata/weather"	
   global dofiles					"$github/MESR-estimation-FISP-and-adoption-of-SAPs/do-files"
   
   


   * Set all non-folder path globals that are constant accross
   * the project. Examples are conversion rates used in unit
   * standardization, different sets of control variables,
   * adofile paths etc.

 

*folder*2*End_StandardGlobals*************************************************
*folder will not work properly if the line above is edited


*folder*3*RunDofiles**********************************************************
*folder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   **#       PART 2: EXECUTION SWITCHES FOR CLEANING AND ESTIMATION
   *
   *           - Cleaning is enabled in the supplied master.
   *           - Estimation is disabled until its switch is changed to 1.
   *           - Keep stage switches separate from installation.
   *
   * ******************************************************************** *

*folder*3*End_RunDofiles******************************************************
*folder will not work properly if the line above is edited

* Current sequence: 01_data_cleaning.do, then 02_MESR_main.do.
* Estimation loads 02.1_MESR_programs.do automatically.
		
		
*Change the if to 1 if you want to run a specific function through the do file 

		* Cleaning stage: enabled in the supplied master (if 1). 
 if (1) {
 	
		do "$dofiles/01_data_cleaning.do" 
 }
		
		
		* Estimation stage: disabled in the supplied master (if 0). 
 if (0) {
	do "$dofiles/02_MESR_main.do"
 }
******************************************************************************
**# OPTIONAL: ALTERNATIVE OUTCOME DISTRIBUTION GRAPHS
******************************************************************************
* Run only after the main estimation has saved its analysis sample.
* This example remains commented and does not change master execution.
* do "$dofiles/03_graphs.do" "$result/MESR_analysis_sample_10_15.dta" "$result"
