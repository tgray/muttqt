project = muttqt
srcdir = .
mansubdir = man
binsubdir = bin
docsdir = docs
scriptsdir = scripts
prefix ?= /usr/local
mandir ?= $(prefix)/share/man/man1
mans = $(addprefix $(docsdir)/,*.1)

# distribution variables
VERSIONNUM:=$(shell test -d .git && git describe --abbrev=0 --tags)
BUILDNUM:=$(shell test -d .git && git rev-parse --short HEAD)
distdir = $(project)-$(VERSIONNUM)-$(BUILDNUM)

# ronn/man variables
rdate = `date +'%Y-%m-%d'`
rmanual = muttqt
rorg = protozoic

all: muttqt docs

docs: $(mans)

test: 
	echo $(VERSIONNUM)
	echo ${prefix}
	echo ${mandir}

# make bin/
$(binsubdir):
	-mkdir -p $(binsubdir)

# copy to bindir
muttqt: $(binsubdir)
	cp muttqt $(binsubdir)/

# install files to their proper locations.
install: all
	-mkdir -p $(prefix)
	-mkdir -p $(prefix)/bin
	-mkdir -p $(prefix)/share/$(project)
	-mkdir -p $(mandir)
	install $(binsubdir)/* $(prefix)/bin/
	install $(scriptsdir)/* $(prefix)/share/$(project)/
	install -m 644 $(docsdir)/*.1 $(mandir)

# make the man files from the ronn files if needed
$(docsdir)/%.1: $(docsdir)/%.1.ronn
	ronn -r --date=$(rdate) --manual="$(rmanual)" --organization="$(rorg)" $(docsdir)/$*.1.ronn

# remove generated man files
cleanman:
	-rm $(docsdir)/*.1

dist: all
	-mkdir -p $(distdir)
	git archive master | tar -x -C $(distdir)
	tar czf $(distdir).tgz $(distdir)
	rm -rf $(distdir)

distclean: clean cleantgz

clean:
	-rm -rf bin
	-rm -f *~

cleantgz:
	-rm -f $(distdir).tgz
