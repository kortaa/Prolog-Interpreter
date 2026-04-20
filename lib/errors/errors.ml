type reason =
| EofInComment
| InvalidNumber   of string
| InvalidChar     of char
| UnexpectedToken of string

exception Parse_error      of (Lexing.position * reason)
exception Runtime_error    of string

exception Cannot_open_file of
  { fname   : string
  ; msg     : string
  }

let string_of_reason reason =
  match reason with
  | EofInComment ->
    "End of file in comment"
  | InvalidNumber s ->
    Printf.sprintf "Invalid number: %s" s
  | InvalidChar c ->
    Printf.sprintf "Invalid character: %c" c
  | UnexpectedToken s ->
    Printf.sprintf "Unexpected token: %s" s

let string_of_error error =
  match error with
  | Parse_error (_, reason) ->
    string_of_reason reason
  | Runtime_error s ->
    Printf.sprintf "Runtime error: %s" s
  | Cannot_open_file { fname; msg } ->
    Printf.sprintf "Cannot open file %s: %s" fname msg
  | _ -> "Unknown error"