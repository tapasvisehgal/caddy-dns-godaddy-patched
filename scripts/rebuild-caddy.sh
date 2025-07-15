#!/bin/bash
set -e
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

echo "🧹 Cleaning..."
go clean -modcache
rm -rf "$HOME/go/pkg/mod/github.com/tapasvisehgal"
rm -rf "$HOME/caddy-build"

echo "📦 Installing xcaddy..."
if ! command -v xcaddy &> /dev/null; then
  go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
fi

echo "🔨 Building Caddy with GoDaddy plugin..."
mkdir -p "$HOME/caddy-build"
cd "$HOME/caddy-build"
xcaddy build v2.7.6 \
  --output "$HOME/caddy-build/caddy" \
  --with github.com/tapasvisehgal/caddy-dns-godaddy-patched@latest

echo "📦 Installing Caddy..."
sudo cp "$HOME/caddy-build/caddy" /usr/local/bin/caddy
sudo chown root:root /usr/local/bin/caddy
sudo chmod 755 /usr/local/bin/caddy

echo "🔁 Restarting Caddy..."
sudo systemctl restart caddy

echo "✅ Done!"