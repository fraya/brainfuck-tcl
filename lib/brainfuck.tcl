# brainfuck.tcl --
#
#         Brainfuck interpreter
#
# Copyright (c) 2016 Fernando Raya
#
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES
#

package provide brainfuck 0.1

package require fileutil

#
# The tape is a dictionary, so only the data cells used
# are present in dictionary.
#
namespace eval ::brainfuck {
    variable dp 0                ; # Data pointer
    variable pp 0                ; # Program pointer
    variable tape [dict create]  ; # Data tape
    variable bracketIndex        ; # Index of brackets (dict)
    variable prog {}             ; # source code 
}

# brainfuck::index_brackets
#
#         Create an index that matches every `[` with `]`.
#
# Arguments:
#         program    List with brainfuck instructions
#
# Results:
#         A dictionary with an entry with `[` like key and
#         the matched `]` as value, and `]` as key and `[` as
#         value.
#

proc ::brainfuck::index_brackets {program} {
    
    set result  [dict create]   ; # matched brackets
    set levels  [dict create]   ; # match by levels
    set level 0                 ; # level counter
    set i 0                     ; # position counter

    foreach c $program {
	switch -- $c f {
	    incr level
	    dict set levels $level $i
	} b {
	    set match [dict get $levels $level]
	    dict set result $i $match
	    dict set result $match $i
	    incr level -1
	} default {}	
	incr i
    }
    
    return $result
}

# brainfuck::run
#
#         Execute a program, instruction by instruction.
#         All instructions have the same name that
#         a `proc` in the `::brainfuck` namespace. The
#         process is: read instruction, execute instruction.
#
# Arguments:
#         program    List of brainfuck instructions
#
# Results:
#         None
#
proc ::brainfuck::run {program} {
    variable bracketIndex
    variable prog
    variable pp
    
    set prog $program
    set bracketIndex [index_brackets $program]
    set end [llength $program]

    
    while {$pp < $end} {
        set op [lindex $prog $pp]  ; # Read the current instruction
	$op                        ; # Execute instruction
        incr pp                    ; # Move to next instruction
    }
}

# ::brainfuck::>
#
#         Increments the data pointer (dp)
#

proc ::brainfuck::> {} {
    variable dp
    
    incr dp
}

# ::brainfuck::<
#
#         Decrements the data pointer (dp)
#

proc ::brainfuck::< {} {
    variable dp
    
    incr dp -1
}

# ::brainfuck::+
#
#         Increments data @ tape[dp] by one
#
proc ::brainfuck::+ {} {
    variable dp
    variable tape

    #
    # `dict incr` creates an entry with value 0, if
    # it does not exists, then increments
    #
    
    dict incr tape $dp 1
}

# ::brainfuck::-
#
#         Decrements data @ tape[dp] by one
#

proc ::brainfuck::- {} {
    variable dp
    variable tape

    #
    # `dict incr` creates an entry with value 0, if
    # it does not exists, then decrements
    #
    
    dict incr tape $dp -1
}

# ::brainfuck::,
#
#         Input. Reads an integer between 0 and 255,
#         and update tape[dp] with this value
#

proc ::brainfuck::, {} {
    variable tape
    variable dp
    
    set correct false
    while {!correct} {
        set c [read stdin 1]
        set r [scan $c "%d" n]
        if {$r && $n > -1 && $n < 256} {
	    dict set tape $dp $n
        } else {
            puts "Incorrect input"
        }   
    }
}

# ::brainfuck::.
#
#         Output. Prints the value of tape[dp] as
#         a character.
#

proc ::brainfuck::. {} {
    variable dp
    variable tape
    
    puts -nonewline [format %c [dict get $tape $dp]]
}

# ::brainfuck::f
#
#         Jump forward. If tape[dp] is 0, jumps
#         to the position of the matched bracket `]`,
#         changing `pp`.
#
#         The name of the `proc` cannot be `[` so this
#         instruction is changed for `f`.
#

proc ::brainfuck::f {} {
    variable bracketIndex
    variable dp
    variable pp
    variable tape

    #
    # If the cell does not exists, is created.
    #
    
    if {![dict exists $tape $dp]} {
	dict set tape $dp 0
    }

    if {![dict get $tape $dp]} {
	set pp [dict get $bracketIndex $pp]
    }
}

# ::brainfuck::b
#
#         Jump backward. If tape[dp] is not 0, jumps
#         to the position of the matched bracket `[`,
#         changing `pp`.
#
#         The name of the `proc` cannot be `]` so this
#         instruction is changed for `b`.
#

proc ::brainfuck::b {} {
    variable bracketIndex
    variable dp
    variable pp
    variable tape

    #
    # If the cell does not exists, is created.
    #
    
    if {![dict exists $tape $dp]} {
	dict set tape $dp 0
    }
    
    if {[dict get $tape $dp]} {  
	set pp [dict get $bracketIndex $pp]
    }
}

# ::brainfuck::load
#
#         Load a file with the brainfuck program and
#         filter only valid instructions and change
#         every `[` for `f` and `]` for a `b`.
#
proc ::brainfuck::load {filename} {    
    set src [fileutil::cat $filename]
    set program {}

    set n [string length $src]
    
    for {set i 0} {$i < $n} {incr i} {
	
        set c [string index $src $i]
	
	switch -- $c {
	    "<" -
	    ">" -
	    "+" -
	    "-" -
	    "." -
	    "," {
		lappend program $c
	    }
	    "\[" {
		lappend program f
	    }
	    "\]" {
		lappend program b
	    } default {
		; # ignore
	    }
	}
    }
    
    return $program
}

