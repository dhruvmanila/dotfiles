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
  link ".editorconfig" ".editorconfig"

  # Bash
  link "bash/bashrc" ".bashrc"
  link "bash/bash_profile" ".bash_profile"

  # Zsh
  link "zsh/zshrc" ".zshrc"
  link "zsh/zshenv" ".zshenv"
  link "zsh/zprofile" ".zprofile"

  # Neovim/Vim
  link "vim/vimrc" ".vimrc"
  link "vim" ".vim"
  link "config/nvim" ".config/nvim"

  # Tmux
  link "tmux/tmux.conf" ".tmux.conf"

  # Python
  link "python/pip" ".config/pip"
  link "python/flake8" ".config/flake8"
  link "python/pylintrc" ".pylintrc"
  link "python/ipython/ipython_config.py" ".ipython/profile_default/ipython_config.py"
  link "python/ipython/startup" ".ipython/profile_default/startup"

  # Git
  link "assets/git/gitignore" ".gitignore"
  link "assets/git/gitconfig" ".gitconfig"
  link "assets/git/gitmessage" ".gitmessage"

  # Shell
  link "assets/inputrc" ".inputrc"
  link "assets/gpg/gpg.conf" ".gnupg/gpg.conf"
  link "assets/gpg/gpg-agent.conf" ".gnupg/gpg-agent.conf"
  link "assets/ssh/config" ".ssh/config"

  # Mac
  link "mac/karabiner" ".config/karabiner"
  link "mac/hammerspoon" ".hammerspoon"

  # CLI config
  link "config/youtube-dl" ".config/youtube-dl"
  link "config/bpytop" ".config/bpytop"
  link "config/htop" ".config/htop"
  link "config/bottom" "Library/Application Support/bottom"
  link "config/bat" ".config/bat"
  link "config/kitty" ".config/kitty"
  link "config/glow" "Library/Preferences/glow"
}
