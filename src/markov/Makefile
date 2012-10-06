ifneq ($(DESTDIR),"")
    IDESTDIR=$(DESTDIR)/
endif


LIBS  = 
CFLAGS = -O2 -fpic  -fomit-frame-pointer -minline-all-stringops  -Wall

CC = gcc


# alphabetical order!!!
all: 


install:
	mkdir -p $(IDESTDIR)$(IDATADIR)/hashkill/markov
	chmod ugo+r $(IDESTDIR)$(IDATADIR)/hashkill/markov
	cp -f *.stat $(IDESTDIR)$(IDATADIR)/hashkill/markov

clean:


distclean:

maintainer-clean:
