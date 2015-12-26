
SHELL = /bin/sh

BASE_FILE = ./bin/base.sh
GEN_FILE  = ./bin/medy
BUILD_FILE = ./medy

.PHONY: combine recombine deploy

all: combine

combine: $(GEN_FILE)
$(GEN_FILE): $(BASE_FILE) ./bin/common.sh ./bin/medy-*.sh ./bin/perl-module/*.sh
	awk -f lib/combine.awk $(BASE_FILE) > $(GEN_FILE)
	awk -f lib/combine.awk $(BASE_FILE) > $(BUILD_FILE)
	chmod +x $(GEN_FILE) $(BUILD_FILE)

recombine:
	@touch $(BASE_FILE)
	@$(MAKE) combine

deploy:
	cp -f $BUILD_FILE /bin/medy
	chmod +x /bin/medy

