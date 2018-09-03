#!/bin/tcsh -f
#
# Update DDCs defined in daisyProjSetup/info/daisyDdcs.txt
# Martin Nielsen-Lönn 2015-06-08

if ($# < 1) then
then
    setenv PROJAREA $1
fi

# Check that the project is loaded
if (! ($?PROJAREA) ) then
  echo "PROJAREA not set, you have probably not sourced the project"
else
  # Create new DDC directories
  daisyGenDdcs.sh
  
  # Create links for project - has to be done for each user
  daisyCreateDdcLinks.sh
  
  cd $WORKAREA
  dbAccess -load daisy/skill/daisyCreateMissingDdcsLibs.il
  
  # Update daisyProjSetup/oa/cds.lib
  daisyBuildCdsLib.sh
  daisyBuildCdsLib.sh testlib
  
#  echo "Run #cad and run \"loadi(\"daisy/skill/daisyCreateMissingDdcsLibs.il\")\n"
  
endif
