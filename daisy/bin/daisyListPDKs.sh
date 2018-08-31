#!/bin/tcsh

set dirs=$PDKSPECIFIC/*

foreach dir ($dirs)
  basename $dir
end

