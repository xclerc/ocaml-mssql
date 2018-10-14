all: build

build:
	@jbuilder build @install

clean:
	@rm -rf `find . -name 'bisect*.out'` _coverage
	@jbuilder clean

coverage: clean
	@BISECT_ENABLE=YES jbuilder runtest
	@bisect-ppx-report -I _build/default/ -html _coverage/ \
	  `find . -name 'bisect*.out'`

pin:
	# FreeTDS upstream holds the global OCaml lock; this branch fixes that
	# Remove when this pull request is merged: https://github.com/kennknowles/ocaml-freetds/pull/29
	opam pin add -yn freetds -k git \
		https://github.com/arenadotio/ocaml-freetds\#release-lock-during-io
	opam pin add -yn mssql .

test:
	@jbuilder runtest --force

# until we have https://github.com/ocaml/opam-publish/issues/38
REPO=../opam-repository
PACKAGES=$(REPO)/packages

pkg-%:
	topkg opam pkg -n $*
	mkdir -p $(PACKAGES)/$*
	cp -r _build/$*.* $(PACKAGES)/$*/
	rm -f $(PACKAGES)/$*/$*.opam
	cd $(PACKAGES) && git add $*

PKGS=$(basename $(wildcard *.opam))
opam-pkg:
	$(MAKE) $(PKGS:%=pkg-%)

.PHONY: all build clean coverage opam-pkg test
