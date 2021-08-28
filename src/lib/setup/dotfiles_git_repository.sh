setup_dotfiles_git_repository() {
  header "Initializing Git repository..."
  set -x
  git init
  git remote add origin https://github.com/dhruvmanila/dotfiles
  git fetch --all
  git reset --hard FETCH_HEAD
  git branch --set-upstream-to origin/master master
  set +x
}
