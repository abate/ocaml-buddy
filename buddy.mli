
(** documentation from http://buddy.sourceforge.net/manual/modules.html *)

type bdd
type bddpair

val _BDDOP_AND : int
val _BDDOP_XOR : int
val _BDDOP_OR : int
val _BDDOP_NAND : int
val _BDDOP_NOR : int
val _BDDOP_IMP : int
val _BDDOP_BIIMP : int
val _BDDOP_DIFF : int
val _BDDOP_LESS : int
val _BDDOP_INVIMP : int
val _BDD_REORDER_NONE : int
val _BDD_REORDER_WIN2 : int
val _BDD_REORDER_WIN2ITE : int
val _BDD_REORDER_SIFT : int
val _BDD_REORDER_SIFTITE : int
val _BDD_REORDER_WIN3 : int
val _BDD_REORDER_WIN3ITE : int
val _BDD_REORDER_RANDOM : int
val _BDD_REORDER_FREE : int
val _BDD_REORDER_FIXED : int

(** Initializes the bdd package. The [nodenum] parameter sets the initial number 
of BDD nodes and [cachesize] sets the size of the caches used for the BDD 
    operators (not the unique node table). 

Good initial values are :

    * Small test examples: nodenum = 1000, cachesize = 100 (default)
    * Small examples: nodenum = 10000, cachesize =1000
    * Medium sized examples: nodenum = 100000, cachesize = 10000
    * Large examples: nodenum = 1000000, cachesize = variable
*)
val init : ?nodenum : int -> ?cachesize : int -> unit -> unit

(** Resets the bdd package.  *)
val reset : unit -> unit 

(** Set the number of used bdd variables. After the initialization a call must be 
    done to bdd_setvarnum to define how many variables to use in this session. 
    This number may be increased later on either by calls to setvarnum.
*)
external setvarnum : int -> unit = "wrapper_bdd_setvarnum"

(** Returns the number of defined variables. *) 
external bdd_varnum : unit -> int = "wrapper_bdd_varnum"

(** Returns a bdd representing the i'th variable. The BDDs returned from 
    bdd_ithvar can then be used to form new BDDs by calling bdd_OP where
    OP may be bddop_and or any of the other operators
*)
external bdd_ithvar : int -> bdd = "wrapper_bdd_ithvar"

(** Returns a bdd representing the negation of the i'th variable.  *)
external bdd_nithvar : int -> bdd = "wrapper_bdd_nithvar"

(** Returns the constant true bdd. *)
external bdd_true : unit -> bdd = "wrapper_bdd_true"

(** Returns the constant false bdd. *)
external bdd_false : unit -> bdd = "wrapper_bdd_false"

external bdd_not : bdd -> bdd = "wrapper_bdd_not"
external bdd_and : bdd -> bdd -> bdd = "wrapper_bdd_and"
external bdd_or : bdd -> bdd -> bdd = "wrapper_bdd_or"
external bdd_xor : bdd -> bdd -> bdd = "wrapper_bdd_xor"
external bdd_imp : bdd -> bdd -> bdd = "wrapper_bdd_imp"

external bdd_biimp : bdd -> bdd -> bdd = "wrapper_bdd_biimp"
external bdd_ite : bdd -> bdd -> bdd -> bdd = "wrapper_bdd_ite"
external bdd_appex : bdd -> bdd -> int -> bdd -> bdd = "wrapper_bdd_appex"
external bdd_satone : bdd -> bdd = "wrapper_bdd_satone"
external bdd_restrict : bdd -> bdd -> bdd = "wrapper_bdd_restrict"
external bdd_var : bdd -> int = "wrapper_bdd_var"
external bdd_high : bdd -> bdd = "wrapper_bdd_high"
external bdd_low : bdd -> bdd = "wrapper_bdd_low"
external bdd_support : bdd -> bdd = "wrapper_bdd_support"
external bdd_nodecount : bdd -> int = "wrapper_bdd_nodecount"
external bdd_newpair : unit -> bddpair = "wrapper_bdd_newpair"
external bdd_setpair : bddpair -> int -> int -> int = "wrapper_bdd_setpair"
external bdd_replace : bdd -> bddpair -> bdd = "wrapper_bdd_replace"

(** Add a variable block for all variables. *)
external bdd_varblockall : unit -> unit = "wrapper_bdd_varblockall"

(** Adds a new variable block for reordering.  *)
external bdd_addvarblock : bdd -> int -> int = "wrapper_bdd_addvarblock"

(** Adds a new variable block for reordering. *)
external bdd_intaddvarblock : int -> int -> int -> int = "wrapper_bdd_intaddvarblock"

(** Enables automatic reordering. *)
external bdd_autoreorder : int -> int = "wrapper_bdd_autoreorder"

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

(** create a conjunction of positive variables *)
external bdd_createset : (int -> bool) -> bdd = "wrapper_bdd_createset"

(** Utility functions *)

(* return a fresh variable. Increment the number of variables available in this 
   session if needed *)
val new_var : unit -> int

val bdd_zero : bdd
val bdd_one : bdd
val bdd_pos : int -> bdd
val bdd_neg : int -> bdd

val bdd_relprod : (int -> bool) -> bdd -> bdd -> bdd
exception EmptyBdd

(* [bdd_setfold f d a] fold through a certain set satisfying [d] *)
val bdd_setfold : (int -> 'a -> 'a) -> bdd -> 'a -> 'a
