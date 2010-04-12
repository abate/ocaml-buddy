type bdd
type bddpair

(* from bdd.h *)

let _BDDOP_AND = 0
let _BDDOP_XOR = 1
let _BDDOP_OR =  2
let _BDDOP_NAND = 3
let _BDDOP_NOR = 4
let _BDDOP_IMP = 5
let _BDDOP_BIIMP = 6
let _BDDOP_DIFF = 7
let _BDDOP_LESS = 8
let _BDDOP_INVIMP = 9

let _BDD_REORDER_NONE = 0
let _BDD_REORDER_WIN2  =  1
let _BDD_REORDER_WIN2ITE = 2
let _BDD_REORDER_SIFT = 3
let _BDD_REORDER_SIFTITE = 4
let _BDD_REORDER_WIN3 = 5
let _BDD_REORDER_WIN3ITE = 6
let _BDD_REORDER_RANDOM = 7

let _BDD_REORDER_FREE = 0
let _BDD_REORDER_FIXED = 1

(* external functions *)

external bdd_init : int -> int -> unit = "wrapper_bdd_init"
external bdd_done : unit -> unit = "wrapper_bdd_done"

external setvarnum : int -> unit = "wrapper_bdd_setvarnum"

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
external bdd_intaddvarblock : int -> int -> int -> int = "wrapper_bdd_intaddvarblock"
external bdd_autoreorder : int -> int = "wrapper_bdd_autoreorder"
external bdd_enable_reorder : unit -> unit = "wrapper_bdd_enable_reorder"
external bdd_disable_reorder : unit -> unit = "wrapper_bdd_disable_reorder"
external bdd_reorder_verbose : int -> int = "wrapper_bdd_reorder_verbose"
external bdd_printorder : unit -> unit = "wrapper_bdd_printorder"
external bdd_level2var : int -> int = "wrapper_bdd_level2var"
external bdd_var2level : int -> int = "wrapper_bdd_var2level"

external bdd_setmaxincrease : int -> int = "wrapper_bdd_setmaxincrease"
external bdd_setcacheratio : int -> int = "wrapper_bdd_setcacheratio"

(* create a conjunction of positive variables *)

external bdd_createset : (int -> bool) -> bdd = "wrapper_bdd_createset"

(* utility functions *)

let varcount = ref 0
let new_var () = 
  incr varcount;
  if bdd_varnum() <= !varcount then (setvarnum (!varcount + 1); !varcount) else !varcount
;;

let init ?(nodenum=1000) ?(cachesize=100) () = bdd_init nodenum cachesize ;;
let reset () = bdd_done () ;;

let bdd_zero = bdd_false ()
let bdd_one = bdd_true ()

let bdd_pos x = bdd_ithvar (if bdd_varnum() <= x then (setvarnum (x + 1); x) else x)
let bdd_neg x = bdd_nithvar (if bdd_varnum() <= x then (setvarnum (x + 1); x) else x)
let bdd_relprod q =
  let qbdd = ref bdd_one and n = ref 0 in 
  fun a b -> 
    if !n != bdd_varnum () then qbdd := bdd_createset q else ();
    bdd_appex a b _BDDOP_AND !qbdd

exception EmptyBdd

(* iterate through a certain set satisfying d *)

let rec bdd_setfold f d t = 
  if d = bdd_zero then raise EmptyBdd
  else if d = bdd_one then t 
  else 
    let e = bdd_low d in 
    if e <> bdd_zero then bdd_setfold f e t 
    else bdd_setfold f (bdd_high d) (f (bdd_var d) t)


