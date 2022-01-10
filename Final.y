
%code requires{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>

    #define MAX 999

    int yylex();
    void yyerror(const char *message);

    struct Content {
        char*           type;
        char*           name;
        int             IntValue;
        int             boolValue;
    };

    struct TreeNode {
        struct Content* detail;
        
        struct TreeNode* leftChild;
        struct TreeNode* rightChild;
    };

    struct Content* newContent(char* type, char* variableName, int IntValue, int boolValue);
    struct Content* emptyContent();

    struct TreeNode* newNode(struct Content* detail, struct TreeNode* leftChild, struct TreeNode* rightChild);
    struct TreeNode* emptyNode();

    void traverse(struct TreeNode* node, char* parent_type, int insideFunction);

    struct TreeNode* root;

    struct TreeNode* definedVariables[MAX];
    int variableAmounts;

    void addVariable(struct TreeNode* node);
    struct TreeNode* getVariable(char* variableName);

    struct Function {
        char* funcName;        
        struct TreeNode* params;
        struct TreeNode* task;
    };
    
    struct Function* definedFunctions[MAX];
    int functionAmounts;

    struct TreeNode* cloneAST(struct TreeNode* node);

    void addFunction(char* funcName, struct TreeNode* theFunction);
    struct Function* getFunction(char* funcName);

    void assignParams(struct TreeNode* parametersName, struct TreeNode* parametersToAssign, struct TreeNode* functionTask);
    void bindParams(struct TreeNode* taskNode, struct TreeNode* replaceNode);

    // char* getTypeName(char* type);
    void typeChecking(struct TreeNode* node, char* type);

    struct TreeNode* freeNode(struct TreeNode* node);
}

%define parse.error verbose

%union {
    struct TreeNode* ASTN;
}

%type   <ASTN>  stmt
%type   <ASTN>  stmts
%type   <ASTN>  print_stmt

%type   <ASTN>  exp
%type   <ASTN>  exps

%type   <ASTN>  num_op
%type   <ASTN>  logical_op

%type   <ASTN>  def_stmt
%type   <ASTN>  variable

%type   <ASTN>  function_exp
%type   <ASTN>  ids
%type   <ASTN>  function_call
%type   <ASTN>  function_ids
%type   <ASTN>  function_body
%type   <ASTN>  function_name
%type   <ASTN>  parameters

%type   <ASTN>  if_exp
%type   <ASTN>  test_exp
%type   <ASTN>  then_exp
%type   <ASTN>  else_exp

%token  <ASTN>  NUMBER
%token  <ASTN>  ID
%token  <ASTN>  BOOL

%token  <ASTN>  PRINT_NUM
%token  <ASTN>  PRINT_BOOL

%token  <ASTN>  ADD
%token  <ASTN>  SUB
%token  <ASTN>  MUL
%token  <ASTN>  DIV
%token  <ASTN>  MOD

%token  <ASTN>  BIGGER_THAN
%token  <ASTN>  SMALLER_THAN
%token  <ASTN>  EQUAL

%token  <ASTN>  AND
%token  <ASTN>  OR
%token  <ASTN>  NOT

%token  <ASTN>  DEFINE
%token  <ASTN>  FUNCTION
%token  <ASTN>  IF
%%

program         :   stmts       {
                    root = $1;
                }

stmts           :   stmt stmts  {
                    $$ = newNode(emptyContent(), $1, $2);
                }
                |   stmt        {
                    $$ = $1;
                }

stmt            :   exp         {
                    $$ = $1;
                }
                |   def_stmt    {
                    $$ = $1;
                }
                |   print_stmt  {
                    $$ = $1;
                }
                ;

print_stmt      :   '(' PRINT_NUM   exp ')' {
                    $$ = newNode(newContent("print_num", NULL, 0, 0), $3, NULL);
                }
                |   '(' PRINT_BOOL  exp ')' {
                    $$ = newNode(newContent("print_bool", NULL, 0, 0), $3, NULL);
                }

exps            :   exp exps    {
                    // as add equal and so on has exp exps, the node is to find the type of it's parent. 
                    $$ = newNode(newContent("equals_to_parent", NULL, 0, 0), $1, $2);
                }
                |   exp         {
                    $$ = $1;
                }

