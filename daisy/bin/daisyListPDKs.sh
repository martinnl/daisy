#!/bin/tcsh

# TODO: Add check that it is a valid PDK config

set dirs=$PDKSPECIFIC/*

foreach dir ($dirs)
  basename $dir
end

