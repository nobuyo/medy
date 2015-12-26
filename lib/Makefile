
SHELL = /bin/sh
.SUFFIXES:
.SUFFIXES: .sh .pl

# convert perl to shell

PERL_SCRIPTS  := $(wildcard *.pl)
SHELL_SCRIPTS := $(patsubst %.pl, %.sh, $(PERL_SCRIPTS))
OUTPUT        := ../bin/perl-module

.PHONY: pl2sh

pl2sh: $(SHELL_SCRIPTS)
$(SHELL_SCRIPTS): $(PERL_SCRIPTS)

%.sh: %.pl | $(OUTPUT)
	awk -f pl2sh.awk $< > $(OUTPUT)/$@

$(OUTPUT):
	mkdir -p $(OUTPUT)
