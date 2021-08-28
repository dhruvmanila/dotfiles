# shellcheck disable=SC2154
dock=${args[--dock]}
settings=${args[--settings]}

if [[ $dock ]]; then
  update_macos_dock
fi

if [[ $settings ]]; then
  seek_confirmation "This will override your macOS settings"
  if is_confirmed; then
    update_macos_settings
  fi
fi
