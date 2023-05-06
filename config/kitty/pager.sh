#!/usr/bin/env bash
#
# Related issue: https://github.com/kovidgoyal/kitty/issues/719
#
# Actual solution which doesn't work for me :(
#   https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731

INPUT_LINE_NUMBER=${1:-0} CURSOR_LINE=${2:-1} CURSOR_COLUMN=${3:-1} ~/neovim/bin/nvim \
  --clean \
  -u ~/.config/kitty/init.lua \
  -c "silent write! /tmp/kitty_scrollback_buffer | terminal cat /tmp/kitty_scrollback_buffer - "
