dsh() { # {{{1
  # Start a bash shell for the given docker container.
  if (( $# == 0 )); then
    echo "Usage: $0 CONTAINER"
    return 1
  fi
  container_id=$(docker ps --format='{{.ID}}' --filter name="$1" | head -1)
  echo "==> Starting bash in $container_id..."
  docker exec --interactive --tty "$container_id" bash
}

git-stats() { # {{{1
  # Show the last month git stats for the current repository. This includes the
  # number of lines added/removed and the total.
  #
  # Ref: https://twitter.com/thorstenball/status/1293181225280999431
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

gld() { # {{{1
  # Get the latest master for the git repository and show the diff between then
  # and now.
  #
  # $1 (string) (optional): remote name
  # $2 (string) (optional): HEAD branch name
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

mcd() { # {{{1
  # Create a new directory and enter it
  mkdir -p "$@" && cd "$_" || return
}

n() { # {{{1
  # Purpose: Avoid opening
  # Block nesting of nnn in subshells
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

o() { # {{{1
  # `o` with no arguments opens the current directory, otherwise opens the given
  # location.
  if (( $# == 0 )); then
    open .
  else
    open "$@"
  fi
}

pip-uninstall() { # {{{1
  # Uninstall all the Python packages for the current environment except for the
  # ones already included when the environment was created.
  python -m pip list \
    | awk 'NR>2 {if ($1 != "pip" && $1 != "setuptools") print $1}' \
    | xargs python -m pip uninstall --yes
}

pip-upgrade() { # {{{1
  # Upgrade the outdated Python packages for the current environment.
  python -m pip list --outdated \
    | awk 'NR>2 {print $1}' \
    | xargs python -m pip install --upgrade
}

py-venv-activate() { # {{{1
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
  local project_root="$PWD"
  while [[ "$project_root" != "/" && ! -e "$project_root/.venv" ]]; do
    project_root="${project_root:h}"
  done
  if [[ -e "$project_root/.venv/bin/activate" ]]; then
    source "$project_root/.venv/bin/activate"
  fi
}

py-upgrade-venv() { # {{{1
  # Upgrade the Python version for the current virtual environment.
  # NOTE: This assumes that we're using `pyenv` (custom script) to install
  # Python versions.
  #
  # $1 (string): upgrade to this version
  if [[ -z "$VIRTUAL_ENV" ]]; then
    echo "$0: not in a virtual environment"
    return 1
  elif (( $# != 1 )); then
    echo "Usage: $0 <version>"
    return 1
  fi
  local DEFINITION="$1"
  local PYTHON_EXEC="$PYENV_ROOT/versions/$DEFINITION/bin/python"
  if [[ ! -e $PYTHON_EXEC ]]; then
    echo "$0: version '$DEFINITION' not installed"
    echo "$0: Use 'pyenv install $DEFINITION' to install it"
    return 1
  fi
  # The `--upgrade` flag assumes that Python was upgraded in place, so we need
  # to update the symlink to point to the desired Python version.
  echo "$0: $VIRTUAL_ENV/bin/python -> $PYTHON_EXEC"
  ln -sf "$PYTHON_EXEC" "$VIRTUAL_ENV/bin/python"
  local VENV_PROMPT="${${VIRTUAL_ENV%-*}:t}"
  $PYTHON_EXEC -m venv --upgrade "$VIRTUAL_ENV" --prompt "$VENV_PROMPT"
  echo "$0: Upgraded to $DEFINITION"
}

rm-email() { # {{{1
  if ! (( $+commands[himalaya] )); then
    echo "$0: 'himalaya' command not found"
    return 1
  elif (( $# != 1 )); then
    echo "Usage: $0 <query>"
    return 1
  elif [[ -z "$1" ]]; then
   echo "$0: query cannot be empty"
   return 1
  fi

  output=$(NO_COLOR=1 himalaya search "$1" --size=0)
  printf "%s\n\n" "$output"

  read -q "?Above emails will be removed. Continue? [y/n] " confirm
  printf "\n"
  if [[ "$confirm" = "y" ]]; then
    himalaya delete \
      $(echo $output | awk 'NR > 2 && $1 != "" {print $1}' | paste -s -d ',' -)
  fi
}

viw() { # {{{1
  # Open a CLI script in vim
  # For `pyenv`, it will resolve path using the provided command.
  # Mnemonic: (vi)m (w)hich
  local bin
  bin=$(which "$1")
  if [[ "$bin" == "$(pyenv root)/shims/"* ]]; then
    bin=$(pyenv which "$1")
  fi
  $EDITOR $(realpath "$bin")
}

