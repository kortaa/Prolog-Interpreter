type fname = string

let run_parser parse (lexbuf : Lexing.lexbuf) =
  try parse Lexer.read lexbuf with
  | Parsing.Parse_error ->
    raise (Errors.Parse_error(Lexing.lexeme_start_p lexbuf,
    UnexpectedToken (Lexing.lexeme lexbuf)))

let parse_file fname =
  match open_in fname with
  | chan ->
    begin match
      let lexbuf = Lexing.from_channel chan in
      lexbuf.lex_curr_p <-
        { lexbuf.lex_curr_p with
          pos_fname = fname
        };
      run_parser Parser.program lexbuf
    with
    | result ->
      close_in chan;
      result
    | exception exn ->
      close_in_noerr chan;
      raise exn
    end
  | exception Sys_error message ->
    raise (Errors.Cannot_open_file { fname; msg = message })

let parse_query chan =
  let lexbuf = Lexing.from_channel chan in
  run_parser Parser.query lexbuf

let parse_query_string str =
  let lexbuf = Lexing.from_string str in
  run_parser Parser.query lexbuf