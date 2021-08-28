# shellcheck disable=SC2154
force=${args[--force]}

if ! [[ $force ]]; then
  declare -i count=0
  backup_dir="${HOME}/dotfiles_$(date +"%Y_%m_%dT%H_%M_%S").backup"
  mkdir "$backup_dir"

  for location in "${BACKUP_DOTFILES[@]}"; do
    if [[ -f $location || -d $location ]]; then
      cp -R "$location" "$backup_dir"
      ((count += 1))
    fi
  done

  if ((count > 0)); then
    header "Created backup in ${backup_dir}"
  else
    header "Skipped backup as there are no dotfiles"
    rm -rf "$backup_dir"
  fi
fi

setup_symlinks