exp             :   BOOL            {
                    $$ = $1;
                }
                |   NUMBER          {
                    $$ = $1;
                }
                |   variable        {
                    $$ = newNode(newContent("get_var", $1->detail->name, 0, 0), NULL, NULL);
                }
                |   num_op          {
                    $$ = $1;
                }
                |   logical_op      {
                    $$ = $1;
                }
                |   function_exp    {                    
                    $$ = $1;
                }
                |   function_call   {                    
                    $$ = $1;
                }
                |   if_exp   {                    
                    $$ = $1;
                }
                ;

num_op          :   '(' ADD             exp exps    ')' {
                    $$ = newNode(newContent("add", NULL, 0, 0), $3, $4);
                }
                |   '(' SUB             exp exp     ')' {
                    $$ = newNode(newContent("sub", NULL, 0, 0), $3, $4);
                }
                |   '(' MUL             exp exps    ')' {
                    $$ = newNode(newContent("mul", NULL, 0, 0), $3, $4);
                }
                |   '(' DIV             exp exp     ')' {
                    $$ = newNode(newContent("div", NULL, 0, 0), $3, $4);
                }
                |   '(' MOD             exp exp     ')' {
                    $$ = newNode(newContent("mod", NULL, 0, 0), $3, $4);
                }
                |   '(' BIGGER_THAN     exp exp     ')' {
                    $$ = newNode(newContent("bigger_than", NULL, 0, 0), $3, $4);
                }
                |   '(' SMALLER_THAN    exp exp     ')' {
                    $$ = newNode(newContent("smaller_than", NULL, 0, 0), $3, $4);
                }
                |   '(' EQUAL           exp exps    ')' {
                    $$ = newNode(newContent("equal", NULL, 0, 0), $3, $4);
                }

logical_op      :   '(' AND     exp exps    ')' {
                    $$ = newNode(newContent("and", NULL, 0, 0), $3, $4);
                }
                |   '(' OR      exp exps    ')' {
                    $$ = newNode(newContent("or", NULL, 0, 0), $3, $4);
                }
                |   '(' NOT     exp         ')' {
                    $$ = newNode(newContent("not", NULL, 0, 0), $3, NULL);
                }

def_stmt        :   '(' DEFINE ID exp ')'   {
                    if(strcmp($4->detail->type, "function") == 0) {
                        $$ = newNode(newContent("df_func", NULL, 0, 0), $3, $4);
                    } else {
                        $$ = newNode(newContent("df_var", NULL, 0, 0), $3, $4);
                    }
                }
                ;

variable        :   ID  {
                    $$ = $1;
                }

function_exp    :   '(' FUNCTION function_ids function_body ')' {
                    $$ = newNode(newContent("function", NULL, 0, 0), $3, $4);
                }

ids             :   ID  ids     {
                    $$ = newNode(newContent("function_parameters", NULL, 0, 0), $1, $2);
                }
                |               {
                    $$ = emptyNode();
                }
                ; 

function_ids    :   '(' ids ')' {
                    $$ = $2;
                }
//Nested Function 
function_body   :   def_stmt function_body  {
                    $$ = newNode(newContent("df_inside_func", NULL, 0, 0), $1, $2);
                }
                |   exp                     {
                    $$ = $1;
                }

function_call   :   '(' function_exp    parameters ')'  {
                    $$ = newNode(newContent("call_func", NULL, 0, 0), $2, $3);
                }
                |   '(' function_name   parameters ')'  {
                    $$ = newNode(newContent("call_func", NULL, 0, 0), $2, $3);
                }

parameters      :   exp parameters  {
                    $$ = newNode(newContent("function_parameters", NULL, 0, 0), $1, $2);
                }
                |                   {
                    $$ = emptyNode();
                }

function_name   :   ID  {
                    $$ = $1;
                }

if_exp          :   '(' IF test_exp then_exp else_exp ')'     {
                    struct TreeNode* ifStatements = newNode(newContent("if_stmts", NULL, 0, 0), $4, $5);
                    $$ = newNode(newContent("if_else", NULL, 0, 0), $3, ifStatements);
                }

