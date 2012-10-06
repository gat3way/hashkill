ifneq ($(DESTDIR),"")
    IDESTDIR=$(DESTDIR)/
endif

all:
	@true

install:
	mkdir -p $(IDESTDIR)$(IDATADIR)/hashkill/rule
	cp -f * $(IDESTDIR)$(IDATADIR)/hashkill/rule
	rm $(IDESTDIR)$(IDATADIR)/hashkill/rule/Makefile

clean:

distclean:

maintainer-clean: