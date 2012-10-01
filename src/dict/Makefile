all:
	@true

install: 
	mkdir -p $(IDATADIR)/hashkill/dict/
	cp * $(IDATADIR)/hashkill/dict

clean:
	@rm $(IDATADIR)/hashkill/dict/* 2>/dev/null || echo "Nothing to delete"

distclean: clean


#cc -o compile compile.c -I/opt/AMDAPP/include/ -L/opt/AMDAPP/lib/x86_64 -lOpenCL -g 