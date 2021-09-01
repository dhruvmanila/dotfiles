BIN := dot
BIN_DIR := $(HOME)/dotfiles/bin
BASH_COMPLETION := /usr/local/etc/bash_completion.d/$(BIN)-completion.bash

SH_FILES := $(shell find src -type f -name '*.sh')

$(BIN_DIR)/$(BIN): $(SH_FILES)
	BASHLY_TARGET_DIR=$(BIN_DIR) bashly generate
	bashly add comp script $(BASH_COMPLETION)
	shfmt -w -i 2 -bn -ci -sr $(BIN_DIR)/$(BIN)
