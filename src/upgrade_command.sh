# shellcheck disable=SC2154
package="${args[package]}"
ref="${args[--ref]}"
handler="upgrade_$package"

if function_exists "$handler"; then
  $handler "$ref"
else
  error "Invalid package: $package"
  exit 1
fi
