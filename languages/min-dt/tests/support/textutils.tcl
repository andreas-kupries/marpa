# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

kt require support fileutil

# Test suite support.
# # ## ### ##### ######## #############

proc fget  {path}     { fileutil::cat $path }
proc fgetc {path enc} { fileutil::cat -encoding $enc $path }

# # ## ### ##### ######## #############
return
