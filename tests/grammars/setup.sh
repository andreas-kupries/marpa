#!/bin/bash

link="z-marpa-tcl"
lloc="../../bootstrap/marpa-tcl-slif"

cd $(dirname "$0")

if [ -d "${link}" ] ; then exit ; fi

ln -s "${lloc}" "${link}"
exit
    
