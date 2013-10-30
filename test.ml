(**************************************************************************************)
(*  Copyright (C) 2009 Pietro Abate <pietro.abate@pps.jussieu.fr>                     *)
(*                                                                                    *)
(*  This library is free software: you can redistribute it and/or modify              *)
(*  it under the terms of the GNU Lesser General Public License as                    *)
(*  published by the Free Software Foundation, either version 3 of the                *)
(*  License, or (at your option) any later version.  A special linking                *)
(*  exception to the GNU Lesser General Public License applies to this                *)
(*  library, see the COPYING file for more information.                               *)
(**************************************************************************************)

open OUnit

let reverse = Hashtbl.create 17 ;;

let add_vars =
  List.iter (fun v ->
    let i = Buddy.bdd_newvar () in
    Hashtbl.add reverse v i
  )
;;

let builder (vars,clauses) =
  add_vars vars;
  let bl = 
    List.map (fun l ->
      List.map (function
        |(v,true) -> Buddy.bdd_pos (Hashtbl.find reverse v)
        |(v,false) -> Buddy.bdd_neg (Hashtbl.find reverse v)
      ) l 
    ) clauses
  in
  Buddy.bdd_bigand (List.map Buddy.bdd_bigor bl)
;;

module S = Set.Make(
  struct
    type t = (Buddy.var * Buddy.value)
    let compare = compare
  end
)

let bdd_allsat_test () = 
  Buddy.bdd_init ();
  Hashtbl.clear reverse ;
  let bdd = builder (["a";"b"],[[("a",true)];[("b",true)]]) in
  let tt_test = ref [] in
  let f bdd =
    let ch l =
      tt_test :=  (List.sort compare l) :: !tt_test ;
(*      List.iter (fun (var,value) ->
        Printf.printf "%d = %s\n" var (Buddy.string_of_value(value))
      ) l;
      Printf.printf "\n";
      *)
    in
    (* Buddy.bdd_fprintset stdout bdd; *)
    Buddy.bdd_allsat ch bdd;
    assert_equal true true
  in
  f bdd;
  Buddy.bdd_done ()
;;

let bdd_satoneset_test () =
  Buddy.bdd_init ();
  Hashtbl.clear reverse ;
  let bdd = builder (["a";"b"],[[("a",true)];[("b",true)]]) in
  let f bdd =
    let b = Buddy.bdd_satoneset bdd [Hashtbl.find reverse "b"] in
    (* Buddy.bdd_fprintdot stdout b; *)
    assert_equal true true
  in
  f bdd ;
  Buddy.bdd_done ()
;;

let bdd_satone_test () =
  Buddy.bdd_init ();
  Hashtbl.clear reverse ;
  let bdd = builder (["a";"b"],[[("a",true)];[("b",true)]]) in
  Buddy.bdd_fprintdot stdout (Buddy.bdd_restrict bdd (Buddy.bdd_pos (Hashtbl.find reverse "b")));
  Buddy.bdd_fprintdot stdout (Buddy.bdd_low bdd);
  Buddy.bdd_fprintdot stdout (Buddy.bdd_high bdd);
  let f bdd =
    let b = Buddy.bdd_satone bdd in
    (* Buddy.bdd_fprintdot stdout b; *)
    assert_equal true true
  in
  f bdd ;
  Buddy.bdd_done ()
;;

let bdd_bigand_test () =
  Buddy.bdd_init ();
  Hashtbl.clear reverse ;
  let vars = ["a";"b"] in
  add_vars vars;
  let v = List.map (fun v -> Buddy.bdd_pos (Hashtbl.find reverse v)) vars in
  let bdd = Buddy.bdd_bigand v in
  assert_equal true true;
  Buddy.bdd_done ()
;;

let bdd_bigor_test () =
  Buddy.bdd_init ();
  Hashtbl.clear reverse ;
  let vars = ["a";"b"] in
  add_vars vars;
  let v = List.map (fun v -> Buddy.bdd_pos (Hashtbl.find reverse v)) vars in
  let bdd = Buddy.bdd_bigor v in
  assert_equal true true;
  Buddy.bdd_done ()
;;

let bdd_setvarorder_test () =
  Buddy.bdd_init ();
  Hashtbl.clear reverse ;
  let vars = ["a";"b"] in
  let bdd = builder (["a";"b"],[[("a",true)];[("b",true)]]) in
  (* add_vars vars; *)
  let v = List.map (Hashtbl.find reverse) vars in
(*  print_endline "-----------1";
  Buddy.bdd_fprintorder stdout ;
  Buddy.bdd_fprintdot stdout bdd;
  print_endline "-----------2";
  ignore(Buddy.bdd_satone bdd);
  Buddy.bdd_setvarorder (List.rev v);
  print_endline "-----------3";
  Buddy.bdd_fprintorder stdout ;
  Buddy.bdd_fprintdot stdout bdd;
  print_endline "-----------4";
*)
  assert_equal true true;
  Buddy.bdd_done ()
