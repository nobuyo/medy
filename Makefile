
SHELL = /bin/sh

BASE_FILE = ./bin/medy.sh
GEN_FILE  = ./bin/combined-medy.sh

.PHONY: combine force
.SILENT: $(GEN_FILE)

all: combine

combine: $(GEN_FILE)
$(GEN_FILE): ./bin/common.sh ./bin/medy*.sh ./lib/*.pl
	awk -f lib/combine.awk $(BASE_FILE) > $(GEN_FILE)
	chmod +x $(GEN_FILE)

