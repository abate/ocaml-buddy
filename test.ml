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
let builder (vars,clauses) =
  List.iter (fun v ->
    let i = Buddy.bdd_newvar () in
    Hashtbl.add reverse v i
  ) vars ;
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
      List.iter (fun (var,value) ->
        Printf.printf "%d = %s\n" var (Buddy.string_of_value(value))
      ) l;
      Printf.printf "\n";
    in
    Buddy.bdd_fprintset stdout bdd;
    Buddy.bdd_allsat bdd ch;
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
    Buddy.bdd_fprintdot stdout b;
    assert_equal true true
  in
  f bdd ;
  Buddy.bdd_done ()
;;

let all =
  "all tests" >::: [ 
    "bdd_allsat" >:: bdd_allsat_test;
    "bdd_allsat" >:: bdd_allsat_test; 
    "bdd_satoneset" >:: bdd_satoneset_test;
    "bdd_satone" >:: (fun _ -> todo "");
    "bdd_bigand" >:: (fun _ -> todo "");
    "bdd_bigor" >:: (fun _ -> todo "");
    "bdd_makeset" >:: (fun _ -> todo "");
    "bdd_setvarorder" >:: (fun _ -> todo "");
  ]

let main () =
  OUnit.run_test_tt_main all
;;

main ()

