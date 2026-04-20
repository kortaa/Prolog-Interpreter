open Unify

let db = Database.init ()

type variable_refresh_map = (string, string) Hashtbl.t

let fresh_variable =
  let counter = ref 0 in
  fun () ->
    incr counter;
    "var" ^ string_of_int !counter

let refresh_variables var_map term =
  let refresh term =
    Ast.bind term (fun v ->
      match Hashtbl.find_opt var_map v with
      | Some new_v -> Ast.return new_v
      | None ->
        let new_v = fresh_variable () in
        Hashtbl.add var_map v new_v;
        Ast.return new_v
    )
  in
  refresh term

let refresh_clause clause =
  let var_map = Hashtbl.create 10 in
  let head = refresh_variables var_map (fst clause)  in
  let body = List.map (refresh_variables var_map) (snd clause) in
  (head, body)


let rec apply subs term =
  Ast.bind term (fun v ->
    match Ast.get_sub subs v with
    | Some t -> apply subs t
    | None -> Ast.return v
  )

let apply_to_terms subs terms =
  List.map (apply subs) terms

  let solve_goal goal = 
    let candidates = Database.get goal db in
    let rec try_candidates candidates =
      match candidates with
      | [] -> Bt.fail
      | candidate :: rest ->
        let (head, body) = refresh_clause candidate in
        Bt.bind (Bt.return(unify_helper head goal)) (function
          | None -> try_candidates rest
          | Some subs ->
            let new_goals = apply_to_terms subs body in  
            Seq.cons (subs, new_goals) (try_candidates rest)
        )
    in
    try_candidates candidates



let rec solve goals current_subst =
  match goals with
  | [] -> Bt.return current_subst 
  | goal :: rest_goals ->
    Bt.bind (solve_goal goal) (fun (new_subst, new_goals) ->
      let combined_goals = new_goals @ apply_to_terms new_subst rest_goals in
      solve combined_goals new_subst
    )

let eval query =
  match query with
  | Ast.DatabaseAdd clauses -> 
    List.iter (fun clause -> Database.add clause db) clauses; 

    Bt.return (init_subs ())
  | Ast.Query goals ->

  let initial_subst = init_subs () in
  solve goals initial_subst
