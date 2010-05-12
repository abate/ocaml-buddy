
NAME = buddy
VERSION = 0.1

LIBS = _build/$(NAME).cma
LIBS_OPT = _build/$(NAME).cmxa
PROGS = _build/solver.byte
PROGS_OPT = _build/solver.native
RESULTS = $(LIBS) $(PROGS)
RESULTS_OPT = $(LIBS_OPT) $(PROGS_OPT)
SOURCES = $(wildcard *.ml *.mli) *.c

OCAMLBUILD = ocamlbuild
OBFLAGS = -classic-display
OCAMLFIND = ocamlfind

DESTDIR =
LIBDIR = $(DESTDIR)/$(shell ocamlc -where)
BINDIR = $(DESTDIR)/usr/bin
ifeq ($(DESTDIR),)
INSTALL = $(OCAMLFIND) install
UNINSTALL = $(OCAMLFIND) remove
else
INSTALL = $(OCAMLFIND) install -destdir $(LIBDIR)
UNINSTALL = $(OCAMLFIND) remove -destdir $(LIBDIR)
endif

DIST_DIR = $(NAME)-$(VERSION)
DIST_TARBALL = $(DIST_DIR).tar.gz
DEB_TARBALL = $(subst -,_,$(DIST_DIR).orig.tar.gz)

all: $(RESULTS)
opt: $(RESULTS_OPT)
$(RESULTS): $(SOURCES)
$(RESULTS_OPT): $(SOURCES)

clean:
	$(OCAMLBUILD) $(OBFLAGS) -clean

_build/%:
	$(OCAMLBUILD) $(OBFLAGS) $*
	@touch $@

docs:
	if [ ! -d doc ]; then mkdir doc; fi
	ocamldoc $(OCFLAGS) -html -d doc $(NAME).mli

headers: header.txt .headache.conf
	headache -h header.txt -c .headache.conf $(SOURCES)

INSTALL_STUFF = META
INSTALL_STUFF += $(wildcard _build/*$(NAME)*.cma _build/$(NAME).cmxa _build/*$(NAME)*.a)
INSTALL_STUFF += $(wildcard _build/*$(NAME)*.cmi) $(wildcard *.mli)
INSTALL_STUFF += $(wildcard _build/*$(NAME)*.cmx _build/dll$(NAME)_stubs.so)

# -ldconf ignore _build/dll$(NAME)_stubs.so

install:
	test -d $(LIBDIR) || mkdir -p $(LIBDIR)
	$(INSTALL) -ldconf ignore -patch-version $(VERSION) $(NAME) $(INSTALL_STUFF)

uninstall:
	$(UNINSTALL) $(NAME)

test: _build/test.byte test.ml
	_build/test.byte -verbose

