#!/bin/tcsh

setenv NETLIST_PROJ $1
setenv NETLIST_DDC  $2
setenv NETLIST_LIB  $3
setenv NETLIST_CELL $4
setenv NETLIST_TYPE $5

echo ""
echo "Daisy :: Create netlist:"
echo $NETLIST_LIB $NETLIST_CELL $NETLIST_TYPE
echo ""

# Actually, if .oceanrc is setup properly, some of this job is not needed, but nevertheless...

source $HOME/.${NETLIST_PROJ}_rc
# cdwa
# cd $WORKAREA
cadr $DAISYAREA/skill/daisyCreateNetlistTxt.il

