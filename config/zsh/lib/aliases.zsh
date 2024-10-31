# List indivial path in separate line.
alias path='echo -e ${PATH//:/\\n}'

# Reload the shell (i.e. invoke as a login shell)
alias reload='exec $SHELL -l'

# Global aliases -- These do not have to be at the beginning of the command line.
alias -g H='--help | less'
alias -g L='| less'
alias -g N='> /dev/null'
alias -g E='2> /dev/null'
alias -g T='| tail'

alias hn='clx --nerdfonts --comment-width=$((COLUMNS - 10))'

# Quick access to programs
alias d='docker'
alias dc='docker compose'
alias g='git'
alias v='nvim'
alias yt='yt-dlp'

# Easier navigation to parent directories.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# cd to the previous directory.
alias -- -='cd -'

# Always show size in human readable format.
alias du='du -h'

# List the sizes of all the directories in the current directory.
alias dud='du -d 1'

# Recursively delete `.DS_Store` files from the current directory.
alias cleanup='find . -type f -name "*.DS_Store" -ls -delete'

# Detect which `ls` flavor is in use along with the common options.
#
# `-h`: display size using human-readable units
# `-F`: append indicator to entries (@ symlink, / directory, * executable, etc.)
if ls --color > /dev/null 2>&1; then # GNU `ls`
  alias ls='ls --color=auto -h -F'
else # macOS `ls`
  alias ls='ls -G -h -F'
fi

# Show files in long listing format
alias l='ls -l'
alias la='ls -lA'
#              └ show entries starting with . (dot) except for . and ..

# List only directories and symbolic links that point to directories.
# See `man zshexpn(1)` /Glob Qualifiers
alias lsd='ls -ld *(-/DN)'

# To reset `less`
alias nnn='LESS=-R nnn'

# From `man zshmisc(1)` /nocorrect
#
#     > Spelling correction is not done on any of the words. This must appear
#     > before any other precommand modifier, as it is interpreted immediately,
#     > before any parsing is done. It has no effect in non-interactive shells.

alias cp='nocorrect cp'
alias man='nocorrect man'
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias sudo='nocorrect sudo'

# Open Neovim with the minimal config file.
alias vm='nvim -n -u ${HOME}/dotfiles/config/nvim/minimal.lua'
#               │  │
#               │  └ use this config file
#               └ no swap file, use memory only

# Better `vim --startuptime` alternative.
# https://github.com/rhysd/vim-startuptime
alias vim-startuptime='vim-startuptime | head -n 30'
alias nvim-startuptime='\vim-startuptime -vimpath nvim | head -n 30'

# Open Neovim in development mode.
alias nvim-dev='cd ${HOME}/contributing/neovim && VIMRUNTIME=runtime ./build/bin/nvim && cd -'

# This will copy the terminfo file kitty uses (xterm-kitty) to the server.
# https://sw.kovidgoyal.net/kitty/faq/
if [[ "$TERM" = "xterm-kitty" ]]; then
  alias ssh='kitty +kitten ssh'
fi

# Default to using Finder for trash.
alias trash='trash -F'
alias rm='trash'
