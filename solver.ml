(**************************************************************************)
(*  Copyright (C) 2008 Akihiko Tozawa and Masami Hagiya.                  *)
(*  Copyright (C) 2009 2010 Pietro Abate <pietro.abate@pps.jussieu.fr     *)
(*                                                                        *)
(*  This library is free software: you can redistribute it and/or modify  *)
(*  it under the terms of the GNU Lesser General Public License as        *)
(*  published by the Free Software Foundation, either version 3 of the    *)
(*  License, or (at your option) any later version.  A special linking    *)
(*  exception to the GNU Lesser General Public License applies to this    *)
(*  library, see the COPYING file for more information.                   *)
(**************************************************************************)

open Printf

let drop str n =
  let l = String.length str in
  String.sub str n (l - n)

let take str n = String.sub str 0 n
let split str ch =
  let rec split' str l =
    try
      let i = String.index str ch in
      let t = take str i in
      let str' = drop str (i+1) in
      let l' = t::l in
      split' str' l'
    with Not_found ->
      List.rev (str::l)
  in
  split' str []

let fold_left f = function
  |h::t -> List.fold_left f h t
  |[] -> assert false

let process_file file =

  (* Mapping between variable names and indices. *)
  let vars = Hashtbl.create 0 in

  (* Processes a line containing a variable definition. *)
  let process_var line =
    let l = String.length line in
    assert (l > 2);
    assert (line.[1] = ' ');
    let name = drop line 2 in
    if not(Hashtbl.mem vars name) then begin
      Printf.eprintf "v %s\n" name;
      let v = Buddy.bdd_newvar () in
      Hashtbl.add vars name v
    end
  in

  (* Processes a line containing a clause. *)
  let process_clause line =
    let l = String.length line in
    assert (l > 2);
    assert (line.[1] = ' ');
    let lits =
        List.map
          (fun lit ->
            if lit.[0] = '-' then
              (false, drop lit 1)
            else
              (true, lit)
          )
          (split (drop line 2) ' ')
    in
    let lits =
      try
        List.map (function
          |false,name -> Buddy.bdd_neg (Hashtbl.find vars name)
          |true,name -> Buddy.bdd_pos (Hashtbl.find vars name)
        ) lits
      with Not_found -> assert false
    in
    fold_left (fun acc b -> Buddy.bdd_or acc b) lits 
  in

  (* Read a new line and processes its content. *)
  let bdd = ref (Buddy.bdd_true) in
  begin try while true do
    match input_line file with
    |"" -> ()
    |line when line.[0] = 'v' -> process_var line
    |line when line.[0] = 'c' -> bdd := Buddy.bdd_and !bdd (process_clause line)
    |line when line.[0] = '#' -> ()
    | _   -> assert false
  done with End_of_file -> () end ;
  (vars,!bdd)
;;

let solve file =
  Buddy.bdd_init ();
  (* Buddy.bdd_autoreorder (); *)
  let (vars,bdd) = process_file file in
  (* Buddy.bdd_varblockall (); *)
  (* Buddy.bdd_setvarorder [5;4;2]; *)
  Buddy.bdd_reorder ();
  let revs =
    let acc = Hashtbl.create (Hashtbl.length vars) in
    Hashtbl.iter (fun name v -> Hashtbl.add acc v name) vars ;
    acc
  in
  let f a =
    List.iter (fun (var,value) ->
      Printf.printf "%s = %s\n"
      (Hashtbl.find revs var)
      (Buddy.string_of_value(value))
    ) a
    ;
    Printf.printf "\n";
  in
  Buddy.bdd_allsat bdd f ;
  Buddy.bdd_fprintdot (open_out ("out.dot")) bdd;

  Buddy.bdd_done ()
;;

let main () =
  let argc = Array.length Sys.argv in
  if argc = 1 then
    solve stdin
  else
    Array.iter
      (fun fname ->
        try
          Printf.eprintf "Solving %s...\n" fname;
          solve (open_in fname)
        with Sys_error msg ->
          Printf.eprintf "ERROR: %s\n" msg
      )
      (Array.sub Sys.argv 1 (argc-1))
;;

main () ;;
