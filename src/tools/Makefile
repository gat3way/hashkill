ifneq ($(DESTDIR),"")
    IDESTDIR=$(DESTDIR)/
endif

all:
	cc -o pcap2hcap pcap2hcap.c -O2 $(LDFLAGS)
	cc -o markovgen markovgen.c -O2 $(LDFLAGS)


install:
	mkdir -p $(IDESTDIR)$(BINDIR)
	cp -f pcap2hcap $(IDESTDIR)$(BINDIR)

clean:
	rm pcap2hcap
	rm markovgen

distclean:
