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

    set program  [brainfuck::read_program $filename]
    set brackets [brainfuck::make_index_brackets $program]

    fconfigure stdout -buffering none
    fconfigure stdin  -buffering none
    brainfuck::run $program $brackets 

    exit 0
    
} on error {e} {
    puts $e
    exit 1
}

