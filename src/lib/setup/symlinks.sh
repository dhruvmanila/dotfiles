declare -A symlinks

symlinks=(
  [".editorconfig"]=".editorconfig"
  ["assets/git/gitconfig"]=".gitconfig"
  ["assets/git/gitignore"]=".gitignore"
  ["assets/git/gitmessage"]=".gitmessage"
  ["assets/gpg/gpg-agent.conf"]=".gnupg/gpg-agent.conf"
  ["assets/gpg/gpg.conf"]=".gnupg/gpg.conf"
  ["assets/inputrc"]=".inputrc"
  ["assets/ssh/config"]=".ssh/config"
  ["bash/bash_profile"]=".bash_profile"
  ["bash/bashrc"]=".bashrc"
  ["config/bat"]=".config/bat"
  ["config/bottom"]="Library/Application Support/bottom"
  ["config/bpytop"]=".config/bpytop"
  ["config/glow"]="Library/Preferences/glow"
  ["config/htop"]=".config/htop"
  ["config/kitty"]=".config/kitty"
  ["config/nvim"]=".config/nvim"
  ["config/youtube-dl"]=".config/youtube-dl"
  ["mac/hammerspoon"]=".hammerspoon"
  ["mac/karabiner"]=".config/karabiner"
  ["python/flake8"]=".config/flake8"
  ["python/ipython/ipython_config.py"]=".ipython/profile_default/ipython_config.py"
  ["python/ipython/startup"]=".ipython/profile_default/startup"
  ["python/pip"]=".config/pip"
  ["python/pylintrc"]=".pylintrc"
  ["tmux/tmux.conf"]=".tmux.conf"
  ["vim"]=".vim"
  ["vim/vimrc"]=".vimrc"
  ["zsh/zprofile"]=".zprofile"
  ["zsh/zshenv"]=".zshenv"
  ["zsh/zshrc"]=".zshrc"
)

setup_symlinks() {
  # What does this file do? {{{
  #
  #   > Immediately after logging a user in, login displays the system copyright
  #   > notice, the date and time the user last logged in, the message of the day
  #   > as well as other information. If the file .hushlogin exists in the user's
  #   > home directory, all of these messages are suppressed.
  #
  # Source: `man login`
  # }}}
  if [[ ! -f "${HOME}/.hushlogin" ]]; then
    touch ~/.hushlogin
  fi

  # Create the necessary symbolic links between the `dotfiles` and `HOME` directory.
  header "Creating the necessary symlinks..."

  #                ┌ list associative array keys
  #                │
  for source in "${!symlinks[@]}"; do
    link "$source" "${symlinks[$source]}"
  done
}
