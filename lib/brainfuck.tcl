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

namespace eval ::brainfuck {
    variable dp 0                   ; # Data pointer
    variable pp 0                   ; # Program pointer
    variable tape [lrepeat 3000 0]  ; # Data tape
    variable bracketIndex           ; # Index of brackets (dict)
    variable prog {}                ; # source code 

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
    
    proc index_brackets {program} {
	variable bracketIndex
	
	set bracketIndex [dict create] ; # matched brackets
	set levels [dict create]       ; # match by levels
	set level 0                    ; # level counter
	set i 0                        ; # position counter
	
	foreach c $program {
	    switch -- $c {[} {
		incr level
		dict set levels $level $i
	    } {]} {
		set match [dict get $levels $level]
		dict set bracketIndex $i $match
		dict set bracketIndex $match $i
		incr level -1
	    } default {}	
	    incr i
	}
	
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
    proc run {program} {
	variable prog
	variable pp
	
	set prog $program    
	set end [llength $program]
	
	index_brackets $program
	
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
    
    proc > {} {
	variable dp
	
	incr dp
    }
    
    # ::brainfuck::<
    #
    #         Decrements the data pointer (dp)
    #
    
    proc < {} {
	variable dp
	
	incr dp -1
    }
    
    # ::brainfuck::+
    #
    #         Increments data @ tape[dp] by one
    #
    proc + {} {
	variable dp
	variable tape
	
	lset tape $dp [expr {[lindex $tape $dp] + 1}]
    }
    
    # ::brainfuck::-
    #
    #         Decrements data @ tape[dp] by one
    #

    proc - {} {
	variable dp
	variable tape

	lset tape $dp [expr {[lindex $tape $dp] - 1}]
    }
    
    # ::brainfuck::,
    #
    #         Input. Reads an integer between 0 and 255,
    #         and update tape[dp] with this value
    #
    
    proc , {} {
	variable tape
	variable dp
	
	set correct false
	while {!correct} {
	    set c [read stdin 1]
	    set r [scan $c "%d" n]
	    if {$r && $n > -1 && $n < 256} {
		lset tape $dp $n
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
    
    proc . {} {
	variable dp
	variable tape
	
	puts -nonewline [format %c [lindex $tape $dp]]
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
    
    proc {[} {} {
	variable bracketIndex
	variable dp
	variable pp
	variable tape
	
	if {![lindex $tape $dp]} {
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
    
    proc {]} {} {
	variable bracketIndex
	variable dp
	variable pp
	variable tape
	
	if {[lindex $tape $dp]} {  
	    set pp [dict get $bracketIndex $pp]
	}
    }
    
    # ::brainfuck::load
    #
    #         Load a file with the brainfuck program and
    #         filter only valid instructions and change
    #         every `[` for `f` and `]` for a `b`.
    #
    proc load {filename} {    
	set src [fileutil::cat $filename]
	set program {}
		
	for {set i 0} {$i < [string length $src]} {incr i} {
	    
	    set c [string index $src $i]
	    
	    switch -- $c {
		"<"  -
		">"  -
		"+"  -
		"-"  -
		"."  -
		","  -		   
		"\[" -
		"\]" {
		    lappend program $c
		} default {
		    ; # ignore
		}
	    }
	}
	
	return $program
    }
    
}
