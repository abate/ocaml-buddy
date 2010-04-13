/**************************************************************************/
/*  Copyright (C) 2008 Akihiko Tozawa and Masami Hagiya.                  */
/*  Copyright (C) 2009 2010 Pietro Abate <pietro.abate@pps.jussieu.fr     */
/*                                                                        */
/*  This library is free software: you can redistribute it and/or modify  */
/*  it under the terms of the GNU Lesser General Public License as        */
/*  published by the Free Software Foundation, either version 3 of the    */
/*  License, or (at your option) any later version.  A special linking    */
/*  exception to the GNU Lesser General Public License applies to this    */
/*  library, see the COPYING file for more information.                   */
/**************************************************************************/

#include <stdio.h>
#include <string.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/custom.h>

#include <bdd.h>

/* Snippet taken from byterun/io.h of OCaml 3.11 */

#ifndef IO_BUFFER_SIZE
#define IO_BUFFER_SIZE 4096
#endif

#include <sys/types.h>
#include <unistd.h>
typedef off_t file_offset;

struct channel {
  int fd;                       /* Unix file descriptor */
  file_offset offset;           /* Absolute position of fd in the file */
  char * end;                   /* Physical end of the buffer */
  char * curr;                  /* Current position in the buffer */
  char * max;                   /* Logical end of the buffer (for input) */
  void * mutex;                 /* Placeholder for mutex (for systhreads) */
  struct channel * next, * prev;/* Double chaining of channels (flush_all) */
  int revealed;                 /* For Cash only */
  int old_revealed;             /* For Cash only */
  int refcount;                 /* For flush_all and for Cash */
  int flags;                    /* Bitfield */
  char buff[IO_BUFFER_SIZE];    /* The buffer itself */
};

#define Channel(v) (*((struct channel **) (Data_custom_val(v))))

static inline value tuple( value a, value b) {
  CAMLparam2( a, b );
  CAMLlocal1( tuple );

  tuple = caml_alloc(2, 0);

  Store_field( tuple, 0, a );
  Store_field( tuple, 1, b );

  CAMLreturn(tuple);
}

static inline value append( value hd, value tl ) {
  CAMLparam2( hd , tl );
  CAMLreturn(tuple( hd, tl ));
}

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

/* converts a Caml channel to a C FILE* stream */
static FILE * stream_of_channel(value chan, const char * mode)
{
  int des ;
  FILE * res ;
  struct channel *c_chan = Channel(chan) ;
  if(c_chan==NULL)
    return NULL;
  des = dup(c_chan->fd) ;
  res = fdopen(des, mode) ;
  return res ;
}

/* wrappers */

CAMLprim value wrapper_bdd_init(value nodesize, value cachesize) {
  CAMLparam2 (nodesize, cachesize);
  bdd_init(Int_val(nodesize), Int_val(cachesize));

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

  /* not gc messages on stdout */
  bdd_gbc_hook(NULL);
  
  CAMLreturn(Val_unit);
}

CAMLprim value wrapper_bdd_done() {
  CAMLparam0();
  bdd_done();
  CAMLreturn(Val_unit);
}

CAMLprim value wrapper_bdd_setvarnum(value num) {
  CAMLparam1(num);
  bdd_setvarnum(Int_val(num));
  CAMLreturn(Val_unit);
}

CAMLprim value wrapper_bdd_varnum() {
  CAMLparam0();
  CAMLreturn(Val_int(bdd_varnum()));
}

CAMLprim value wrapper_bdd_newpair() {
  CAMLparam0(); 
  CAMLlocal1(r);
  bddPair* shifter;
  r = alloc_custom(&bddpairops, sizeof (bddPair*), 1, 1);
  shifter = bdd_newpair();
  *((bddPair**)Data_custom_val(r)) = shifter;
  CAMLreturn(r);
}

CAMLprim value wrapper_bdd_fprinttable(value out, value bdd) {
  CAMLparam2(out, bdd);
  BDD x = *((BDD*)Data_custom_val(bdd));
  bdd_fprinttable(stream_of_channel(out,"wb"), x);
  CAMLreturn(Val_unit);
}

