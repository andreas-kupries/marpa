# -*- tcl -*-
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
# Test cases for symbol creation from literal

proc lit-symbol {} {
    ++ {%named-class braille}                        @%NCC:<\[:braille:\]>
    ++ {%string 65 45}                               @%STR:<A->
    ++ {^%named-class braille}                       @^%NCC:<\[:braille:\]>
    ++ {^character 45}                               @^CHR:<->
    ++ {^character 97}                               @^CHR:<a>
    ++ {^charclass 45 %braille}                      @^CLS:<-\[:%braille:\]>
    ++ {^charclass 45 {65 70} {97 102} %braille}     @^CLS:<-A-Fa-f\[:%braille:\]>
    ++ {^charclass 45 {65 70} {97 102}}              @^CLS:<-A-Fa-f>
    ++ {^charclass 45 {97 102} braille}              @^CLS:<-a-f\[:braille:\]>
    ++ {^charclass 45 {97 102}}                      @^CLS:<-a-f>
    ++ {^charclass 65 97 %braille}                   @^CLS:<Aa\[:%braille:\]>
    ++ {^charclass 65 97}                            @^CLS:<Aa>
    ++ {^charclass 97 braille}                       @^CLS:<a\[:braille:\]>
    ++ {^charclass {45 47} %braille}                 @^CLS:<--/\[:%braille:\]>
    ++ {^charclass {45 47} 65 97}                    @^CLS:<--/Aa>
    ++ {^charclass {65 70} {97 102} %braille}        @^CLS:<A-Fa-f\[:%braille:\]>
    ++ {^charclass {65 70} {97 102}}                 @^CLS:<A-Fa-f>
    ++ {^charclass {97 102} braille}                 @^CLS:<a-f\[:braille:\]>
    ++ {^named-class braille}                        @^NCC:<\[:braille:\]>
    ++ {^range 97 102}                               @^RAN:<af>
    ++ {character 45}                                @CHR:<->
    ++ {character 97}                                @CHR:<a>
    ++ {charclass 45 %braille}                       @CLS:<-\[:%braille:\]>
    ++ {charclass 45 {65 70} {97 102} %braille}      @CLS:<-A-Fa-f\[:%braille:\]>
    ++ {charclass 45 {65 70} {97 102}}               @CLS:<-A-Fa-f>
    ++ {charclass 45 {97 102} braille}               @CLS:<-a-f\[:braille:\]>
    ++ {charclass 45 {97 102}}                       @CLS:<-a-f>
    ++ {charclass 65 97 %braille}                    @CLS:<Aa\[:%braille:\]>
    ++ {charclass 65 97}                             @CLS:<Aa>
    ++ {charclass 97 braille}                        @CLS:<a\[:braille:\]>
    ++ {charclass {45 47} %braille}                  @CLS:<--/\[:%braille:\]>
    ++ {charclass {45 47} 65 97}                     @CLS:<--/Aa>
    ++ {charclass {65 70} {97 102} %braille}         @CLS:<A-Fa-f\[:%braille:\]>
    ++ {charclass {65 70} {97 102}}                  @CLS:<A-Fa-f>
    ++ {charclass {97 102} braille}                  @CLS:<a-f\[:braille:\]>
    ++ {named-class braille}                         @NCC:<\[:braille:\]>
    ++ {range 97 102}                                @RAN:<af>
    ++ {string 97 45}                                @STR:<a->

    # Codepoints beyond the BMP

    ++ {character 65535}   @CHR:<\\uffff>
    ++ {character 65536}   @CHR:<\\u10000>
    ++ {character 131071}  @CHR:<\\u1ffff>
    ++ {character 131070}  @CHR:<\\u1fffe>
    ++ {character 1114111} @CHR:<\\u10ffff>
    ++ {character 1114110} @CHR:<\\u10fffe>
    ++ {character 1111567} @CHR:<\\u10f60f>

    **
}

# # ## ### ##### ######## #############
return
