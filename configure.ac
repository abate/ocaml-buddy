AC_INIT(ocaml-buddy, 0.8, pietro.abate@pps.jussieu.fr)
AC_CONFIG_SRCDIR(buddy.mli)

AC_CHECKING(for ocaml compiler and tools)
AC_CHECK_PROG(ocamlc,ocamlc,ocamlc)
AC_CHECK_PROG(ocamlopt,ocamlopt,ocamlopt)
AC_CHECK_PROG(ocamlfind,ocamlfind,ocamlfind)

#AC_PROG_INSTALL
#AC_SUBST(INSTALL)

AC_CHECKING(for C compiler)
AC_PROG_CC

AC_CHECKING(for C header files)
AC_HEADER_STDC

AC_CHECKING(libraries)

AC_ARG_WITH(
  bdd,
  [AC_HELP_STRING([[--with-buddy=PATH]],[base directory for buddy])],
  [LIBS="$LIBS -L$withval/lib"
   CPPFLAGS="$CPPFLAGS -I$withval/include"])

AC_CHECKING(for buddy library)
AC_CHECK_LIB(
  bdd, bdd_init,,
  AC_ERROR([Buddy is required.  See the --with-buddy configure option.]))

AC_CHECKING(for buddy header files)
AC_CHECK_HEADER(bdd.h,,
  AC_ERROR([Buddy is required.  See the --with-buddy configure option.]))

AC_CHECKING(for OCaml header files)
CAMLLOC=`$ocamlc -where`
CPPFLAGS="$CPPFLAGS -I$CAMLLOC"
AC_OUTPUT(Makefile)
AC_OUTPUT(META)
