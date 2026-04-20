let rec user_input prompt action =
  match LNoise.linenoise prompt with
  | None -> ()
  | Some input -> 
    action input; 
    user_input prompt action

let rec seq_iter f xs cont () =
  match xs () with
  | Seq.Nil -> cont ()
  | Seq.Cons(x, xs) ->
    f x (fun () -> seq_iter f xs cont ())


let print_results result query =
  match query with
  | Ast.DatabaseAdd _ -> print_endline "Saved"
  | Ast.Query goals ->
  let vars = List.concat_map Ast.get_uniq_vars goals in
  seq_iter (fun subs cont ->
    if Hashtbl.length subs = 0 || vars = [] then print_endline "Yes"
    else begin
      print_newline ();
      print_string @@ Ast.subs_to_string subs;
      let input = read_line () in
      match input with
      | ";" -> cont ()
      | "." -> ()
      | _ -> print_endline "Invalid input"; cont ()
    end
    ) result (fun () -> print_endline "No") ()

let print_error error =
  print_string "\x1b[1;31m";
  print_string @@ Errors.string_of_error error;
  print_endline "\x1b[0m"

let history_filename = ".prolog_history"

let main_loop () = 
  user_input "prolog ?- " (fun input ->
  try
    LNoise.history_add input |> ignore;
    LNoise.history_save ~filename:history_filename |> ignore;
    let query = Parser_interface.parse_query_string input in
    let results = Evaluator.eval query in
    print_results results query
  with error -> print_error error)

let _ = 
  LNoise.history_load ~filename:history_filename |> ignore;
  LNoise.history_set  ~max_length:150 |> ignore;
  ["\n\x1b[38;5;87m" ^ "Welcome to The JUNGLE!" ^ "\x1b[0m\n"; 
   "assertz(X). to add X to database\n"] 
  |> List.iter print_endline;
  main_loop ()