# Stack Based ALU + Infix Expression parser and evaluator

Author: Alireza Samimi 401110501

## Evaluating Infix Expressions

Shunting Yard algorithm is used to convert infix expressions to postfix expressions. The postfix expression is then evaluated using the stack based ALU
implemented in this project.

It is tested with some expressions (including the one in problem statement) in the testbench.

The module reads the expression from a register array writes the result to the result register when it is done and sets the ready flag. It parses the expression and evaluates it at the same time
to avoid needing to store the postfix expression. It has 4 states
with PARSE and EVAL states being the main states. It uses a stack to store the operators and another for the operands.

## Stack

The stack is implemented in SystemVerilog. It has WIDTH and DEPTH parameters to specify the width of the data and the depth of the stack. The stack has
opcodes for push, pop, addition and multiplication. The stack is implemented using a register array. It has full, empty and overflow flags to indicate
the status of the stack.

It is tested using testbenches for 4, 8, 16 and 32 bit data widths.

## Testing

The modules have been tested using the testbenches in QuestaIntel.

## Links

[Shunting Yard Algorithm](https://en.wikipedia.org/wiki/Shunting_yard_algorithm)
