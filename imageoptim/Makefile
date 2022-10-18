HELPINDEXES=$(addsuffix Help.helpindex, $(wildcard *.lproj/Help/))
SUBMODULES=../svgcleaner/src

build: all

all: $(SUBMODULES) pngout helpindexes

$(SUBMODULES): ../.gitmodules
	../scripts/fetch-submodule $(shell dirname $@) && touch $@

pngout:
	curl -L https://www.jonof.id.au/files/kenutils/pngout-20200115-linux-static.tar.gz | tar xz --strip-components-1

clean:
	-rm -rf pngout

install:

helpindexes:: $(HELPINDEXES)

%/Help.helpindex: %/index.html %/prefs.html
	./makehelp.sh $(patsubst %.lproj/Help/Help.helpindex,%,$@)

.PHONY: build all install clean
