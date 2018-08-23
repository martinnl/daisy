cd $PROJAREA


grep -rw pv/drc --include=\*.log -e 'Total  errors' | sed 's/  */ /g' | sed 's/pv\/drc\///g' | sed 's/\.log//g'

grep -rw pv/lvs --include=\*.log -e 'Schematic and Layout Match' | sed 's/  */ /g' | sed 's/pv\/lvs\///g' | sed 's/\.log:/ --> /g'

grep -rw pv/lvs --include=\*.log -e 'abnormally' | sed 's/  */ /g' | sed 's/pv\/lvs\///g' | sed 's/\.log:/ --> /g'

grep -rw pv/lvs --include=\*.lrs -e 'Mismatch between Schematic and Layout' | sed 's/  */ /g' | sed 's/pv\/lvs\///g' | sed 's/\.lrs:/ --> /g'

rm -f pv/__qrc.log.*
