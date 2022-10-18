VERSION=1.8.13
ARCHIVE=/tmp/pngcrush-$(VERSION).tar.gz

build: pngcrush.c

pngcrush.c:
	test -d tmp || mkdir -p tmp
	( cd tmp; curl -L https://downloads.sourceforge.net/project/pmt/pngcrush/$(VERSION)/pngcrush-$(VERSION).tar.gz | tar xz --strip-components=1 --exclude=Makefile )
	-rm tmp/png.h tmp/pngconf.h 2>/dev/null
	cp tmp/*.[ch] ./
	touch pngcrush.c

clean:
	-rm -rf tmp *.c *.h

install:

.PHONY: all build clean
