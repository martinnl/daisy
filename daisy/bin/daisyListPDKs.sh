#!/bin/tcsh

set dirs=$PDKSPECIFIC/pdkSpecific/*

foreach dir ($dirs)
  basename $dir
end

