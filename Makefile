BIN := dotbot
DOTFILES := $(HOME)/dotfiles
BIN_DIR := $(DOTFILES)/bin
BASH_COMPLETION := $(DOTFILES)/config/bash/completions/$(BIN).bash

SH_FILES := $(shell find src -type f -name '*.sh')

$(BIN_DIR)/$(BIN): $(SH_FILES) src/bashly.yml
	BASHLY_TARGET_DIR=$(BIN_DIR) bashly generate
	bashly add comp script $(BASH_COMPLETION) --force
	shfmt -w -i 2 -bn -ci -sr $(BIN_DIR)/$(BIN)

.PHONY: docker
docker:
	docker build --tag dhruvmanila/dotfiles:latest .
	docker push dhruvmanila/dotfiles:latest
