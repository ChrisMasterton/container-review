#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "${script_dir}/.." && pwd)"

app_name="Container Review"
app_dir="${repo_dir}/.build/${app_name}.app"
install_dir="${INSTALL_DIR:-/Applications}"
target_app="${install_dir}/${app_name}.app"

"${script_dir}/build-app.sh"

if [[ ! -d "$app_dir" ]]; then
    echo "Expected app bundle was not built: ${app_dir}" >&2
    exit 1
fi

copy_app() {
    rm -rf "$target_app"
    ditto "$app_dir" "$target_app"
}

if [[ ! -d "$install_dir" ]]; then
    mkdir -p "$install_dir"
fi

if [[ -w "$install_dir" ]]; then
    copy_app
else
    sudo rm -rf "$target_app"
    sudo ditto "$app_dir" "$target_app"
fi

echo "Installed ${target_app}"
