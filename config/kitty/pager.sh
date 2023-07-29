#!/usr/bin/env bash
#
# Related issue: https://github.com/kovidgoyal/kitty/issues/719
#
# Actual solution which doesn't work for me :(
#   https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731

TMP_FILE="$(mktemp -t kitty_scrollback_buffer)"

INPUT_LINE_NUMBER=${1:-0} CURSOR_LINE=${2:-1} CURSOR_COLUMN=${3:-1} ~/neovim/bin/nvim \
  --clean \
  -u ~/.config/kitty/init.lua \
  -c "silent write! $TMP_FILE | terminal cat $TMP_FILE - "

rm "$TMP_FILE"
