# Zsh Aliases

# cd {{{1

# Easier navigation to parent directories.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# cd to the previous directory.
alias -- -='cd -'

# defaults {{{1

# Show/hide all desktop icons.
alias show='defaults write com.apple.finder CreateDesktop -bool true && killall Finder'
alias hide='defaults write com.apple.finder CreateDesktop -bool false && killall Finder'

# Show/hide hidden files in Finder.
alias showhidden='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
alias hidehidden='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'

# docker {{{1

alias d='docker'
alias dc='docker compose'

# du {{{1

# Always show size in human readable format.
alias du='du -h'

# List the sizes of all the directories in the current directory.
alias usage='du -d 1'

# find {{{1

# Recursively delete `.DS_Store` files from the current directory.
alias cleanup='find . -type f -name "*.DS_Store" -ls -delete'

# git {{{1

alias g='git'

# ls {{{1

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

# nnn {{{1

# To reset `less`
alias nnn='LESS=-R nnn'

# nvim {{{1

alias v='nvim'
alias vi='nvim'

# Open Neovim with the minimal config file.
alias vm='nvim -n -u ${HOME}/dotfiles/config/nvim/minimal.lua'
#               │  │
#               │  └ use this config file
#               └ no swap file, use memory only

# Better `vim --startuptime` alternative.
# https://github.com/rhysd/vim-startuptime
alias vim-startuptime='vim-startuptime | head -n 30'
alias nvim-startuptime='\vim-startuptime -vimpath nvim | head -n 30'

# PATH {{{1

# List indivial path in separate line.
alias path='echo -e ${PATH//:/\\n}'

# python {{{1

alias python='python3'
alias pip='python3 -m pip'

# ssh {{{1

# Don't know if there is any other (better?) way to find out if we're in the
# kitty terminal or not.
#
# This will copy the terminfo file kitty uses (xterm-kitty) to the server.
# https://sw.kovidgoyal.net/kitty/faq/
if [[ -n "$KITTY_PID" ]]; then
  alias ssh='kitty +kitten ssh'
fi

# trash {{{1

# Default to using Finder for trash.
alias trash='trash -F'

# youtube-dl {{{1

alias yt='youtube-dl'
