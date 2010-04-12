#include <stdio.h>
#include <string.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/custom.h>

#include <bdd.h>

/* global variables (initialized by wrapper_bdd_init) */

struct custom_operations bddops; /* custom GC-enabled type */
struct custom_operations bddpairops; /* custom GC-enabled type */

/* number of bdd node allocation needed to trigger ocaml GC */

int wrapper_ocamlgc_max = 20000;

/* type bdd: linking buddy reference counters with Ocaml GC */

void wrapper_makebdd(value* vptr, BDD x)
{
  int used = bdd_nodecount(x);
  bdd_addref(x);
  *vptr = alloc_custom(&bddops, sizeof (BDD), used, wrapper_ocamlgc_max);
  *((BDD*)Data_custom_val(*vptr)) = x;
}

void wrapper_deletebdd(value v)
{
  BDD x = *((BDD*)Data_custom_val(v));
  bdd_delref(x);
}

int wrapper_comparebdd(value v1, value v2)
{
  BDD x,y;
  CAMLparam2(v1, v2);
  x = *((BDD*)Data_custom_val(v1));
  y = *((BDD*)Data_custom_val(v2));
  CAMLreturn(x < y ? -1  : x == y ? 0 : 1);
}

long wrapper_hashbdd(value v)
{
  CAMLparam1(v);
  BDD x = *((BDD*)Data_custom_val(v));
  CAMLreturn((long)x);
}

/* type bddpair: the use of custom_val here is not so important */

void wrapper_deletebddpair(value v)
{
  bddPair* x = *((bddPair**)Data_custom_val(v));
  bdd_freepair(x);
}

/* wrappers */

CAMLprim void wrapper_bdd_init(value v1, value v2)
{
  int nodesize = Int_val(v1);
  int cachesize = Int_val(v2);
  bdd_init(nodesize, cachesize);

  bddops.identifier = NULL;
  bddops.finalize = wrapper_deletebdd;
  bddops.compare = wrapper_comparebdd;
  bddops.hash = wrapper_hashbdd;
  bddops.serialize = NULL;
  bddops.deserialize = NULL;

  bddpairops.identifier = NULL;
  bddpairops.finalize = wrapper_deletebddpair;
  bddpairops.compare = NULL;
  bddpairops.hash = NULL;
  bddpairops.serialize = NULL;
  bddpairops.deserialize = NULL;
}

CAMLprim void wrapper_bdd_done() 
{
  bdd_done();
}

CAMLprim void wrapper_bdd_setvarnum(value v) 
{
  int num = Int_val(v);
  bdd_setvarnum(num);
}

CAMLprim value wrapper_bdd_varnum() 
{
  int num = bdd_varnum();
  return Val_int(num);
}

CAMLprim value wrapper_bdd_newpair()
{
  bddPair* shifter;
  CAMLparam0(); 
  CAMLlocal1(r);
  r = alloc_custom(&bddpairops, sizeof (bddPair*), 1, 1);
  shifter = bdd_newpair();
  *((bddPair**)Data_custom_val(r)) = shifter;
  CAMLreturn(r);
}

/* 
 * creating a set representing bdd
 * (this is here to demonstrate callback)
 */

CAMLprim value wrapper_bdd_createset(value q)
{
  int l,v;
  BDD d,e;
  CAMLparam1(q); 
  d = bdd_true ();
  for (l = bdd_varnum() - 1; l >= 0; l--) 
    {
      v = bdd_level2var(l);
      if (Bool_val(callback(q, Val_int(v)))) 
        {
          e = bdd_and(bdd_ithvar(v), d); /* bdd_ithvar is always reference-counted */
          bdd_delref(d);
          bdd_addref(e);
          d = e;
        }
    }
  CAMLlocal1(r);
  wrapper_makebdd(&r, d);
  CAMLreturn(r);
}

/* macro definitions */

#define FUN_ARG_bdd(x, v) \
  BDD x = *((BDD*)Data_custom_val(v));

#define FUN_ARG_bddpair(x, v) \
  bddPair* x = *((bddPair**)Data_custom_val(v));

#define FUN_ARG_int(x, v) \
  int x = Int_val(v);

#define FUN_RET_int(eval) \
  CAMLreturn(Val_int(eval));

