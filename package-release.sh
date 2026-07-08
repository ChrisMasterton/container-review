#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$script_dir"
cd "$repo_dir"

version="${1:-${CONTAINER_REVIEW_VERSION:-}}"
if [[ -z "$version" ]]; then
    version="$(< "${repo_dir}/VERSION")"
fi
version="${version#v}"
if [[ -z "$version" ]]; then
    echo "Release version is required." >&2
    exit 1
fi

app_name="Container Review"
app_dir=".build/${app_name}.app"
dist_dir="dist"
zip_name="ContainerReview-${version}-macOS.zip"
checksum_name="${zip_name}.sha256"

./scripts/build-app.sh "$version"

mkdir -p "$dist_dir"
rm -f "${dist_dir}/${zip_name}" "${dist_dir}/${checksum_name}"

ditto -c -k --keepParent --norsrc --noextattr "$app_dir" "${dist_dir}/${zip_name}"

(
    cd "$dist_dir"
    shasum -a 256 "$zip_name" > "$checksum_name"
)

echo "Packaged ${dist_dir}/${zip_name}"
echo "Wrote ${dist_dir}/${checksum_name}"
