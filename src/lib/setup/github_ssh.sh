setup_github_ssh() {
  # NOTE: This function should be called after symlinking the dotfiles
  ssh -T git@github.com &> /dev/null
  if [[ $? -eq 1 ]]; then
    return
  fi

  local ssh_algorithm="ed25519"
  local ssh_filename="github"

  header "Generating SSH keys..."
  ask "Please provide an email address"
  ssh-keygen -f "${HOME}/.ssh/${ssh_filename}" -t "$ssh_algorithm" -C "$REPLY"

  # shellcheck disable=SC1090
  source "$(ssh-agent)"
  header "Adding SSH key to the ssh-agent..."
  ssh-add -K "${HOME}/.ssh/${ssh_filename}"

  header "Copied public SSH key to clipboard. Please add it to GitHub.com..."
  pbcopy < "${HOME}/.ssh/${ssh_filename}.pub"
  open "https://github.com/settings/ssh"
  for i in {1..6}; do
    ssh -T git@github.com &> /dev/null
    if [[ $? -eq 1 ]]; then
      header "Authentication successful."
      break
    else
      if [[ i -eq 6 ]]; then
        error "Exceeded max retries. Authenticate using 'ssh -T git@github.com' command."
        break
      fi
      error "Failed to authenticate. Retrying in 5 seconds..."
    fi
    sleep 5
  done
}
