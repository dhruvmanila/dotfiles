# CFLAGS, CPPFLAGS, LDFLAGS {{{1

# The following softwares are installed via Homebrew but they're not symlinked
# as they are key-only. The official instructions is to include them in common
# compiler environment variables.
#
# NOTE: Homebrew installed `clang` compiler does not search for header and
# library files in `/usr/local/{include,lib}` directories, so they're added
# here. This can be seen by running the following command:
#
#     $ clang -x c -v -E /dev/null

if [[ -n "$HOMEBREW_PREFIX" ]]; then
  export CFLAGS="\
  -I$HOMEBREW_PREFIX/include \
  -I$HOMEBREW_PREFIX/opt/openssl@3/include \
  "
  export CPPFLAGS="$CFLAGS"

  export LDFLAGS="\
  -L$HOMEBREW_PREFIX/lib \
  -L$HOMEBREW_PREFIX/opt/openssl@3/lib \
  "
fi

# bat {{{1

# Specify desired highlighting theme (e.g. "TwoDark"). Run `bat --list-themes`
# for a list of all available themes
export BAT_THEME="gruvbox-dark"

# Specify the style
# * full: enables all available components.
# * auto: same as 'full', unless the output is piped (default).
# * plain: disables all available components.
# * changes: show Git modification markers.
# * header: show filenames before the content.
# * grid: vertical/horizontal lines to separate side bar
#         and the header from the content.
# * rule: horizontal lines to delimit files.
# * numbers: show line numbers in the side bar.
# * snip: draw separation lines between distinct line ranges.
export BAT_STYLE="changes,header,numbers,rule"

# EDITOR {{{1

# Make Neovim the default editor.
# https://unix.stackexchange.com/questions/4859/visual-vs-editor-what-s-the-difference
export EDITOR='nvim'
export VISUAL="$EDITOR"

# fzf {{{1

# Fzf configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_DEFAULT_OPTS='
  --height=50%
  --layout=reverse
  --info=inline
  --prompt="❯ "
  --bind=ctrl-p:toggle-preview
  --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54'

# Molokai for fzf
# --color fg:252,bg:233,hl:67,fg+:252,bg+:235,hl+:81
# --color info:144,prompt:161,spinner:135,pointer:135,marker:118

export FZF_CTRL_R_OPTS="
  --prompt='History ❯ '
  --preview 'echo {}'
  --preview-window down:3:wrap
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --prompt='Files ❯ '
  --preview 'bat --color=always --line-range :300 {}'"

export FZF_ALT_C_COMMAND='fd --type d . --hidden --exclude .git'
export FZF_ALT_C_OPTS="
  --prompt='CD ❯ '
  --preview 'tree -C {} | head -100'"

# gpg {{{1

# Avoid issues with `gpg` as installed via Homebrew.
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY="$(tty)"

# history {{{1

# The variable is already set by system rc file but that can change and without
# this, the history is not saved.
export HISTFILE="$HOME/.zsh_history"

# Infinite history
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE

# Homebrew {{{1

# Opt-out of homebrew's analytics
export HOMEBREW_NO_ANALYTICS=1

# Do not create the lock file on `brew bundle`
export HOMEBREW_BUNDLE_NO_LOCK=1
export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/lib/Brewfile"

# Use `bat` for `brew cat` command.
export HOMEBREW_BAT=1

# Do not show environment variable hints. HOMBREW_* environment variables can
# be found at `man brew /Environment`.
export HOMEBREW_NO_ENV_HINTS=1

# less {{{1

# `less(1)` default options to pass to the command.
#
# `i` - ignore case in search pattern. This option is ignored if it contains
#       uppercase characters
# `~` - Normally lines after end of file are displayed as a single tilde (~).
#       This option causes lines after end of file to be displayed as blank lines.
# `J` - Show status column at the left edge of the screen
# `M` - Make prompt more verbose. At the bottom of the screen, it prints info
#       about our position with a percentage, and line numbers.
# `R` - Send ANSI "color" escape sequences and OSC 8 hyperlink in "raw" form
#       which will allow us to see colors. This is useful for commands such as
#       `git log`. Without, you would see things like `ESC[33m ... ESC[m`.
# `S` - Causes lines longer than the screen width to be chopped (truncated)
#       rather than wrapped. That is, the portion of a long line that does
#       not fit in the screen width is not displayed until you press RIGHT-
#       ARROW. The default is to wrap long lines; that is, display the
#       remainder on the next line.
export LESS='i~JMRS'

# `X` - leave content on-screen
# `F` - quit automatically if less than one screenfull

# locale {{{1

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# man {{{1

export MANPAGER="nvim +Man!"

# nnn {{{1

# Options {{{
#                ┌ detail mode
#                │┌ show directories in context color with NNN_FCOLORS set
#                ││┌ open text files in $VISUAL/$EDITOR/vi
#                │││┌ show hidden files (toggled with '.')
#                ││││┌ use selection (no prompt)
#                │││││┌ show user and group names in status bar
#                ││││││ }}}
export NNN_OPTS="dDeHuU"
export NNN_FIFO=/tmp/nnn.fifo

# These are defined in the `bat` section.
export NNN_BATTHEME="$BAT_THEME"
export NNN_BATSTYLE="$BAT_STYLE"

# Use system Trash.
#
# This actually uses `trash-put` from `trash-cli` but we are using `trash` from
# Homebrew and so an alias script by the same name exists on PATH.
export NNN_TRASH=1

# Plugins {{{
#
# - To run a plugin, press ; followed by the key or Alt+key
# - To skip directory refresh after running a plugin, prefix with -
# - To assign keys to arbitrary non-background non-shell-interpreted cli
#   commands and invoke like plugins, add ! (bang) before the command.
# }}}
NNN_SHELL_PLUGINS='l:-!git log;x:!chmod +x $nnn'
NNN_PLUGINS='p:preview-tui;c:fzcd;o:fzopen'
export NNN_PLUG="$NNN_PLUGINS;$NNN_SHELL_PLUGINS"

unset NNN_SHELL_PLUGINS NNN_PLUGINS

# Python {{{1

# Disable virtual environment prompt.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8'

# ripgrep {{{1

# https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
export RIPGREP_CONFIG_PATH="$HOME/dotfiles/config/ripgreprc"
