#!/bin/tcsh

##########################################################################
##########################################################################

echo "DAISY :: Running $0 at $PWD"
setenv NETLIST_REPO  $1 # "xrayChannel_3b"
setenv NETLIST_CELL  $2 # "CLOCK_TOP_3A_TB"
setenv NETLIST_KEY   $3 # "comparator"
setenv ARTIFACT_DIR  $4 # For Jenkins, etc.
# setenv NETLIST_LIB   "xrayChannelComp_3bTest"
# setenv NETLIST_TYPE  "schematic"

##########################################################################
##########################################################################
## |                   |
## v Make this generic v
## |                   |
##########################################################################
##########################################################################

echo "Running $NETLIST_REPO $NETLIST_CELL ($NETLIST_KEY)"
setenv EXIT_OCEAN

# A check could be done if it is already sourced, but nevertheless for now
# leave it there
source ~/.${PROJNAME}_rc

# Generic jump into the source directories
# Preferrably remove the NETLIST_KEY thingie if it is undefined

cd $PROJAREA/$NETLIST_REPO/sim/ocean/$NETLIST_KEY/

ln -sf ${WORKAREA}/.cdsinit
ln -sf ${WORKAREA}/cds.lib
ln -sf ${WORKAREA}/.oceanrc
ln -sf ${WORKAREA}/.cdsenv

# Run the ocean scripts
ocean -nograph -restore ${NETLIST_CELL}.ocn > ${NETLIST_CELL}.ocnlog

# Perform post simulation evaluation of the results
# These calls are generic

if (-f ${NETLIST_CELL}.py ) then
    mkdir -p $PROJAREA/$NETLIST_REPO/doc/${NETLIST_CELL}/
    mkdir -p $PROJAREA/$NETLIST_REPO/doc/${NETLIST_CELL}/figs/

    echo "Running python file to compile data into latex and figures"
    python ${NETLIST_CELL}.py

    ## Compile the information in the subdirectories
    cd $PROJAREA/$NETLIST_REPO/doc/${NETLIST_CELL}    
    pdflatex ${NETLIST_CELL}.tex
    # evince ${NETLIST_CELL}.pdf &

endif

# Add here copy to destination folder for the jenkins artifacts

if ( "$ARTIFACT_DIR" == "") then
    echo "No destination folder for results files"
else
    echo "Copying simulation results files for Jenkins ($1)"
    setenv ARTIFACT_DIR $4
    # If they do not exist, the copy command will be ignored
    cp -f ${NETLIST_CELL}.pdf ${ARTIFACT_DIR}
    cp -f $PROJAREA/$NETLIST_REPO/sim/ocean/$NETLIST_KEY/${NETLIST_CELL}.ocnlog ${ARTIFACT_DIR}
endif


cd $PROJAREA/$NETLIST_REPO/sim/ocean/$NETLIST_KEY/

