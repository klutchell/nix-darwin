#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_FILE="$SCRIPT_DIR/../pkgs/balena-cli.nix"

if [[ ! -f "$PKG_FILE" ]]; then
  echo "error: $PKG_FILE not found" >&2
  exit 1
fi

old_version=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')
echo "Current version: $old_version"

echo "Fetching latest release from GitHub..."
tag=$(curl -sf https://api.github.com/repos/balena-io/balena-cli/releases/latest | jq -r .tag_name)
new_version="${tag#v}"
echo "Latest version:  $new_version"

if [[ "$old_version" == "$new_version" ]]; then
  echo "Already up to date."
  exit 0
fi

url="https://github.com/balena-io/balena-cli/releases/download/v${new_version}/balena-cli-v${new_version}-macOS-arm64-standalone.tar.gz"

echo "Prefetching $url ..."
new_hash=$(nix-prefetch-url --unpack "$url" 2>/dev/null)
new_sri=$(nix hash to-sri --type sha256 "$new_hash")

echo "New SRI hash: $new_sri"

sed -i "s|version = \"$old_version\"|version = \"$new_version\"|" "$PKG_FILE"
sed -i "s|sha256 = \"sha256-.*\"|sha256 = \"$new_sri\"|" "$PKG_FILE"

echo ""
echo "Updated $PKG_FILE: $old_version -> $new_version"
