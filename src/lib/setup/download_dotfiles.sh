download_dotfiles() {
  header "Downloading the dotfiles..."
  mkdir -p "${DOTFILES_DIRECTORY}"
  curl -fsSLo ~/dotfiles.tar.gz https://github.com/dhruvmanila/dotfiles/tarball/master

  header "Extracting the dotfiles..."
  tar -zxf "${HOME}/dotfiles.tar.gz" --strip-components 1 -C "${DOTFILES_DIRECTORY}"
  rm -rf ~/dotfiles.tar.gz
}
