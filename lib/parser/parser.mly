%token LPAREN
%token RPAREN
%token DOT
%token COMMA
%token RULE
%token EOF
%token DATABASEADD

%token <string> ATOM
%token <string> VARIABLE

%start <Ast.program> program
%start <Ast.query> query
%start <Ast.clause> clause


%%

program:
    | clauses EOF { $1 }
    ;

clauses:
    | clause; { [$1] }
    | clause; COMMA; clauses { $1 :: $3 }
    ;

clause:
    | head = term { (head, []) }
    | head = term; RULE; body = terms { (head, body) }
    ;

terms:
    | term; { [$1] }
    | term; COMMA; terms { $1 :: $3 }
    ;

term:
    | ATOM { Ast.Sym($1, []) }
    | VARIABLE { Ast.Var $1 }
    | ATOM; LPAREN; terms; RPAREN { Ast.Sym($1, $3) }
    ;

query:
    | terms; DOT { Ast.Query $1 }
    | DATABASEADD; LPAREN; clauses; RPAREN; DOT { Ast.DatabaseAdd $3 }
    ;