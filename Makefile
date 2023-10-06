BIN := dotbot
DOTFILES := $(HOME)/dotfiles
BIN_DIR := $(DOTFILES)/bin
BASH_COMPLETION := $(DOTFILES)/config/bash/completions/$(BIN).bash

SH_FILES := $(shell find src -type f -name '*.sh')

$(BIN_DIR)/$(BIN): Makefile $(SH_FILES) src/bashly.yml
	BASHLY_TARGET_DIR=$(BIN_DIR) BASHLY_ENV=production bashly generate --upgrade
	bashly add completions_script $(BASH_COMPLETION) --force
	shfmt -w -i 2 -bn -ci -sr $(BIN_DIR)/$(BIN)
