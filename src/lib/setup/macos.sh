update_macos_settings() {
  header "Updating macOS settings..."
  bash "${DOTFILES_DIRECTORY}/lib/osxdefaults"
}

update_macos_dock() {
  header "Updating macOS dock applications..."
  dockutil --remove all
  for app in "${MACOS_DOCK_APPLICATIONS[@]}"; do
    dockutil --add "$app" --section apps
  done

  dockutil \
    --add "${HOME}/Downloads" \
    --view grid \
    --display folder \
    --sort dateadded \
    --section others
}