#define FUN_RET_unit(eval) \
  eval; \
  CAMLreturn0;

#define FUN_RET_bdd(eval) \
  CAMLlocal1(r); /* &r is GC-root */ \
  wrapper_makebdd(&r, eval); \
  CAMLreturn(r);

#define FUN0(name, ret_type) \
CAMLprim value wrapper_##name() \
{  \
  CAMLparam0(); \
  FUN_RET_##ret_type(name()); \
}

/* same as above but returns void to avoid a compiler warning */
#define FUN00(name, ret_type) \
void wrapper_##name() \
{  \
  CAMLparam0(); \
  FUN_RET_##ret_type(name()); \
}

#define FUN1(name, arg0_type, ret_type) \
CAMLprim value wrapper_##name(value v0) \
{  \
  CAMLparam1(v0); \
  FUN_ARG_##arg0_type(x, v0); \
  FUN_RET_##ret_type(name(x)); \
}

#define FUN2(name, arg0_type, arg1_type, ret_type)  \
CAMLprim value wrapper_##name(value v0, value v1) \
{ \
  CAMLparam2(v0, v1);  \
  FUN_ARG_##arg0_type(x, v0); \
  FUN_ARG_##arg1_type(y, v1); \
  FUN_RET_##ret_type(name(x, y)); \
}

#define FUN3(name, arg0_type, arg1_type, arg2_type, ret_type) \
CAMLprim value wrapper_##name(value v0, value v1, value v2) \
{ \
  CAMLparam3(v0, v1, v2); \
  FUN_ARG_##arg0_type(x, v0); \
  FUN_ARG_##arg1_type(y, v1); \
  FUN_ARG_##arg2_type(z, v2); \
  FUN_RET_##ret_type(name(x, y, z)); \
}

#define FUN4(name, arg0_type, arg1_type, arg2_type, arg3_type, ret_type) \
  CAMLprim value wrapper_##name(value v0, value v1, value v2, value v3) \
{ \
  CAMLparam4(v0, v1, v2, v3); \
  FUN_ARG_##arg0_type(x, v0); \
  FUN_ARG_##arg1_type(y, v1); \
  FUN_ARG_##arg2_type(z, v2); \
  FUN_ARG_##arg3_type(w, v3); \
  FUN_RET_##ret_type(name(x, y, z, w)); \
}



/* wrapped primitives */

FUN0(bdd_true, bdd)
FUN0(bdd_false, bdd)
FUN1(bdd_ithvar, int, bdd)
FUN1(bdd_nithvar, int, bdd)
FUN1(bdd_not, bdd, bdd)
FUN2(bdd_and, bdd, bdd, bdd)
FUN2(bdd_or, bdd, bdd, bdd)
FUN2(bdd_xor, bdd, bdd, bdd)
FUN2(bdd_imp, bdd, bdd, bdd)
FUN2(bdd_biimp, bdd, bdd, bdd)
FUN3(bdd_ite, bdd, bdd, bdd, bdd)
FUN4(bdd_appex, bdd, bdd, int, bdd, bdd)
FUN1(bdd_satone, bdd, bdd)
FUN2(bdd_restrict, bdd, bdd, bdd)
FUN1(bdd_var, bdd, int)
FUN1(bdd_high, bdd, bdd)
FUN1(bdd_low, bdd, bdd)
FUN1(bdd_support, bdd, bdd)
FUN1(bdd_nodecount, bdd, int)
FUN3(bdd_setpair, bddpair, int, int, int)
FUN2(bdd_replace, bdd, bddpair, bdd)

FUN2(bdd_addvarblock, bdd, int, int)
FUN3(bdd_intaddvarblock, int, int, int, int)
FUN00(bdd_varblockall, unit)
FUN1(bdd_autoreorder, int, int)
FUN00(bdd_enable_reorder, unit)
FUN00(bdd_disable_reorder, unit)
FUN1(bdd_reorder_verbose, int, int)
FUN00(bdd_printorder, unit)
FUN1(bdd_level2var, int, int)
FUN1(bdd_var2level, int, int)

FUN1(bdd_setcacheratio, int, int)
FUN1(bdd_setmaxincrease, int, int)

