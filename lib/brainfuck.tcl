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
    variable brackets               ; # Index of brackets (dict)
    variable program                ; # source code 

    #
    # Read a brainfuck source file and filter instructions
    #
    # @param filename A brainfuck source code
    # @result A list with instructions
    #
    
    proc read_program {filename} {

	set src     [fileutil::cat $filename]
	set program [list]

	for {set i 0} {$i < [string length $src]} {incr i} {
	    
	    set c [string index $src $i]
	    
	    switch -- $c "<" - ">" - "+" - "-" - "." - "," - "\[" - "\]" {
		lappend program $c
	    } default {
		; # ignore non instructions characters
	    }
	}

	return $program
    }
    
	
    proc make_index_brackets {program} {
	
	set brackets [dict create]  
	set levels   [dict create]  
	set level 0
	
	for {set i 0} {$i < [llength $program]} {incr i} {
	    
	    set c [lindex $program $i]
	    
	    switch -- $c "\[" {
		incr level
		dict set levels $level $i
	    } "]" {
		set match [dict get $levels $level]
		dict set brackets $i $match
		dict set brackets $match $i
		incr level -1
	    } default {}
	}

	return $brackets
    }

    #
    # Execute a program, instruction by instruction.  All instructions
    # have the same name that a `proc` in the `::brainfuck`
    # namespace. The process is: read instruction, execute
    # instruction.
    #
    # @param prog List of brainfuck instructions
    # @param bracketIndex A dictionary with the matched `[` `]`
    # instructions
    # @return None
    #
    
    proc run {prog bracketIndex} {
	
	variable brackets $bracketIndex
	variable program  $prog
	variable pp 0
		
	while {$pp < [llength $program]} {
	    set op [lindex $program $pp]   
	    $op                           
	    incr pp                       
	}
	
    }
    
    # 
    # Increments the data pointer (dp)
    #
    
    proc > {} {
	
	variable dp
	
	incr dp
    }
    
    # 
    # Decrements the data pointer (dp)
    #
    
    proc < {} {
	
	variable dp
	
	incr dp -1
    }
    
    # 
    # Increments data @ tape[dp] by one
    #
    proc + {} {
	
	variable dp
	variable tape
	
	lset tape $dp [expr {[lindex $tape $dp] + 1}]
    }
    
    # 
    # Decrements data @ tape[dp] by one
    #

    proc - {} {
	
	variable dp
	variable tape

	lset tape $dp [expr {[lindex $tape $dp] - 1}]
    }
    
    # 
    # Input. Reads an integer between 0 and 255,
    # and update tape[dp] with this value
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
    
    # 
    # Output. Prints the value of tape[dp] as
    # a character.
    #
    
    proc . {} {
	
	variable dp
	variable tape
	
	puts -nonewline [format %c [lindex $tape $dp]]
    }
    
    #
    # Jump forward. If tape[dp] is 0, jumps to the position of the
    # matched bracket `]`, changing `pp`.
    #
    
    proc {[} {} {
	
	variable brackets
	variable dp
	variable pp
	variable tape
	
	if {![lindex $tape $dp]} {
	    set pp [dict get $brackets $pp]
	}
    }
    
    #
    # Jump backward. If tape[dp] is not 0, jumps to the position of
    # the matched bracket `[`, changing `pp`.
    #

    proc {]} {} {
	
	variable brackets
	variable dp
	variable pp
	variable tape
	
	if {[lindex $tape $dp]} {  
	    set pp [dict get $brackets $pp]
	}
    }
    
    
}
