ifneq ($(DESTDIR),"")
    IDESTDIR=$(DESTDIR)/
endif

all:
	$(CC) -o pcap2hcap pcap2hcap.c -O2 $(LDFLAGS) -Wno-unused-result
	$(CC) -o markovgen markovgen.c -O2 $(LDFLAGS) -Wno-unused-result


install:
	mkdir -p $(IDESTDIR)$(BINDIR)
	cp -f pcap2hcap $(IDESTDIR)$(BINDIR)
	cp -f markovgen $(IDESTDIR)$(BINDIR)
	cp -f lastpass2hashkill $(IDESTDIR)$(BINDIR)

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
