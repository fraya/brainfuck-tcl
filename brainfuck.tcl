lappend auto_path .

package require fileutil
package require brainfuck

if {$argc < 1} {
    puts "Usage: tclsh brainfuck.tcl <brainfuck-program>"
    exit 1
}

#
# Check for file's existence
#

set filename [lindex $argv 0]
if {![fileutil::test $filename fer msg]} {
    puts stderr "Error: $msg"
    exit 1
}

try {
    brainfuck::run [brainfuck::load $filename]
} on error {e} {
    puts $e
    exit 1
}

