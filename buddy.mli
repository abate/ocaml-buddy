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

(** documentation from http://buddy.sourceforge.net/manual/modules.html *)

type bdd
type bddpair
type var = int

type value = False | True | Unknown
type solution = SAT | UNSAT | UNKNOWN

val value_of_var : var -> value
val string_of_value : value -> string

(** reordering strategy used by [bdd_autoreorder] *)
type reorder_strategy =
  |Win2    (** Reordering using a sliding window of size 2. This algorithm swaps
               two adjacent variable blocks and if this results in more nodes then the two
               blocks are swapped back again. Otherwise the result is kept in the variable
               order. This is then repeated for all variable blocks *)
  |Win2ite (** The same as above but the process is repeated until no further
               progress is done. Usually a fast and efficient method. *)
  |Win3    (** The same as above but with a window size of 3. *)
  |Win3ite (** The same as above but with a window size of 3. *)
  |Sift    (** Reordering where each block is moved through all possible positions.
               The best of these is then used as the new position. Potentially a very slow
               but good method. *)
  |Siftite (** The same as above but the process is repeated until no further
               progress is done. Can be extremely slow. *)
  |Random  (** Mostly used for debugging purpose, but may be usefull for others.
               Selects a random position for each variable. *)

(** Initializes the bdd package. The [nodenum] parameter sets the initial number 
of BDD nodes and [cachesize] sets the size of the caches used for the BDD 
    operators (not the unique node table). 

Good initial values are :

    * Small test examples: nodenum = 1000, cachesize = 100 (default)
    * Small examples: nodenum = 10000, cachesize =1000
    * Medium sized examples: nodenum = 100000, cachesize = 10000
    * Large examples: nodenum = 1000000, cachesize = variable
*)
val bdd_init : ?nodenum : int -> ?cachesize : int -> unit -> unit

(** Resets the bdd package.  *)
val bdd_done : unit -> unit 

(** Set the number of used bdd variables. After the initialization a call must be 
    done to bdd_setvarnum to define how many variables to use in this session. 
    This number may be increased later on either by calls to setvarnum.
*)
external bdd_setvarnum : int -> unit = "wrapper_bdd_setvarnum"

(** Returns the number of defined variables. *) 
external bdd_varnum : unit -> int = "wrapper_bdd_varnum"

(** BDD operations *)

(** Return a fresh variable. Increment the number of variables available in this 
   session if needed *)
val bdd_newvar : unit -> var

(** [bdd_pos x] Returns the bdd representing the variable [x]. Alias of [ithvar] *)
val bdd_pos : var -> bdd

(** [bdd_neg x] Returns the bdd representing the negation of the variable [x].
    Alias of [nithvar] *)
val bdd_neg : var -> bdd

(** Returns the constant true bdd. *)
val bdd_true : bdd

(** Returns the constant false bdd. *)
val bdd_false : bdd

(** The logical negation of a bdd.  *)
external bdd_not : bdd -> bdd = "wrapper_bdd_not"

(** The logical 'and' of two bdds.  *)
external bdd_and : bdd -> bdd -> bdd = "wrapper_bdd_and"

(** The logical 'or' of two bdds.  *)
external bdd_or : bdd -> bdd -> bdd = "wrapper_bdd_or"

(** The logical 'xor' of two bdds.  *)
external bdd_xor : bdd -> bdd -> bdd = "wrapper_bdd_xor"

(** The logical 'implication' of two bdds.  *)
external bdd_imp : bdd -> bdd -> bdd = "wrapper_bdd_imp"

(** The logical 'bi-implication' of two bdds.  *)
external bdd_biimp : bdd -> bdd -> bdd = "wrapper_bdd_biimp"

(** If-then-else operator. Calculates the BDD for the expression 
    $(f \land g) \lor (\lnot f \land h)$ more efficiently than doing 
    the three operations separately.
*)
external bdd_ite : bdd -> bdd -> bdd -> bdd = "wrapper_bdd_ite"

val bdd_bigor : bdd list -> bdd
val bdd_bigand : bdd list -> bdd

(* external bdd_appex : bdd -> bdd -> int -> bdd -> bdd = "wrapper_bdd_appex" *)

external bdd_allsat : bdd -> ((var * value) list -> unit) -> unit = "wrapper_bdd_allsat"
external bdd_satone : bdd -> bdd = "wrapper_bdd_satone"
external bdd_simplify : bdd -> bdd -> bdd = "wrapper_bdd_restrict"

(** [bdd_var r] gets the top level variable of the [r]. *)
external bdd_var : bdd -> var = "wrapper_bdd_var"

(** [bdd_low r] gets the true branch of the top level variable of [r]. *)
external bdd_high : bdd -> bdd = "wrapper_bdd_high"

(** [bdd_low r] gets the false branch of the top lelve variable of [r]. *)
external bdd_low : bdd -> bdd = "wrapper_bdd_low"

(* [bdd_restrict r var] restricts the variables in [r] to constant true or false. How 
   this is done depends on how the variables are included in the variable set
   var. If they are included in their positive form then they are restricted to
   true and vice versa. In other words, for each variable in var, it selects
   either the true or false branch of [r] wrt the polarity. *)
external bdd_restrict : bdd -> bdd -> bdd = "wrapper_bdd_restrict"

(** Returns the variable support of a bdd. [bdd_support r] finds all the 
    variables that r depends on. That is the support of r. *)
external bdd_support : bdd -> bdd = "wrapper_bdd_support"

external bdd_nodecount : bdd -> int = "wrapper_bdd_nodecount"
external bdd_newpair : unit -> bddpair = "wrapper_bdd_newpair"
external bdd_setpair : bddpair -> int -> int -> int = "wrapper_bdd_setpair"
external bdd_replace : bdd -> bddpair -> bdd = "wrapper_bdd_replace"

(** Add a variable block for all variables. *)
external bdd_varblockall : unit -> unit = "wrapper_bdd_varblockall"

(** Add a new variable block for reordering.  *)
external bdd_addvarblock : bdd -> int -> int = "wrapper_bdd_addvarblock"

(** Add a new variable block for reordering. *)
external bdd_intaddvarblock : int -> int -> int -> int = "wrapper_bdd_intaddvarblock"

(** Start dynamic reordering.   *)
val bdd_reorder : ?strategy : reorder_strategy -> unit -> unit

(** Enable automatic reordering.  *)
val bdd_autoreorder : ?strategy : reorder_strategy -> unit -> unit

external bdd_setvarorder : int list -> unit = "wrapper_bdd_setvarorder"

(** Enables automatic reordering. *)
external bdd_enable_reorder : unit -> unit = "wrapper_bdd_enable_reorder"

(** Disable automatic reordering. *)
external bdd_disable_reorder : unit -> unit = "wrapper_bdd_disable_reorder"

(** Enables verbose information about reorderings. *)
external bdd_reorder_verbose : int -> int = "wrapper_bdd_reorder_verbose"

(** Prints the current order to stdout. *)
external bdd_printorder : unit -> unit = "wrapper_bdd_printorder"

(** Fetch the level of a specific bdd variable. *)
external bdd_level2var : int -> int = "wrapper_bdd_level2var"

(** Fetch the variable number of a specific level. *)
external bdd_var2level : int -> int = "wrapper_bdd_var2level"

external bdd_setmaxincrease : int -> int = "wrapper_bdd_setmaxincrease"
external bdd_setcacheratio : int -> int = "wrapper_bdd_setcacheratio"

external bdd_fprinttable : out_channel -> bdd -> unit = "wrapper_bdd_fprinttable"
external bdd_fprintdot : out_channel -> bdd -> unit = "wrapper_bdd_fprintdot"
external bdd_fprintset : out_channel -> bdd -> unit = "wrapper_bdd_fprintset"

(*
external bdd_load : in_channel -> bdd = "wrapper_bdd_load"
external bdd_save : in_channel -> bdd = "wrapper_bdd_save"
*)

(** create a conjunction of positive variables *)
external bdd_createset : (int -> bool) -> bdd = "wrapper_bdd_createset"

(** Utility functions *)

val bdd_relprod : (int -> bool) -> bdd -> bdd -> bdd
exception EmptyBdd

(* [bdd_setfold f d a] fold through a certain set satisfying [d] *)
val bdd_setfold : (int -> 'a -> 'a) -> bdd -> 'a -> 'a
