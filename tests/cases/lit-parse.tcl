# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
# Test cases for parsing literals lexemes into the internal rep

proc lit-parse {} {
    # XXX TODO: Add border cases BMP / FULL, middle, high FULL
    
    ++ N01 {'a'}                        {character 97}
    ++ N02 {'a-'}                       {string 97 45}

    ++ N03 {'a':i}                      {charclass 65 97}
    ++ N03 {'-':i}                      {character 45}
    ++ N04 {'a-':i}                     {%string 65 45}

    ++ N05 {[a]}                        {character 97}
    ++ N06 {[a-f]}                      {range 97 102}
    ++ N07 {[[:braille:]]}              {named-class braille}
    ++ N08 {[[:braille:]a]}             {charclass 97 braille}
    ++ N08 {[\-a-f]}                    {charclass 45 {97 102}}
    ++ N08 {[a-f[:braille:]]}           {charclass {97 102} braille}
    ++ N08 {[a-f[:braille:]\-]}         {charclass 45 {97 102} braille}

    ++ N09 {[a]:i}                      {charclass 65 97}
    ++ N09 {[\-]:i}                     {character 45}
    ++ N10 {[a-f]:i}                    {charclass {65 70} {97 102}}
    ++ N11 {[[:braille:]]:i}            {%named-class braille}
    ++ N12 {[a[:braille:]]:i}           {charclass 65 97 %braille}
    ++ N12 {[[:braille:]\-]:i}          {charclass 45 %braille}
    ++ N12 {[a-f\-]:i}                  {charclass 45 {65 70} {97 102}}
    ++ N12 {[\x2D-/a]:i}                {charclass {45 47} 65 97}
    ++ N12 {[[:braille:]a-f]:i}         {charclass {65 70} {97 102} %braille}
    ++ N12 {[\055-/[:braille:]]:i}      {charclass {45 47} %braille}
    ++ N12 {[\055[:braille:]a-f]:i}     {charclass 45 {65 70} {97 102} %braille}

    ++ N13 {[^a]}                       {^character 97}
    ++ N14 {[^abcdef]}                  {^range 97 102}
    ++ N15 {[^[:braille:]]}             {^named-class braille}
    ++ N16 {[^[:braille:]a]}            {^charclass 97 braille}
    ++ N16 {[^a-c\055d-f]}              {^charclass 45 {97 102}}
    ++ N16 {[^d-f[:braille:]a-e]}       {^charclass {97 102} braille}
    ++ N16 {[^a-c\055[:braille:]b-f]}  {^charclass 45 {97 102} braille}

    ++ N17 {[^a]:i}                     {^charclass 65 97}
    ++ N17 {[^\x2d]:i}                  {^character 45}
    ++ N18 {[^a-f]:i}                   {^charclass {65 70} {97 102}}
    ++ N19 {[^[:braille:]]:i}           {^%named-class braille}
    ++ N20 {[^[:braille:]a]:i}          {^charclass 65 97 %braille}
    ++ N20 {[^[:braille:]\055]:i}       {^charclass 45 %braille}
    ++ N20 {[^a-c\055b-f]:i}            {^charclass 45 {65 70} {97 102}}
    ++ N20 {[^\055\056\057a]:i}         {^charclass {45 47} 65 97}
    ++ N20 {[^[:braille:]a-f]:i}        {^charclass {65 70} {97 102} %braille}
    ++ N20 {[^[:braille:]\--/]:i}       {^charclass {45 47} %braille}
    ++ N20 {[^\055abcdef[:braille:]]:i} {^charclass 45 {65 70} {97 102} %braille}

    ++ CC0 "\[^\"\\\\\[:control:]]"     {^charclass 34 92 control}

    **
}

# # ## ### ##### ######## #############
return
