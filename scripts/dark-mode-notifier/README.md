# Dark Mode Notifier

A simple executable that listens for changes in the macOS dark mode setting and
updates the Kitty terminal's theme accordingly.

Run `make` from the root directory to build and install the executable. The
executable will be installed to `~/.local/bin/dark-mode-notifier`. It'll
also be installed as a launch agent to run on login.

Reference: https://github.com/mnewt/dotemacs/blob/8a153b133d289867415e99665d49e288cc0def5d/bin/dark-mode-notifier.swift
