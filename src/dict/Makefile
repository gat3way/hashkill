ifneq ($(DESTDIR),"")
    IDESTDIR=$(DESTDIR)/
endif


all:
	@true

install: 
	mkdir -p $(IDESTDIR)$(IDATADIR)/hashkill/dict/
	cp * $(IDESTDIR)$(IDATADIR)/hashkill/dict

clean:
	@rm -f $(IDESTDIR)$(IDATADIR)/hashkill/dict/* 2>/dev/null || echo "Nothing to delete"

distclean: clean

maintainer-clean: clean

#cc -o compile compile.c -I/opt/AMDAPP/include/ -L/opt/AMDAPP/lib/x86_64 -lOpenCL -g 