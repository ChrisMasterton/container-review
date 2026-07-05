#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

version="${1:-0.1.0}"
version="${version#v}"

app_name="Container Review"
app_dir=".build/${app_name}.app"
dist_dir="dist"
zip_name="ContainerReview-${version}-macOS.zip"
checksum_name="${zip_name}.sha256"

./build-app.sh

mkdir -p "$dist_dir"
rm -f "${dist_dir}/${zip_name}" "${dist_dir}/${checksum_name}"

ditto -c -k --keepParent --norsrc --noextattr "$app_dir" "${dist_dir}/${zip_name}"

(
    cd "$dist_dir"
    shasum -a 256 "$zip_name" > "$checksum_name"
)

echo "Packaged ${dist_dir}/${zip_name}"
echo "Wrote ${dist_dir}/${checksum_name}"