test_exp        :   exp     {
                    $$ = $1;
                }

then_exp        :   exp     {
                    $$ = $1;
                }

else_exp        :   exp     {
                    $$ = $1;
                }

%%

struct Content* newContent(char* type, char* name, int IntValue, int boolValue) {
    struct Content* toCreate = (struct Content *) malloc(sizeof(struct Content));

    toCreate->type = type;
    toCreate->name = name;

    toCreate->IntValue = IntValue;
    toCreate->boolValue = boolValue;

    return toCreate;
}

struct Content* emptyContent() {
    return newContent("no_type", NULL, 0, 0);
}

struct TreeNode* newNode(struct Content* detail, struct TreeNode* leftChild, struct TreeNode* rightChild) {
    struct TreeNode* toCreate = (struct TreeNode *) malloc(sizeof(struct TreeNode));

    toCreate->detail = detail;
    toCreate->leftChild = leftChild;
    toCreate->rightChild = rightChild;

    return toCreate;
}

struct TreeNode* emptyNode() {
    return newNode(emptyContent(), NULL, NULL);
}

void addVariable(struct TreeNode* node) {
    definedVariables[++variableAmounts] = node;
}

struct TreeNode* getVariable(char* name) {
    for(int i = 0; i <= variableAmounts; i++) {
        if(strcmp(definedVariables[i]->detail->name, name) == 0) {
            return cloneAST(definedVariables[i]);
        }
    }
}

struct TreeNode* cloneAST(struct TreeNode* node) {
    if(node == NULL) {
        return NULL;
    }
    
    struct TreeNode* toClone = emptyNode();

    toClone->detail->type = node->detail->type;
    toClone->detail->name = node->detail->name;

    toClone->detail->IntValue = node->detail->IntValue;
    toClone->detail->boolValue = node->detail->boolValue;

    toClone->leftChild = cloneAST(node->leftChild);
    toClone->rightChild = cloneAST(node->rightChild);

    return toClone;
}

void addFunction(char* Name, struct TreeNode* theFunction) {
    struct Function* adding = (struct Function *) malloc(sizeof(struct Function));

    adding->funcName = Name;
    adding->params = theFunction->leftChild;
    adding->task = theFunction->rightChild;

    definedFunctions[++functionAmounts] = adding;
}

struct Function* getFunction(char* funcName) {
    for(int i = 0; i <= functionAmounts; i++) {
        if(strcmp(definedFunctions[i]->funcName, funcName) == 0) {
            struct Function* result = (struct Function *) malloc(sizeof(struct Function));

            result->funcName = strdup(definedFunctions[i]->funcName);
            result->params = cloneAST(definedFunctions[i]->params);
            result->task = cloneAST(definedFunctions[i]->task);

            return result;
        }
    }

    return NULL;
}
//later
void assignParams(struct TreeNode* parametersName, struct TreeNode* parametersToAssign, struct TreeNode* functionTask) {
    /* to do 3 type */
    /*  1.no para 2.variable ...Bonus :3.function */
    
    
    char* tmp[MAX] ;
    strcpy (tmp, parametersName->detail->type);
    if(strcmp(tmp,"no_type") == 0) {
        //end
        return;
    }else {//if(strcmp(tmp,"function_parameters") == 0){ 
       
        parametersToAssign->leftChild->detail->name = parametersName->leftChild->detail->name;

        bindParams(functionTask, cloneAST(parametersToAssign->leftChild));

        assignParams(parametersName->rightChild, parametersToAssign->rightChild, functionTask);
    }
}
void bindParams(struct TreeNode* taskNode, struct TreeNode* replaceNode) {
    if(taskNode == NULL || strcmp(taskNode->detail->type,"df_func") == 0) {
        return;
    }
    if(strcmp(taskNode->detail->type,"string") == 0 && strcmp(replaceNode->detail->type, "function") == 0) {
        
        //bind function call
        taskNode->detail->type = replaceNode->detail->type;

        taskNode->detail->IntValue = replaceNode->detail->IntValue;
        taskNode->detail->boolValue = replaceNode->detail->boolValue;

        taskNode->leftChild = cloneAST(replaceNode->leftChild);
        taskNode->rightChild = cloneAST(replaceNode->rightChild);


        // printf("task (string && func) : %s\n", taskNode->detail->name);
        // printf("======================\n");


        return;
    } else if(strcmp(taskNode->detail->type, "get_var") == 0) {
        if(strcmp(taskNode->detail->name, replaceNode->detail->name) == 0) {
            // printf("replace %s %s %d\n", replaceNode->detail->type,replaceNode->detail->name,replaceNode->detail->IntValue);
            // printf("================\n");

            taskNode->detail->type = replaceNode->detail->type;

            taskNode->detail->IntValue = replaceNode->detail->IntValue;
            taskNode->detail->boolValue = replaceNode->detail->boolValue;

            taskNode->leftChild = cloneAST(replaceNode->leftChild);
            taskNode->rightChild = cloneAST(replaceNode->rightChild);
            return;
        }
    }
    // printf("bind: %s : %d \n", taskNode->detail->type,taskNode->detail->IntValue);
    // printf("bind: %s : %s :%d \n", replaceNode->detail->type,replaceNode->detail->name,replaceNode->detail->IntValue);
    // printf("========================\n");
    bindParams(taskNode->leftChild, replaceNode);
    bindParams(taskNode->rightChild, replaceNode);
}