CAMLprim value wrapper_bdd_fprintset(value out, value bdd) {
  CAMLparam2(out, bdd);
  BDD x = *((BDD*)Data_custom_val(bdd));
  bdd_fprintset(stream_of_channel(out,"wb"), x);
  CAMLreturn(Val_unit);
}

CAMLprim value wrapper_bdd_fprintdot(value out, value bdd) {
  CAMLparam2(out, bdd);
  BDD x = *((BDD*)Data_custom_val(bdd));
  bdd_fprintdot(stream_of_channel(out,"wb"), x);
  CAMLreturn(Val_unit);
}

CAMLprim value wrapper_bdd_setvarorder(value neworder) {
  CAMLparam1(neworder);
  int h, i, n[bdd_varnum()];
  for (i = bdd_varnum() - 1; i >= 0; i--) { n[i] = 0; }
  i = 0;
  while (neworder != Val_emptylist) {
    h = Int_val(Field(neworder, 0));
    neworder = Field(neworder, 1);
    n[i]=h;
    i=i+1;
  }
  bdd_setvarorder(n);
  CAMLreturn(Val_unit);
}

CAMLprim value wrapper_bdd_addclause(value clause) {
  CAMLparam1(clause);
  CAMLlocal1(r);
  BDD e,x;
  if (clause == Val_emptylist) {
    CAMLreturn(r); /* XXX I know I know ... */
  } else {
    BDD bdd = *((BDD*)Data_custom_val((Field(clause, 0))));
    clause = Field(clause, 1);
    while (clause != Val_emptylist) {
      x = *((BDD*)Data_custom_val((Field(clause, 0))));
      e = bdd_or(x, bdd);
      bdd_delref(bdd);
      bdd_addref(e);
      bdd = e;
      clause = Field(clause, 1);
    }
    wrapper_makebdd(&r, bdd);
  }
  CAMLreturn(r);
}

CAMLprim value wrapper_bdd_allsat(value r, value f) {
  CAMLparam2(r,f);
  BDD bdd = *((BDD*)Data_custom_val(r));
  void handler(char* varset, int size) {
    CAMLlocal1(tl);
    int i;
    tl = Val_emptylist;
    for (i = 0 ; i < size; i++) {
      // printf("%d : %d\n", i, varset[i]);
      tl = append(tuple(Val_int(i),Val_int(varset[i])),tl);
    }
    callback(f,tl);
    return;
  }
  bdd_allsat(bdd,*handler);
  CAMLreturn(Val_unit);
}

/* 
 * creating a set representing bdd
 * (this is here to demonstrate callback)
 */

CAMLprim value wrapper_bdd_createset(value f) {
  CAMLparam1(f); 
  CAMLlocal1(r);
  int l,v;
  BDD d,e;
  d = bdd_true ();
  for (l = bdd_varnum() - 1; l >= 0; l--) 
    {
      v = bdd_level2var(l);
      if (Bool_val(callback(f, Val_int(v)))) 
        {
          /* bdd_ithvar is always reference-counted */
          e = bdd_and(bdd_ithvar(v), d); 
          bdd_delref(d);
          bdd_addref(e);
          d = e;
        }
    }
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

#define FUN11(name, arg0_type, ret_type) \
void wrapper_##name(value v0) \
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
FUN1(bdd_satcount, bdd, int)
FUN1(bdd_satcountln, bdd, int)
FUN3(bdd_setpair, bddpair, int, int, int)
FUN2(bdd_replace, bdd, bddpair, bdd)

FUN2(bdd_addvarblock, bdd, int, int)
FUN3(bdd_intaddvarblock, int, int, int, int)
FUN00(bdd_varblockall, unit)
FUN11(bdd_reorder, int, unit)
FUN1(bdd_autoreorder, int, int)
FUN00(bdd_enable_reorder, unit)
FUN00(bdd_disable_reorder, unit)
FUN1(bdd_reorder_verbose, int, int)
FUN00(bdd_printorder, unit)
FUN1(bdd_level2var, int, int)
FUN1(bdd_var2level, int, int)

FUN1(bdd_setcacheratio, int, int)
FUN1(bdd_setmaxincrease, int, int)

