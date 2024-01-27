$Title  Script for DAC-NEMS integration
$inlinecom   { }

$offlisting

* Set directory path for root directory  - include back slash at the end
* Use "..\"  for current/run directory
*e.g.$set RootPath "C:\VAF\CTS\Scenario1\"
* --RootPath=".\"
$set RootPath ".\"

*Set directory path for location of gams model files - include back slash at the end
* In NEMS, the model code is in the root path
*$set SrcDir %RootPath%"ModelCode\"
*$set SrcDir  "S:\NETL\CTS_ModelCode\MasterCode\"
$set DACDir  %RootPath%DAC\

*Set directory path for location of results files
$set  Outdir %RootPath%

*********    Begin  User Settings   ****************************************************************

* Set = 1 to turn off selected constraints that should not apply in the NEMS-integrated runs
$set NEMSIntegrated 1

* To set solver...  set to Cplex or Xpress
$set  LPsolver               Cplex

* To send output to current local directory, set this value to 1; otherwise set it to -1
$set  CurrentDirectory        -1

* Set = 1 to use NEMS Carbon Price
$set CO2TAX 1

* Set = 1 to stop capture if operating cost is negative
$set STOPCAP 1

*********    End User Settings   ****************************************************************

$If %CurrentDirectory% == 1 $set OutDir .\

*Assign correct version of model files
$set GAMS_DACPrep_Name  %DACDir%DACPrep.gms
$set GAMS_DACModel_Name %DACDir%DACModel.gms

$set environ LO=%gams.lo% IDE=%gams.ide% workdir=%RootPath%

* about.put captures information about the versions used for this run
file about /%Outdir%about.put/;
put about;
put 'Run started on = ' system.date ' at ' system.time /

*GAMS_DataPrep_Name calaculates the model costs and bounds
$hiddencall gams %GAMS_DACPrep_Name% %environ% OptDir=%RootPath% ScrDir=%RootPath% PutDir=%RootPath% --dir=%RootPath% --InNEMS=%NEMSIntegrated%
$IF errorlevel 1 $Abort 'Error occurred during data preparation'
*put 'Data Preparation file: %GAMS_DataPrep_Name% - run completed at  ' system.time  /
$log Data Preparation completed after %system.elapsed% seconds

* GAMS_Model_Name contains the model formulation
$hiddencall gams %GAMS_DACModel_Name%  %environ% OptDir=%RootPath% ScrDir=%RootPath% PutDir=%RootPath% --LPsolver=%LPsolver% --dir=%RootPath% --InNEMS=%CO2TAX% --CheckOM=%STOPCAP%
$IF errorlevel 1 $Abort 'Model did not terminate with integer solution'
*$IF errorlevel 1 put 'Model did not terminate with integer solution'
*put 'CTS model file: %GAMS_Model_Name% - run completed at  ' system.time  /
$log Model Execution completed after %system.elapsed% seconds

$IF NOT errorlevel 1 $goto ok
$log *****************
$log more text
$log ******************
$abort

$label ok
