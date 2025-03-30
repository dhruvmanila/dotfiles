# Start a bash shell for the given docker container.
dsh() {
  if (( $# == 0 )); then
    echo "Usage: $0 CONTAINER"
    return 1
  fi
  container_id=$(docker ps --format='{{.ID}}' --filter name="$1" | head -1)
  echo "==> Starting bash in $container_id..."
  docker exec --interactive --tty "$container_id" bash
}

# Show the last month git stats for the current repository. This includes the
# number of lines added/removed and the total.
#
# Ref: https://twitter.com/thorstenball/status/1293181225280999431
git-stats() {
  git log \
    --since "30 days ago" \
    --author "$(git config --get user.name)" \
    --pretty=tformat: --numstat |
      awk '{
        add += $1; subs += $2; loc += $1 - $2
      } END {
        printf "Lines: +\033[32m%s\033[0m -\033[31m%s\033[0m\nTotal: %s\n", add, subs, loc
      }'
}

# Get the latest master for the git repository and show the diff between then
# and now.
#
# $1 (string) (optional): remote name
# $2 (string) (optional): HEAD branch name
gld() {
  local curr_hash latest_hash
  curr_hash=$(git rev-parse HEAD)
  # These are optional arguments and if we quote them, the command will contain
  # empty string and `git` will complain.
  git pull $1 $2
  latest_hash=$(git rev-parse HEAD)
  if [[ "$curr_hash" != "$latest_hash" ]]; then
    # `show` will display the commit message along with the diff.
    git show "$curr_hash".."$latest_hash" | delta --side-by-side
  fi
}

# Create a new directory and enter it
mcd() {
  mkdir -p "$@" && cd "$_" || return
}

# Purpose: Avoid opening
# Block nesting of nnn in subshells
n() {
  if [ -n "$NNNLVL" ] && [ "${NNNLVL:-0}" -ge 1 ]; then
    echo "nnn is already running"
    return
  fi

  # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
  # To cd on quit only on ^G, remove the "export" as in:
  #
  #     export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
  #     ^----^
  #
  # NOTE: NNN_TMPFILE is fixed, should not be modified
  local NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

  nnn "$@"

  if [ -f "$NNN_TMPFILE" ]; then
    . "$NNN_TMPFILE"
    rm -f "$NNN_TMPFILE" > /dev/null
  fi
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location.
o() {
  if (( $# == 0 )); then
    open .
  else
    open "$@"
  fi
}

# Uninstall all the Python packages for the current environment except for the
# ones already included when the environment was created.
pip-uninstall() {
  python -m pip list \
    | awk 'NR>2 {if ($1 != "pip" && $1 != "setuptools") print $1}' \
    | xargs python -m pip uninstall --yes
}

# Upgrade the outdated Python packages for the current environment.
pip-upgrade() {
  python -m pip list --outdated \
    | awk 'NR>2 {print $1}' \
    | xargs python -m pip install --upgrade
}

# Activate the Python virtual environment built using the `uv` command.
#
# This checks for the `.venv` directory by climbing up the path until it
# finds the directory or reaches the system root directory (`/`).
#
# This is used for the `_python_auto_venv` hook, but can be used from the
# command-line as well.
#
# The activation part cannot be a script as that is executed in a subshell
# and so the `source` part will also be executed in the subshell instead of
# the current shell.
py-venv-activate() {
  local project_root="$PWD"
  while [[ "$project_root" != "/" && ! -e "$project_root/.venv" ]]; do
    project_root="${project_root:h}"
  done
  if [[ -e "$project_root/.venv/bin/activate" ]]; then
    source "$project_root/.venv/bin/activate"
  fi
}

# Open a CLI script in vim.
#
# For `pyenv`, it will resolve path using the provided command.
#
# Mnemonic: (vi)m (w)hich
viw() {
  local bin
  bin=$(which "$1")
  if [[ "$bin" == "$(pyenv root)/shims/"* ]]; then
    bin=$(pyenv which "$1")
  fi
  $EDITOR $(realpath "$bin")
}
