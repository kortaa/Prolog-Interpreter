{
  open Parser
}
let whitespace = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"

let digit = ['0'-'9']
let upper = ['A'-'Z']
let lower = ['a'-'z']
let letter = upper | lower
let variable = upper (letter | digit | '_')*
let atom = lower (letter | digit | '_')*

rule read = parse
  | whitespace { read lexbuf }
  | newline    { Lexing.new_line lexbuf; read lexbuf }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | '.' { DOT }
  | ',' { COMMA }
  | ":-" { RULE }
  | "assertz" {DATABASEADD}
  | variable   { VARIABLE (Lexing.lexeme lexbuf) }
  | atom       { ATOM (Lexing.lexeme lexbuf) }
  | eof { EOF }
  | _ as c { raise (Failure ("illegal character " ^ Char.escaped c)) }