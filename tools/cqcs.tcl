#!/usr/bin/env tclsh
## See also export/rtc-critcl.tcl (CQCS)

package require char

# char quote cstring
# over \0 to \ff

puts "const char* marpatcl_qcs \[\] = \{"

for {set c 0} {$c < 256} {incr c} {
    set cq [char quote cstring [format %c $c]]
    puts "    /* [format %3d $c] = */ \"[char quote cstring $cq]\","
}

puts "    0\n\};"
