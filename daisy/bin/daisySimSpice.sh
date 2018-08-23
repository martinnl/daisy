#!/bin/bash

# A command wrapper that runs all the python files on the
# ocean scripts

echo "DAISY:: Launching $0 in $PWD -- a wrapper to execute a list of simulations."
# sources the project directory
# Display the runset's file name for identification
echo "DAISY:: Runset file is $1"
echo "DAISY:: Results directory $2"

while read CMDFILE; do
    
    echo "DAISY:: == Running $CMDFILE ============================= "
    #echo ${PROJAREA}
    #echo $PROJAREA
    if [ -z "$2" ]
    then
	echo "DAISY:: $CMDFILE"
        eval $DAISYAREA/bin/daisyTrigOceanPy.sh $CMDFILE
    else
	echo "DAISY:: $CMDFILE > $2"
	eval $DAISYAREA/bin/daisyTrigOceanPy.sh $CMDFILE $2
    fi

    #ls -lastr ${PROJAREA}/xrayChannel_3b/sim/ocean/comparator/
    #ls -lastr  $CMDFILE
    #ls ${PROJAREA}/xrayChannel_3b/sim/ocean/comparator/CLOCK_TOP_3A_TB.csh    
    # source $CMDFILE
    
done < $1
