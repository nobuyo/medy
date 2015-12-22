
SHELL = /bin/sh

BASE_FILE = ./bin/base.sh
GEN_FILE  = ./bin/medy

.PHONY: combine force
.SILENT: $(GEN_FILE)

all: combine

combine: $(GEN_FILE)
$(GEN_FILE): ./bin/common.sh ./bin/medy-*.sh ./lib/*.pl
	awk -f lib/combine.awk $(BASE_FILE) > $(GEN_FILE)
	chmod +x $(GEN_FILE)

