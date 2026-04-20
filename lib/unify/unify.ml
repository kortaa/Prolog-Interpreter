open Ast
exception Not_unifiable

type substitution = (string, term) Hashtbl.t


let init_subs () = Hashtbl.create 10

let rec occurs_check var term =
  match term with
  | Var v -> v = var
  | Sym(_ , terms) -> List.exists (occurs_check var) terms


let rec unify t1 t2 sub =
  match t1, t2 with
  | Var v1, Var v2 when v1 = v2 ->  Some sub
  | Var v, t | t, Var v -> 
    if occurs_check v t then None
    else begin
      match Hashtbl.find_opt sub v with
      | Some t' -> unify t' t sub
      | None -> 
        Hashtbl.add sub v t;
        Some sub
    end
  | Sym(s1, terms1), Sym(s2, terms2) when s1 = s2  && List.length terms1 = List.length terms2 ->
    List.fold_left2 (fun acc_sub t1 t2 -> 
        match acc_sub with
        | Some sub -> unify t1 t2 sub
        | None -> None
      ) (Some sub) terms1 terms2
  | _ -> None

let unify_helper t1 t2 =
  unify t1 t2 (init_subs ())  