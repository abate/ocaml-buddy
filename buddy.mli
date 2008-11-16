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
external bdd_init : int -> int -> unit = "wrapper_bdd_init"
external bdd_done : unit -> unit = "wrapper_bdd_done"
external bdd_setvarnum : int -> unit = "wrapper_bdd_setvarnum"
external bdd_varnum : unit -> int = "wrapper_bdd_varnum"
external bdd_ithvar : int -> bdd = "wrapper_bdd_ithvar"
external bdd_nithvar : int -> bdd = "wrapper_bdd_nithvar"
external bdd_true : unit -> bdd = "wrapper_bdd_true"
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
external bdd_varblockall : unit -> unit = "wrapper_bdd_varblockall"
external bdd_addvarblock : bdd -> int -> int = "wrapper_bdd_addvarblock"
external bdd_intaddvarblock : int -> int -> int -> int
  = "wrapper_bdd_intaddvarblock"
external bdd_autoreorder : int -> int = "wrapper_bdd_autoreorder"
external bdd_enable_reorder : unit -> unit = "wrapper_bdd_enable_reorder"
external bdd_disable_reorder : unit -> unit = "wrapper_bdd_disable_reorder"
external bdd_reorder_verbose : int -> int = "wrapper_bdd_reorder_verbose"
external bdd_printorder : unit -> unit = "wrapper_bdd_printorder"
external bdd_level2var : int -> int = "wrapper_bdd_level2var"
external bdd_var2level : int -> int = "wrapper_bdd_var2level"
external bdd_setmaxincrease : int -> int = "wrapper_bdd_setmaxincrease"
external bdd_setcacheratio : int -> int = "wrapper_bdd_setcacheratio"
external bdd_createset : (int -> bool) -> bdd = "wrapper_bdd_createset"
val bdd_zero : bdd
val bdd_one : bdd
val bdd_pos : int -> bdd
val bdd_neg : int -> bdd
val bdd_relprod : (int -> bool) -> bdd -> bdd -> bdd
exception EmptyBdd
val bdd_setfold : (int -> 'a -> 'a) -> bdd -> 'a -> 'a
