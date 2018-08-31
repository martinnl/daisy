# Getting started

FIX ExampleDDC to $PROJNAME_Top

setenv PROJPARENTPATH `pwd`/projects/
setenv PROJNAME test1
setenv PROJGROUP eks
setenv PROCESS xfab_xh018_v7

$DAISYAREA/bin/daisySetupNewProj.sh `pwd`/projects/ test1 eks 

source ${PROJPARENTPATH}${PROJNAME}/daisyProjSetup/cshrc/tcshrc

$DAISYAREA/bin/daisyGenDdcs.sh




Project test1 is setup in /home/marni16/Projects/smallDaisy/projects//test1.
Don't forget to:
 1) update the daisyDdcs.txt file in /home/marni16/Projects/smallDaisy/projects//test1/daisyProjSetup/info
 2) rerun the daisyGenDdcs.sh script to update all DDC subdirectories
 3) change the variables (if any) in daisyProjSetupAdd.sh in /home/marni16/Projects/smallDaisy/projects//test1/daisyProjSetup/bin
 4) setup a working directory with daisySetupProj.sh
 5) start Cadence and run (loadi "daisy/skill/daisyCreateDdcLibs.il")
 6) run daisyBuildCdsLib to build up the new /home/marni16/Projects/smallDaisy/projects//test1/daisyProjSetup/cds(oa)/cds.lib
 7) run daisyOpen (after sourcing project rc file) to set group permissions on everything
