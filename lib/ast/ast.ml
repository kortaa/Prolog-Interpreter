type symbol = string

and term =
  | Var of symbol
  | Sym of symbol * term list


let rec term_to_string term =
  match term with
  | Var variable -> variable
  | Sym (symbol, []) -> symbol
  | Sym (symbol, terms) ->
    let terms_string = List.map term_to_string terms |> String.concat ", " in
    Printf.sprintf "%s(%s)" symbol terms_string


let clause_to_string clause =
  match clause with
  | (head, []) -> term_to_string head
  | (head, body) ->
    let head_str = term_to_string head in
    match body with
    | [] -> head_str
    | _ ->
      let body_str = List.map term_to_string body |> String.concat ", " in
      Printf.sprintf "%s :- %s" head_str body_str

let subs_to_string subs =
  let buffer = Buffer.create 100 in
  Hashtbl.iter (fun v t ->
    let entry = Printf.sprintf "%s = %s, " v (term_to_string t) in
    Buffer.add_string buffer entry
  ) subs;
  let subs_string = Buffer.contents buffer in
  let subs_string_length = String.length subs_string in
  if subs_string_length >= 2 then
    String.sub subs_string 0 (subs_string_length - 2)  
  else
    subs_string  
      
    

let rec get_uniq_vars term =
  match term with
  | Var variable -> [variable]
  | Sym (_, terms) ->
    List.map get_uniq_vars terms
    |> List.flatten
    |> List.sort_uniq String.compare

let get_sub subs variable =
  match Hashtbl.find_opt subs variable with
  | Some term -> Some term
  | None -> None


let return variable = Var variable

let rec bind term f =
  match term with
  | Var variable -> f variable
  | Sym (symbol, terms) -> Sym (symbol, List.map (fun t -> bind t f) terms)

type clause = term * term list

type program = clause list
type query   = 
  | Query of term list
  | DatabaseAdd of program