#!/usr/bin/env bash
#
# Related issue: https://github.com/kovidgoyal/kitty/issues/719

# Kitty can be launched by macOS without the shell PATH, so use known absolute
# install paths. Homebrew installs nvim under /opt/homebrew, MacPorts uses /opt/local,
# and ~/neovim/bin is used for local builds.
for nvim_path in /opt/homebrew/bin/nvim /opt/local/bin/nvim ~/neovim/bin/nvim; do
  if [[ -x "$nvim_path" ]]; then
    break
  fi
done

if [[ ! -x "$nvim_path" ]]; then
  echo 'Could not find nvim' >&2
  exit 1
fi

KITTY_SCROLLBACK=1 INPUT_LINE_NUMBER="${1:-0}" CURSOR_LINE="${2:-1}" CURSOR_COLUMN="${3:-1}" "$nvim_path" \
  -
