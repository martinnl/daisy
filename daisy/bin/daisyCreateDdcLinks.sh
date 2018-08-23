#!/bin/tcsh -f
# Create links to the DDCs in WORKAREA
#
# Martin Nielsen-Lönn martin.nielsen.lonn@liu.se 2015-06-08
#

if ( ! ($?PROJAREA) ) then
    echo "PROJAREA not set, you have probably not sourced the project"
else

  if (-e  "$PROJAREA/daisyProjSetup/info/daisyDdcs.txt") then 
      foreach line (`cat $PROJAREA/daisyProjSetup/info/daisyDdcs.txt`)
           echo "DAISY:: Adding $line to your $WORKAREA"
  	 ln -sf "$PROJAREA/$line"
      end
  else
      echo "DAISY: There is no daisyDdcs.txt file in your daisyProjSetup/info"
  endif
endif
