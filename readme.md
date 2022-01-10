# Mini LISP Interpreter


## How to Compile ?
- run the code with the correspond name
- Change **final** to the name of the lex and yacc
```
bison -d -o final.tab.c final.y
gcc -c -g -I.. final.tab.c
 flex -o lex.yy.c final.l
gcc -c -g -I.. lex.yy.c
gcc -o final final.tab.o lex.yy.o -ll
```


### using language

- Yacc
- Lex
- C



## Feature

![](https://i.imgur.com/ERSbiJZ.png)


- [x] Syntax Validation
- [x] Print Statements
    - Print Number
    - Print Boolean
- [x] Numerical Operations
    - Addition
    - Subtraction
    - Multiplication
    - Division
    - Modulus
- [x] Logical Operations
    - And
    - Or
    - Not
- [x] If-Else Statement
- [x] Define Statements
    - Define Variable
    - Define Function
- [x] Function
    - Anonymous Function
    - Named Function
### Bonus
- [x] Recursion
- [x] Type Checking
- [x] Nested Function
- [x] First-Class Function

## Key point
- To build an AST tree, each AST node has it's own type.
- Whenever tranverse, check the type and do the correspond action.

- Struct 
    - Content : store the detail of the node.
    - TreeNode : node struct store the child and deatail pointer.
    - Function : to store the todo task, function name and parameters.
    
- definedVariables[MAX]
    - to store the pointer of defined variables.
- definedFunctions[MAX]
    - to storee the pointer of defined name functions.
