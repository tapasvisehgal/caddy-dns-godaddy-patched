#!/bin/bash
set -e

echo "📦 Cloning patched GoDaddy DNS plugin..."
cd ~
rm -rf godaddy
git clone https://github.com/tapasvisehgal/caddy-dns-godaddy-patched.git godaddy

echo "🔧 Fixing go.mod module name..."
sed -i 's|^module .*|module github.com/caddy-dns/godaddy|' godaddy/go.mod
cd godaddy
go mod tidy

echo "🚧 Building Caddy with local GoDaddy plugin..."
cd ~
xcaddy build --with github.com/caddy-dns/godaddy=./godaddy

echo "🚀 Installing Caddy binary..."
sudo mv ./caddy /usr/bin/caddy
sudo chmod +x /usr/bin/caddy

echo "✅ Done! Caddy is built and installed with GoDaddy DNS plugin (wildcard SSL ready)."