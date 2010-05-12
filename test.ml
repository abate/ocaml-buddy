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

let bdd_builder = function
  |1 ->
  Printf.eprintf "builder %!\n";
      Buddy.bdd_and
      (Buddy.bdd_pos (Buddy.bdd_newvar ()))
      (Buddy.bdd_pos (Buddy.bdd_newvar ()))
  |_ -> assert_failure "Bdd_builder : Unknown Bdd"
;;

let bdd_setup builder _ =
  (* Buddy.bdd_init (); *)
  Lazy.force builder
;;

let bdd_teardown _ = Buddy.bdd_done () ;;

let test testfun bdd =
  let setup = bdd_setup (lazy(bdd_builder bdd)) in
  let teardown = bdd_teardown in
  bracket setup testfun teardown
;;

let bdd_allsat_test = 
  let tt_real = [] in
  let tt_test = ref [] in
  let f bdd =
    let ch l =
      List.iter (fun ((var,value) as x) ->
        tt_test :=  x :: !tt_test ;
        Printf.printf "%d = %s\n" var (Buddy.string_of_value(value))
      ) l
    in
    Buddy.bdd_allsat bdd ch;
    assert_equal tt_real !tt_test
  in
  test f 1
;;

let all =
  "all tests" >::: [ 
    "bdd_allsat" >:: bdd_allsat_test;
    "bdd_satone" >:: (fun _ -> todo "");
    "bdd_satoneset" >:: (fun _ -> todo "");
    "bdd_bigand" >:: (fun _ -> todo "");
    "bdd_bigor" >:: (fun _ -> todo "");
    "bdd_makeset" >:: (fun _ -> todo "");
    "bdd_setvarorder" >:: (fun _ -> todo "");
  ]

let main () =
  Buddy.bdd_init ();
  OUnit.run_test_tt_main all
;;

main ()

