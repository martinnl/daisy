#!/bin/csh 

# Helper script for the cadence plot generator. 
# Some tweaks were needed due to several versions of software and systems.

#module rm local
#module add localfirst

unsetenv LD_LIBRARY_PATH
set fileName = $1
set angle  = $2 

ps2epsi $fileName.eps $fileName.epsi
convert -rotate $angle $fileName.eps $fileName.tiff
convert -rotate $angle $fileName.eps $fileName.png

convert $fileName.eps $fileName.pdf
