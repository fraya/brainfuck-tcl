# brainfuck-tcl
Brainfuck interpreter in Tcl

- Filters non-instruction characters from brainfuck source code.
- Creates an index of brackets.
- Uses a dict for `tape` instead of a `list`.
- Creates a `proc` for each instruction, so there is no `switch` in
  interpreter's loop.

## Usage

```
tclsh brainfuck.tcl <brainfuck-program>
```
There are brainfuck test programs in `./res` directory

## Requires

- Tcl 8.6
- Tcllib
