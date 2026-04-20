open Ast  

let init () : ((string * int), clause list) Hashtbl.t = Hashtbl.create 100

let database_to_string (db : ((string * int), clause list) Hashtbl.t) : string =
  let buf = Buffer.create 100 in
  Hashtbl.iter (fun (key, value) clauses ->
    Buffer.add_string buf (Printf.sprintf "(%s, %d) => [\n" key value);
    List.iter (fun clause ->
      Buffer.add_string buf (Printf.sprintf "  %s\n" (Ast.clause_to_string clause))
    ) clauses;
    Buffer.add_string buf "]\n"
  ) db;
  Buffer.contents buf
  

let add c db =
  match (fst c) with
  | Sym(s, terms) ->
    let arity = List.length terms in
    let key = (s, arity) in
    begin
      match Hashtbl.find_opt db key with
      | None -> Hashtbl.add db key [c]
      | Some exis_c -> Hashtbl.replace db key (exis_c @ [c])
    end
  | _ -> failwith "Invalid clause format(should be Sym)"

let get t db =
  match t with
  | Sym(s, terms) ->
    let arity = List.length terms in
    let key = (s, arity) in
    begin
      match Hashtbl.find_opt db key with
      | None -> []
      | Some exis_c -> exis_c
    end
  | _ -> failwith "Invalid term format"