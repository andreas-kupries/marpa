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
    ++ N01 {'a'}                        {character 97}
    ++ N02 {'a-'}                       {string 97 45}

    ++ N03 {'a':i}                      {charclass 65 97}
    ++ N03 {'a':ic}                     {charclass 65 97}
    ++ N03 {'-':i}                      {character 45}
    ++ N04 {'a-':i}                     {%string 65 45}
    ++ N04 {'a':i:ic:i}                 {charclass 65 97}
    ++ N04 {'ab':i:ic:i}                {%string 65 66}

    ++ N05 {[a]}                        {character 97}
    ++ N06 {[a-f]}                      {range 97 102}
    ++ N07 {[[:braille:]]}              {named-class braille}
    ++ N08 {[[:braille:]a]}             {charclass 97 braille}
    ++ N08 {[\55a-f]}                   {charclass 45 {97 102}}
    ++ N08 {[a-f[:braille:]]}           {charclass {97 102} braille}
    ++ N08 {[a-f[:braille:]\55]}        {charclass 45 {97 102} braille}

    ++ N09 {[a]:i}                      {charclass 65 97}
    ++ N09 {[a]:ic}                     {charclass 65 97}
    ++ N09 {[\55]:i}                    {character 45}
    ++ N10 {[a-f]:i}                    {charclass {65 70} {97 102}}
    ++ N11 {[[:braille:]]:i}            {%named-class braille}
    ++ N12 {[a[:braille:]]:i}           {charclass 65 97 %braille}
    ++ N12 {[[:braille:]\55]:i}         {charclass 45 %braille}
    ++ N12 {[a-f\55]:i}                 {charclass 45 {65 70} {97 102}}
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
    ++ N16 {[^a-c\055[:braille:]b-f]}   {^charclass 45 {97 102} braille}

    ++ N17 {[^a]:i}                     {^charclass 65 97}
    ++ N17 {[^\x2d]:i}                  {^character 45}
    ++ N18 {[^a-f]:i}                   {^charclass {65 70} {97 102}}
    ++ N19 {[^[:braille:]]:i}           {^%named-class braille}
    ++ N20 {[^[:braille:]a]:i}          {^charclass 65 97 %braille}
    ++ N20 {[^[:braille:]\055]:i}       {^charclass 45 %braille}
    ++ N20 {[^a-c\055b-f]:i}            {^charclass 45 {65 70} {97 102}}
    ++ N20 {[^\055\056\057a]:i}         {^charclass {45 47} 65 97}
    ++ N20 {[^[:braille:]a-f]:i}        {^charclass {65 70} {97 102} %braille}
    ++ N20 {[^[:braille:]\55-/]:i}      {^charclass {45 47} %braille}
    ++ N20 {[^\055abcdef[:braille:]]:i} {^charclass 45 {65 70} {97 102} %braille}

    ++ CC0 "\[^\"\\\\\[:control:]]"     {^charclass 34 92 control}

    # Go over all the forms an escape can take.
    # Go into codepoints outside of the BMP too.

    ++ N01 {'\a\b\f\n\r\t\v\\'} {string 7 8 12 10 13 9 11 92}
    ++ N01 {'\0'}               {character 0}
    ++ N01 {'\10'}              {character 8}
    ++ N01 {'\100'}             {character 64}
    ++ N01 {'\377'}             {character 255}
    ++ N01 {'\xFF'}             {character 255}
    ++ N01 {'\xFFAB'}           {string 255 65 66}
    ++ N01 {'\uF'}              {character 15}
    ++ N01 {'\uFF'}             {character 255}
    ++ N01 {'\uFFF'}            {character 4095}
    ++ N01 {'\uFFFF'}           {character 65535}
    ++ N01 {'\u10000'}          {character 65536}
    ++ N01 {'\u1FFFF'}          {character 131071}
    ++ N01 {'\u10FFFF'}         {character 1114111}
    ++ N01 {'\U0010FFFF'}       {character 1114111}
    ++ N01 {'\u10FFFE'}         {character 1114110}
    ++ N01 {'\U0010FFFE'}       {character 1114110}
    ++ N01 {'\u00000F'}         {character 15}
    ++ N01 {'\uFFFE'}           {character 65534}
    ++ N01 {'\u10F60F'}         {character 1111567}
    ++ N01 {'\uD800'}           {character 55296}
    ++ N01 {'\uDB00'}           {character 56064}

    # ++ N01 {'\'} {string }
    # ++ N01 {'\'} {string }
    # ++ N01 {'\'} {string }
    # ++ N01 {'\'} {string }
    # ++ N01 {'\'} {string }
    # ++ N01 {'\'} {string }
    # ++ N01 {'\'} {string }
    # ++ N01 {'\'} {string }
    # ++ N01 {'\'} {string }

    **
}

# # ## ### ##### ######## #############
return