;;

let string_of_intlist xs = String.concat "," (List.map string_of_int xs)
let string_of_tpllist xs =
  let pp tuple = "(" ^ string_of_intlist tuple ^ ")" in
  String.concat "," (List.map pp xs)
let fdd_allsat_list bdd vars =
  let tpl_list = ref [] in
  let add_tpl tpl = tpl_list := tpl::(!tpl_list) in
  Buddy.fdd_allsat add_tpl bdd vars;
  List.sort compare (!tpl_list)

let fdd_domain () =
  Buddy.bdd_init ();
  let d = Buddy.fdd_extdomain 11 in
  assert_equal ~printer:string_of_int 1 (Buddy.fdd_domainnum ());
  assert_equal ~printer:string_of_int 4 (Buddy.fdd_varnum d);
  assert_equal ~printer:string_of_int 11 (Buddy.fdd_domainsize d);
  let domain_list = ref [] in
  let add_elt = function
    | [x] -> domain_list := x::(!domain_list)
    | _ -> assert false
  in
  Buddy.fdd_allsat add_elt (Buddy.fdd_domain d) [d];
  assert_equal
    ~printer:string_of_intlist
    [0;1;2;3;4;5;6;7;8;9;10]
    (List.sort compare (!domain_list));
  Buddy.bdd_done ()

let fdd_equals () =
  Buddy.bdd_init ();
  let d = Buddy.fdd_extdomain 3 in
  let e = Buddy.fdd_extdomain 3 in
  assert_equal ~printer:string_of_int 2 (Buddy.fdd_domainnum ());
  assert_equal ~printer:string_of_int 2 (Buddy.fdd_varnum d);
  assert_equal ~printer:string_of_int 3 (Buddy.fdd_domainsize d);
  let equals_bdd = Buddy.fdd_equals d e in
  let domain_bdd = Buddy.fdd_domain d in
  assert_equal
    ~printer:string_of_tpllist
    [[0;0];[1;1];[2;2];[3;3]]
    (fdd_allsat_list equals_bdd [d; e]);
  assert_equal
    ~printer:string_of_tpllist
    [[0;0];[1;1];[2;2]]
    (fdd_allsat_list (Buddy.bdd_and domain_bdd equals_bdd) [d; e]);
  Buddy.bdd_done ()

let fdd_replace () =
  Buddy.bdd_init ();
  let d = Buddy.fdd_extdomain 2 in
  let e = Buddy.fdd_extdomain 2 in
  let d_restrict = Buddy.fdd_ithvar d 1 in
  let replace = Buddy.fdd_replace d_restrict d e in
  assert_equal
    ~printer:string_of_tpllist
    [[1;0];[1;1]]
    (fdd_allsat_list d_restrict [d; e]);
  assert_equal
    ~printer:string_of_tpllist
    [[0;1];[1;1]]
    (fdd_allsat_list replace [d; e]);
  Buddy.bdd_done ()

let fdd_allsat () =
  Buddy.bdd_init ();
  let d = Buddy.fdd_extdomain 5 in
  let e = Buddy.fdd_extdomain 5 in
  let f = Buddy.fdd_extdomain 5 in
  let d_restrict = Buddy.fdd_ithvar d 1 in
  let e_restrict = Buddy.fdd_ithvar e 2 in
  let f_restrict =
    Buddy.bdd_or (Buddy.fdd_ithvar f 3) (Buddy.fdd_ithvar f 0)
  in
  let bdd = Buddy.bdd_bigand [d_restrict; e_restrict; f_restrict] in
  assert_equal
    ~printer:string_of_tpllist
    [[1;2;0];[1;2;3]]
    (fdd_allsat_list bdd [d; e; f]);
  assert_equal
    ~printer:string_of_tpllist
    [[0;2];[3;2]]
    (fdd_allsat_list bdd [f; e]);
  Buddy.bdd_done ()


let all =
  "all tests" >::: [ 
    "bdd_bigand" >:: bdd_satone_test;
    "bdd_bigor" >:: bdd_bigor_test;
    "bdd_makeset" >:: (fun _ -> todo "");

    "bdd_satone" >:: bdd_satone_test;
    "bdd_satoneset" >:: bdd_satoneset_test;
    "bdd_allsat" >:: bdd_allsat_test;

    "bdd_setvarorder" >:: bdd_setvarorder_test;

    "fdd_domain" >:: fdd_domain;
    "fdd_equals" >:: fdd_equals;
    "fdd_replace" >:: fdd_replace;
    "fdd_allsat" >:: fdd_allsat;
  ]

let main () =
  OUnit.run_test_tt_main all
;;

main ()

