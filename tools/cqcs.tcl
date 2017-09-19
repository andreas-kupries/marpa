#!/usr/bin/env tclsh

package require char

# char cquote string
# over \0 to \ff

puts "static const char* quote_cstring \[\] = \{"

for {set c 0} {$c < 256} {incr c} {
    set cq [char quote cstring [format %c $c]]
    puts "    /* [format %3d $c] = */ \"[char quote cstring $cq]\","
}

puts "    0\n\};"
