# CFLAGS, CPPFLAGS, LDFLAGS

# The following softwares are installed via Homebrew but they're not symlinked
# as they are keg-only. The official instructions is to include them in common
# compiler environment variables.
#
# NOTE: Homebrew installed `clang` compiler does not search for header and
# library files in `/usr/local/{include,lib}` directories, so they're added
# here. This can be seen by running the following command:
#
#     $ clang -x c -v -E /dev/null

# if [[ -n "$HOMEBREW_PREFIX" ]]; then
#   export CFLAGS="-I$HOMEBREW_PREFIX/include -I$HOMEBREW_PREFIX/opt/openssl@3/include"
#   export CPPFLAGS="$CFLAGS"

#   export LDFLAGS="-L$HOMEBREW_PREFIX/lib -L$HOMEBREW_PREFIX/opt/openssl@3/lib"
# fi

# Run `bat --list-themes` for a list of all available themes
export BAT_THEME="gruvbox-dark"
export BAT_STYLE="changes,header,numbers,rule"

# Make Neovim the default editor.
# https://unix.stackexchange.com/questions/4859/visual-vs-editor-what-s-the-difference
export EDITOR='nvim'
export VISUAL="$EDITOR"

# Fzf configuration
# TODO: Add light color scheme
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

# Avoid issues with `gpg` as installed via Homebrew.
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY="$(tty)"

# export GOPROXY="https://proxy.golang.org/"

# The variable is already set by system rc file but that can change and without
# this, the history is not saved.
export HISTFILE="$HOME/.zsh_history"

# Infinite history
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE

# Opt-out of homebrew's analytics
export HOMEBREW_NO_ANALYTICS=1

# Do not create the lock file on `brew bundle`
export HOMEBREW_BUNDLE_NO_LOCK=1
export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/lib/Brewfile"

# Use `bat` for `brew cat` command.
export HOMEBREW_BAT=1

# Do not show environment variable hints. HOMEBREW_* environment variables can
# be found at `man brew /Environment`.
export HOMEBREW_NO_ENV_HINTS=1

# Default options to pass to the `less(1)` command.
export LESS='--ignore-case --tilde --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --chop-long-lines'

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Use Neovim as the man pager.
export MANPAGER="nvim +Man!"

# Default options to pass to the `nnn(1)` command.
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

# Disable virtual environment prompt.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8'
export PIP_REQUIRE_VIRTUALENV=true

# https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
export RIPGREP_CONFIG_PATH="$HOME/dotfiles/config/ripgreprc"
