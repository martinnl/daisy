#!/bin/tcsh -f
#
# Project setup for the daisy cad environment
# J Jacob Wikner
#
# 2018-08-23: Retrive DAISYAREA from config
#

# Path to your local directory
setenv PROJPATH "$1"

# Local project name
setenv PROJNAME "$2"
echo $PROJNAME

# Shared project area
setenv PROJAREA "$3"

setenv WORKAREA "$PWD/$PROJPATH/$PROJNAME/"

# Get DAISYAREA from config
source `dirname $0`/config.sh

mkdir -p "$WORKAREA"

cd "$WORKAREA"

# Linking the ProjSetup and daisy areas
ln -sf   "$PROJAREA/daisyProjSetup"
ln -sf   $DAISYAREA

setenv USERAREA "$WORKAREA/work_$USER"
echo $USERAREA

$DAISYAREA/bin/daisyGenDdcSubdirs.sh "work_$USER" local

cd "$WORKAREA"
echo "$WORKAREA"

# Linking the cadence setup files and dot files
ln -sf $DAISYAREA/cds/cdsinit     .cdsinit
ln -sf $DAISYAREA/cds/cdsenv      .cdsenv
ln -sf $DAISYAREA/cds/cdsplotinit .cdsplotinit
ln -sf $DAISYAREA/cds/assura_tech.lib       
ln -sf $DAISYAREA/oceanrc         .oceanrc
ln -sf $DAISYAREA/data.reg 
ln -sf $DAISYAREA/hdl.var

# Create local cds.lib so that Cadence don't complain that they don't exist
touch "$USERAREA/cds/cds.lib"
touch "$USERAREA/cds/cds.testlib"
touch "$USERAREA/oa/cds.lib"
touch "$USERAREA/oa/cds.testlib"

# Setting up simulation directories for ocean
ln -sf $DAISYAREA/oceanrc         "$USERAREA/sim/ocean/.oceanrc"
ln -sf $DAISYAREA/cds/cdsinit     "$USERAREA/sim/ocean/.cdsinit"
ln -sf $DAISYAREA/cds/cdsplotinit "$USERAREA/sim/ocean/.cdsplotinit"

# Creating the cds.lib file
echo 'INCLUDE $DAISYAREA/cds/$CDSDATABASE.lib' >! cds.lib

# Write to the rc file in the $HOME to be sourced
echo "# Setup for $PROJNAME" >! "$HOME/.${PROJNAME}_rc"
echo "setenv PROJNAME $PROJNAME" >> "$HOME/.${PROJNAME}_rc"
echo "setenv WORKAREA $WORKAREA" >> "$HOME/.${PROJNAME}_rc"
echo "setenv DAISYAREA $DAISYAREA" >> "$HOME/.${PROJNAME}_rc"
echo 'source $DAISYAREA/cshrc/tcshrc' >> "$HOME/.${PROJNAME}_rc"

cd "$WORKAREA"

# Link all the repos
# Changed 2015-06-08 /MNL
$DAISYAREA/bin/daisyCreateDdcLinks.sh
# Old code follows
#if (-e  "$PROJAREA/daisyProjSetup/info/daisyDdcs.txt") then 
#    foreach line (`cat $PROJAREA/daisyProjSetup/info/daisyDdcs.txt`)
#         echo "DAISY:: Adding $line to your $WORKAREA"
#	 ln -sf "$PROJAREA/$line"
#    end
#else
#    echo "DAISY: There is no daisyDdcs.txt file in your daisyProjSetup/info"
#endif


# Run project specific setup
if (-e "$PROJAREA/daisyProjSetup/bin/daisyProjSetupAdd.sh") then
    "$PROJAREA/daisyProjSetup/bin/daisyProjSetupAdd.sh"
endif

## End of files


