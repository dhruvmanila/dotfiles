DOTFILES := $(HOME)/dotfiles
DOTFILES_BIN_DIR = $(DOTFILES)/bin
DOTBOT_BIN = $(DOTFILES_BIN_DIR)/dotbot

SH_FILES := $(shell find src -type f -name '*.sh')

.PHONY: all
all: $(DOTBOT_BIN)

$(DOTBOT_BIN): $(SH_FILES) src/bashly.yml
	BASHLY_TARGET_DIR=$(DOTFILES_BIN_DIR) BASHLY_ENV=production bashly generate --upgrade
	bashly add completions_script $(DOTFILES)/config/bash/completions/dotbot.bash --force
	shfmt -w -i 2 -bn -ci -sr $@
