#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "${script_dir}/.." && pwd)"
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

swift build -c release

app_name="Container Review"
app_dir=".build/${app_name}.app"
contents_dir="${app_dir}/Contents"
macos_dir="${contents_dir}/MacOS"
resources_dir="${contents_dir}/Resources"
iconset_dir=".build/AppIcon.iconset"

rm -rf "$app_dir"
mkdir -p "$macos_dir" "$resources_dir"

cp ".build/release/ContainerReview" "${macos_dir}/ContainerReview"
rm -rf "$iconset_dir"
swift Tools/generate-app-icon.swift "$iconset_dir"
iconutil -c icns "$iconset_dir" -o "${resources_dir}/AppIcon.icns"

cat > "${contents_dir}/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ContainerReview</string>
    <key>CFBundleIdentifier</key>
    <string>local.container-review</string>
    <key>CFBundleName</key>
    <string>Container Review</string>
    <key>CFBundleDisplayName</key>
    <string>Container Review</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${version}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSRemovableVolumesUsageDescription</key>
    <string>Container Review runs the local Docker CLI to list containers; Docker or Colima may need access to mounted paths used by your containers.</string>
</dict>
</plist>
PLIST

echo "Built ${app_dir}"
