# shellcheck disable=SC2154
sync_brew=${args[--brew]}
sync_node=${args[--node]}
sync_python=${args[--python]}
sync_cargo=${args[--cargo]}

# If there are no arguments, then the default behavior is to sync all files.
if [[ -z ${args[*]} ]]; then
  sync_all=1
fi

if [[ $sync_all || $sync_brew ]]; then
  header "Syncing Brewfile with the currently installed packages..."
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle dump -f --describe
fi

if [[ $sync_all || $sync_python ]]; then
  header "Syncing requirements.txt with the global Python packages..."
  pipx list --json \
    | jq --raw-output '.venvs | keys | join("\n")' \
      > "${PYTHON_GLOBAL_REQUIREMENTS}"
fi

if [[ $sync_all || $sync_node ]]; then
  header "Syncing node_modules.txt with the global Node packages..."
  npm --global --json list \
    | jq --raw-output '.dependencies | del(."instant-markdown-d") | keys | join("\n")' \
      > "${NPM_GLOBAL_PACKAGES}"
fi

if [[ $sync_all || $sync_cargo ]]; then
  header "Syncing cargo_packages.txt with the global Cargo packages..."
  cargo install --list \
    | awk -F ' ' '{ if(NR % 2 == 1) {print $1} }' \
      > "${CARGO_GLOBAL_PACKAGES}"
fi
