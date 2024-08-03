BIN := dark-mode-notifier
INSTALL_DIR := $(HOME)/.local/bin

PLIST = $(HOME)/Library/LaunchAgents/com.dhruvmanila.darkmodenotifier.plist

.PHONY: all
all: $(INSTALL_DIR)/$(BIN) $(PLIST)

$(INSTALL_DIR)/$(BIN): main.swift
	swiftc $^ -o $@

$(PLIST): com.dhruvmanila.darkmodenotifier.plist
	cp $^ $@
