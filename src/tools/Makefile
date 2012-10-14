ifneq ($(DESTDIR),"")
    IDESTDIR=$(DESTDIR)/
endif

all:
	$(CC) -o pcap2hcap pcap2hcap.c -O2 $(LDFLAGS)
	$(CC) -o markovgen markovgen.c -O2 $(LDFLAGS)


install:
	mkdir -p $(IDESTDIR)$(BINDIR)
	cp -f pcap2hcap $(IDESTDIR)$(BINDIR)

install-strip:
	strip pcap2hcap
	strip markovgen
	mkdir -p $(IDESTDIR)$(BINDIR)
	cp -f pcap2hcap $(IDESTDIR)$(BINDIR)
	cp -f markovgen $(IDESTDIR)$(BINDIR)

clean:
	-rm -f pcap2hcap
	-rm -f markovgen

distclean:

maintainer-clean:
