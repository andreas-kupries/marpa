# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
# Test cases for literal normalization

proc lit-norm {} {
    # XXX TODO: Add border cases BMP / FULL, middle, high FULL

    ++ N01 {string 97}             {character 97}
    ++ N02 {string 97 45}          --

    ++ N03 {%string 97}            {charclass 65 97}
    ++ N03 {%string 45}            {character 45}
    ++ N04 {%string 65 45}         --

    ++ N05 {charclass 97}                    {character 97}
    ++ N06 {charclass {97 102}}              {range 97 102}
    ++ N07 {charclass braille}               {named-class braille}
    ++ N08 {charclass 97 braille}            --mix:char,named
    ++ N08 {charclass 45 {97 102}}           --mix:char,range
    ++ N08 {charclass {97 102} braille}      --mix:range,named
    ++ N08 {charclass 45 {97 102} braille}   --mix:char,range,named

    ++ N09 {%charclass 97}                   {charclass 65 97}
    ++ N09 {%charclass 45}                   {character 45}
    ++ N10 {%charclass {97 102}}             {charclass {65 70} {97 102}}
    ++ N11 {%charclass braille}              {%named-class braille}
    ++ N12 {%charclass 97 braille}           {charclass 65 97 %braille}
    ++ N12 {%charclass 45 braille}           {charclass 45 %braille}
    ++ N12 {%charclass 45 {97 102}}          {charclass 45 {65 70} {97 102}}
    ++ N12 {%charclass {45 47} 97}           {charclass {45 47} 65 97}
    ++ N12 {%charclass {97 102} braille}     {charclass {65 70} {97 102} %braille}
    ++ N12 {%charclass {45 47} braille}      {charclass {45 47} %braille}
    ++ N12 {%charclass 45 {97 102} braille}  {charclass 45 {65 70} {97 102} %braille}

    ++ N13 {^charclass 97}                   {^character 97}
    ++ N14 {^charclass {97 102}}             {^range 97 102}
    ++ N15 {^charclass braille}              {^named-class braille}
    ++ N16 {^charclass 97 braille}           --mix:char,named
    ++ N16 {^charclass 45 {97 102}}          --mix:char,range
    ++ N16 {^charclass {97 102} braille}     --mix:range,named
    ++ N16 {^charclass 45 {97 102} braille}  --mix:char,range,named

    ++ N17 {^%charclass 97}                  {^charclass 65 97}
    ++ N17 {^%charclass 45}                  {^character 45}
    ++ N18 {^%charclass {97 102}}            {^charclass {65 70} {97 102}}
    ++ N19 {^%charclass braille}             {^%named-class braille}
    ++ N20 {^%charclass 97 braille}          {^charclass 65 97 %braille}
    ++ N20 {^%charclass 45 braille}          {^charclass 45 %braille}
    ++ N20 {^%charclass 45 {97 102}}         {^charclass 45 {65 70} {97 102}}
    ++ N20 {^%charclass {45 47} 97}          {^charclass {45 47} 65 97}
    ++ N20 {^%charclass {97 102} braille}    {^charclass {65 70} {97 102} %braille}
    ++ N20 {^%charclass {45 47} braille}     {^charclass {45 47} %braille}
    ++ N20 {^%charclass 45 {97 102} braille} {^charclass 45 {65 70} {97 102} %braille}

    **
}

# # ## ### ##### ######## #############
return
