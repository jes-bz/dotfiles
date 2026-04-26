#!/usr/bin/env bash
set -e

cd ~/.config/nix/npm-packages
echo "Running npm install..."
npm install

echo "Prefetching hash..."
HASH=$(nix run nixpkgs#prefetch-npm-deps -- package-lock.json)
echo "New hash: $HASH"

echo "Updating flake.nix..."
sed -i "s|npmDepsHash = \".*\";|npmDepsHash = \"$HASH\";|" ../flake.nix

echo "Done! You can now run 'nix run' or apply your configuration."
