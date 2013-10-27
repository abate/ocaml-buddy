(**************************************************************************)
(*  Copyright (C) 2009-12   Pietro Abate <pietro.abate@pps.jussieu.fr     *)
(*                                                                        *)
(*  This library is free software: you can redistribute it and/or modify  *)
(*  it under the terms of the GNU Lesser General Public License as        *)
(*  published by the Free Software Foundation, either version 3 of the    *)
(*  License, or (at your option) any later version.  A special linking    *)
(*  exception to the GNU Lesser General Public License applies to this    *)
(*  library, see the COPYING file for more information.                   *)
(**************************************************************************)

open Ocamlbuild_plugin

let _ = dispatch begin function
   | After_rules ->
       (* ocaml compile flags *)
       flag ["ocaml"; "compile"] & S[A"-ccopt"; A"-O9"];

       (* C compile flags *)
       flag ["c"; "compile"] & S[A"-cc"; A"gcc"; A"-ccopt"; A"-fPIC"];

       flag ["c"; "ocamlmklib"] & S[A"-lbdd";];

       dep ["link"; "ocaml"; "use_bdd"] ["libbuddy_stubs.a"];

       (* this is used to link cmxs files *)
       flag ["link"; "ocaml"; "link_bdd"] (A"libbuddy_stubs.a");

       (*
       flag ["ocaml"; "use_bdd"; "link"; "library"; "byte"] & S[A"-ccopt"; A"-L."];
       *)
       flag ["ocaml"; "use_bdd"; "link"; "library"; "byte"] & S[A"-dllib"; A"-lbuddy_stubs" ];

       flag ["ocaml"; "use_bdd"; "link"; "library"; "native"] & S[A"-cclib"; A"-lbuddy_stubs"; ];
       flag ["ocaml"; "use_bdd"; "link"; "library"; "native"] & S[A"-cclib"; A"-lbdd";];

       flag ["ocaml"; "use_bdd"; "link"; "program"; "native"] & S[A"-ccopt"; A"-L."; A"buddy.cmxa"];
       flag ["ocaml"; "use_bdd"; "link"; "program"; "byte"] & S[A"-ccopt"; A"-L."; A"buddy.cma"];

       flag ["ocaml"; "pkg_threads"; "compile"] (S[A "-thread"]);
       flag ["ocaml"; "pkg_threads"; "link"] (S[A "-thread"]);
   | _ -> ()
end
