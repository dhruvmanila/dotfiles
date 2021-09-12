# shellcheck disable=SC2154
sync_brew=${args[--brew]}
sync_node=${args[--node]}
sync_python=${args[--python]}

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
  pip-compile --quiet "$PACKAGE_DIR/requirements.in"
fi

if [[ $sync_all || $sync_node ]]; then
  header "Syncing node_modules.txt with the global Node packages..."
  npm --global --json list \
    | jq --raw-output '.dependencies | del(."instant-markdown-d") | keys | join("\n")' \
      > "${NPM_GLOBAL_PACKAGES}"
fi