void typeChecking(struct TreeNode* node, char* type) {
    if(strcmp(node->detail->type,type) != 0) {
        printf( "Type Error: Expecting '%s', but got '%s'.\n", type, node->detail->type);
        exit(0);
    }
    
}

struct TreeNode* freeNode(struct TreeNode* node) {
    if(node == NULL) {
        return NULL;
    }

    freeNode(node->leftChild);
    freeNode(node->rightChild);

    free(node);

    return NULL;
}

void traverse(struct TreeNode* node, char* parent_type, int insideFunction) {
    if(node == NULL) {
        return;
    }
    char* tmp[MAX];
    strcpy (tmp, node->detail->type);
    if(strcmp(tmp, "no_type") == 0) {
            traverse(node->leftChild, node->leftChild->detail->type, insideFunction);
            traverse(node->rightChild, node->rightChild->detail->type, insideFunction);
    } else if(strcmp(tmp, "equals_to_parent") == 0){
        node->detail->type = parent_type;
        traverse(node, node->detail->type, insideFunction);
    }
    else if(strcmp(tmp, "print_num") == 0){
        traverse(node->leftChild, node->leftChild->detail->type, insideFunction);

        typeChecking(node->leftChild, "integer");

        printf("%d\n", node->leftChild->detail->IntValue);

    }
    else if(strcmp(tmp, "print_bool") == 0){
        traverse(node->leftChild, node->leftChild->detail->type, insideFunction);

        typeChecking(node->leftChild, "boolean");

        char* bools;
        if(node->leftChild->detail->boolValue)
            bools = "#t";
        else
            bools = "#f";
        printf("%s\n", bools);

    }
    else if(strcmp(tmp, "add") == 0){
        /*As top says, here we tranverse child with the type add, so the child which is seperate by exps can chenge there type "Equal to parent to add."*/
        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "integer");
        typeChecking(node->rightChild, "integer");

        /* after tranverse put the result type back to a single interger. */
        /* And free their using child. */
        node->detail->type = "integer";
        node->detail->IntValue = node->leftChild->detail->IntValue + node->rightChild->detail->IntValue;

        node->leftChild = freeNode(node->leftChild);
        node->rightChild = freeNode(node->rightChild);

    }
    else if(strcmp(tmp, "sub") == 0){
        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "integer");
        typeChecking(node->rightChild, "integer");

        node->detail->type = "integer";
        node->detail->IntValue = node->leftChild->detail->IntValue - node->rightChild->detail->IntValue;

        node->leftChild = freeNode(node->leftChild);
        node->rightChild = freeNode(node->rightChild);  
    }
    else if(strcmp(tmp, "mul") == 0){
        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "integer");
        typeChecking(node->rightChild, "integer");

        node->detail->type = "integer";
        node->detail->IntValue = node->leftChild->detail->IntValue * node->rightChild->detail->IntValue;

        node->leftChild = freeNode(node->leftChild);
        node->rightChild = freeNode(node->rightChild);
        
    }
    else if(strcmp(tmp, "div") == 0){
        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "integer");
        typeChecking(node->rightChild, "integer");

        node->detail->type = "integer";
        node->detail->IntValue = node->leftChild->detail->IntValue / node->rightChild->detail->IntValue;

        node->leftChild = freeNode(node->leftChild);
        node->rightChild = freeNode(node->rightChild); 
    }
    else if(strcmp(tmp, "mod") == 0){
        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "integer");
        typeChecking(node->rightChild, "integer");

        node->detail->type = "integer";
        node->detail->IntValue = node->leftChild->detail->IntValue % node->rightChild->detail->IntValue;

        node->leftChild = freeNode(node->leftChild);
        node->rightChild = freeNode(node->rightChild); 
    }
    else if(strcmp(tmp, "bigger_than") == 0){
        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "integer");
        typeChecking(node->rightChild, "integer");

        node->detail->type = "boolean";
        if (node->leftChild->detail->IntValue > node->rightChild->detail->IntValue) {
            node->detail->boolValue = 1; 
        }else{
            node->detail->boolValue = 0;
        }
        
        node->leftChild = freeNode(node->leftChild);
        node->rightChild = freeNode(node->rightChild);
    }
    else if(strcmp(tmp, "smaller_than") == 0){
        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "integer");
        typeChecking(node->rightChild, "integer");

        node->detail->type = "boolean";
        if (node->leftChild->detail->IntValue < node->rightChild->detail->IntValue){
            node->detail->boolValue = 1;
        }else{
            node->detail->boolValue = 0;
        }

        node->leftChild = freeNode(node->leftChild);
        node->rightChild = freeNode(node->rightChild);
    }
    else if(strcmp(tmp, "equal") == 0){ 

        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "integer");
        typeChecking(node->rightChild, "integer");

        
        node->detail->type = "boolean";
        node->detail->IntValue = node->leftChild->detail->IntValue;
        node->detail->boolValue = node->leftChild->detail->IntValue == node->rightChild->detail->IntValue;

        node->leftChild = freeNode(node->leftChild);
        node->rightChild = freeNode(node->rightChild);   
    }
    else if(strcmp(tmp, "and") == 0){
        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "boolean");
        typeChecking(node->rightChild, "boolean");
        
        node->detail->type = "boolean";
        node->detail->boolValue = node->leftChild->detail->boolValue && node->rightChild->detail->boolValue;

        node->leftChild = freeNode(node->leftChild);
        node->rightChild = freeNode(node->rightChild);
    }
    else if(strcmp(tmp, "or") == 0){
        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "boolean");
        typeChecking(node->rightChild, "boolean");

        node->detail->type = "boolean";
        node->detail->boolValue = node->leftChild->detail->boolValue || node->rightChild->detail->boolValue;

        node->leftChild = freeNode(node->leftChild);
        node->rightChild = freeNode(node->rightChild);
    }
    else if(strcmp(tmp, "not") == 0){
        traverse(node->leftChild, node->detail->type, insideFunction);

        typeChecking(node->leftChild, "boolean");

        node->detail->type ="boolean";
        if(node->leftChild->detail->boolValue == 1){
            node->detail->boolValue = 0;
        }else{
            node->detail->boolValue = 1;
        }

        node->leftChild = freeNode(node->leftChild);
    }
    else if(strcmp(tmp, "df_var") == 0){
        //put var name into the value node and put the node into array
        node->rightChild->detail->name = node->leftChild->detail->name;
        addVariable(node->rightChild);
    }
    else if(strcmp(tmp, "get_var") == 0){
        if(!insideFunction) {
            struct TreeNode* found = getVariable(node->detail->name);

            node->detail->type = found->detail->type;

            node->detail->IntValue = found->detail->IntValue;
            node->detail->boolValue = found->detail->boolValue;

            node->leftChild = cloneAST(found->leftChild);
            node->rightChild = cloneAST(found->rightChild);
            
            traverse(node, node->detail->type, insideFunction);
        }
    }
    else if(strcmp(tmp, "df_func") == 0){
        char* name = node->leftChild->detail->name;
        addFunction(name, node->rightChild);
    }
    // for nest function tranverse the function inside first
    else if(strcmp(tmp, "df_inside_func") == 0){
        traverse(node->leftChild, node->detail->type, insideFunction);
        traverse(node->rightChild, node->detail->type, insideFunction);
        // after run function body 
        node->detail->type = node->rightChild->detail->type;

        node->detail->IntValue = node->rightChild->detail->IntValue;
        node->detail->boolValue = node->rightChild->detail->boolValue;
    }
    else if(strcmp(tmp, "call_func") == 0){
        if(strcmp(node->leftChild->detail->type ,"function") == 0) {
            // function nested
            // function paras left child, body right child
            //(struct TreeNode* parametersName, struct TreeNode* parametersToAssign, struct TreeNode* functionTask)
            // ids -> left id , 
            assignParams(node->leftChild->leftChild, node->rightChild, node->leftChild->rightChild);
            // the last parameter means inside funciton is true
            traverse(node->leftChild->rightChild, node->leftChild->detail->type, 1);

            node->detail->type = node->leftChild->rightChild->detail->type;

            node->detail->IntValue = node->leftChild->rightChild->detail->IntValue;
            node->detail->boolValue = node->leftChild->rightChild->detail->boolValue;

            struct TreeNode* temp = cloneAST(node->leftChild);
            node->leftChild = cloneAST(node->leftChild->rightChild->leftChild);
            node->rightChild = cloneAST(temp->rightChild->rightChild);
        } else if(strcmp(node->leftChild->detail->type, "string") == 0) {
            // function name || variable name
            struct Function* functionToCall = getFunction(node->leftChild->detail->name);

            if(functionToCall != NULL) {
                assignParams(functionToCall->params, node->rightChild, functionToCall->task);

                traverse(functionToCall->task, functionToCall->task->detail->type, 1);

                node->detail->type = functionToCall->task->detail->type;

                node->detail->IntValue = functionToCall->task->detail->IntValue;
                node->detail->boolValue = functionToCall->task->detail->boolValue;

                node->leftChild = cloneAST(functionToCall->task->leftChild);
                node->rightChild = cloneAST(functionToCall->task->rightChild);
            } else {
                //the string is variable
                struct TreeNode* result = getVariable(node->leftChild->detail->name);

                node->leftChild->detail->type = result->detail->type;
                // printf("getVer : %s \n",node->leftChild->detail->type);

                node->leftChild->detail->IntValue = result->detail->IntValue;
                node->leftChild->detail->boolValue = result->detail->boolValue;

                node->leftChild->leftChild = cloneAST(result->leftChild);
                node->leftChild->rightChild = cloneAST(result->rightChild);

                traverse(node->leftChild, node->leftChild->detail->type, 1);
                /* node->leftChild->detail->type == function */

                traverse(node, node->detail->type, 1);
            }
        }

    }
    else if(strcmp(tmp, "if_else") == 0){
        //get the bool
        traverse(node->leftChild, node->detail->type, insideFunction);

        if(node->leftChild->detail->boolValue) {
            traverse(node->rightChild->leftChild, node->rightChild->leftChild->detail->type, insideFunction);

            node->detail->type = node->rightChild->leftChild->detail->type;
            
            node->detail->IntValue = node->rightChild->leftChild->detail->IntValue;
            node->detail->boolValue = node->rightChild->leftChild->detail->boolValue;
        } else {
            traverse(node->rightChild->rightChild, node->rightChild->rightChild->detail->type, insideFunction);

            node->detail->type = node->rightChild->rightChild->detail->type;
            
            node->detail->IntValue = node->rightChild->rightChild->detail->IntValue;
            node->detail->boolValue = node->rightChild->rightChild->detail->boolValue;
        }

    }
}

void yyerror(const char *message) {
    fprintf(stderr, "%s\n", message);

    exit(0);
}

void init() {
    variableAmounts = -1;
    functionAmounts = -1;

    root = emptyNode();
}

int main() {
    init();

    yyparse();

    traverse(root, root->detail->type, 0);

    return 0;
}