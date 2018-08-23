#!/bin/tcsh

setenv NETLIST_LIB $1
setenv NETLIST_CELL $2
setenv NETLIST_TYPE $3

echo ""
echo "Make netlist:"
echo $NETLIST_LIB $NETLIST_CELL $NETLIST_TYPE
echo ""

source  ~/.xray_rc
cd $WORKAREA



icfb -nograph -replay /proj/ek/xray/xray/xray3A/sim/ocean/makeNetlist.il 
