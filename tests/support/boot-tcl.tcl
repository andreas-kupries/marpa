# -*- tcl -*- tcl.tk//DSL tcltest//EN//2.0 tcl.tk//DSL tcltest//EN//2.0
## (c) 2017 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## (tparse)

## Use the builtin parser and semantics to generate a tcl parser
## for a grammar specified via procedure `GrammarLocation`. The
## procedure `pclass` provides the name of the parser class to
## generate. At last, procedure `ParseFile` specifies the destination,
## the file the generated parser is stored into.
#
## This is a variant of `bin/marpa-gen` reduced to the minimum needed
## for reading, processing and exporting as tparse.

proc unboot-tcl {} {
    removeFile [ParserFile];#Disable when debugging
    rename ParserFile {}
    rename GrammarLocation {}
    return
}

proc boot-tcl {} {
    # _ __ ___ _____ ________ _____________ _____________________
    # The builtin lexer, parser and uncore are used to process the
    # SLIF meta grammar and create a full-blown tcl-based engine for
    # it (via the proper exporter). This engine is used, in turn, to
    # process all the test cases.
    
    # _ __ ___ _____ ________ _____________ _____________________
    # I. Create the processor
    marpa::slif::container create GC
    marpa::slif::semantics create SEMX GC
    marpa::slif::parser    create BOOT

    # _ __ ___ _____ ________ _____________ _____________________
    # II. Process the slif meta grammar
    SEMX process [BOOT process-file [GrammarLocation]/slif]
    # GC now holds the grammar
    BOOT destroy
    # Note: SEMX auto-destroys itself at the end of 'process'.

    # _ __ ___ _____ ________ _____________ _____________________
    # III. Generate a tcl-based parser class
    marpa::export config! version  1
    marpa::export config! writer   {Jeffrey Kegler + Andreas Kupries}
    marpa::export config! year     2017
    marpa::export config! name     [pclass]
    marpa::export config! operator $::tcl_platform(user)@[info hostname]
    marpa::export config! tool     [info script]

    set parser [marpa::export::tparse container GC]
    GC destroy
    # Write to file for debugging.
    fileutil::writeFile [ParserFile] $parser

    # _ __ ___ _____ ________ _____________ _____________________
    # IV. Load and activate the new class.
    uplevel #0 $parser
    # _ __ ___ _____ ________ _____________ _____________________
    return


}
