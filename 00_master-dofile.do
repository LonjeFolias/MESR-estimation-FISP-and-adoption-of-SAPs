   * ******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
   *               Farm input subsidies (FISP) and adoption of sustainable* 
   *               agricultural practices in Malawi: synergies and		  * 
   *               implications on farm productivity and household		  * 
   *               resilience to food shocks                              *
   *																	  *
   *               Model Estimation  DO_FILE : This do file estimates 	  *
   *			   1)Probit Models to determine factors influencing       *
   *			   farmers' adoption/participation of the coupling        *
   *			   of FISP with SAPs.                                     *
   *   			   2) estimates the Selectivity-corrected Multinomial     *
   *			   Endogenous Switching Probit (MNESR) model to quantify  *
   *			   the impacts of coupling of FISP with SAPs on           *
   *               productivity and food security                         *
   *               														  *                                
   *				Author : Lonjezo Erick Folias                         *
   *				Number : 0992 888 003   							  *
   *				Email  : lonjefolias@hotmail.com					  *
   * ******************************************************************** *
   * ******************************************************************** *


   * ******************************************************************** *
   *
   **#       PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
   *
   *           - Install packages needed to run all dofiles called
   *            by this master dofile.
   *           - Use ieboilstart to harmonize settings across users
   *
   * ******************************************************************** *

*folder*0*End_StandardSettings************************************************
*folder will not work properly if the line above is edited

   *Install all packages that this project requires:
   *(Note that this never updates outdated versions of already installed commands, to update commands use adoupdate)
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
   **#       PART 1:  PREPARING FOLDER PATH GLOBALS
   *
   *           - Set the global box to point to the project folder
   *            on each collaborator's computer.
   *           - Set other locals that point to other folders of interest.
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
   **#       PART 3: - RUN DOFILES CALLED BY THIS MASTER DOFILE
   *
   *           - When survey rounds are added, this section will
   *            link to the master dofile for that round.
   *           - The default is that these dofiles are set to not
   *            run. It is rare that all round-specfic master dofiles
   *            are called at the same time; the round specific master
   *            dofiles are almost always called individually. The
   *            exception is when reviewing or replicating a full project.
   *
   * ******************************************************************** *

*folder*3*End_RunDofiles******************************************************
*folder will not work properly if the line above is edited

		do "$dofiles/01_data_cleaning.do" 
		do "$dofiles/05_model_estimation.do" 

