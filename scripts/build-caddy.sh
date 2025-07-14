#!/bin/bash

set -e
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

echo "🧹 Cleaning Go module cache and previous build..."
go clean -modcache
rm -rf /root/caddy-build /root/go/pkg/mod/github.com/tapasvisehgal/caddy-dns-godaddy-patched

echo "📦 Installing xcaddy if not already installed..."
if ! command -v xcaddy &> /dev/null; then
  echo "⬇️ Installing xcaddy..."
  go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
fi

echo "📁 Creating fresh build directory..."
mkdir -p /root/caddy-build
cd /root/caddy-build

echo "🔨 Building Caddy v2.7.6 with patched GoDaddy plugin from GitHub..."
xcaddy build v2.7.6 \
  --output ./caddy \
  --with github.com/tapasvisehgal/caddy-dns-godaddy-patched@main

echo "✅ Done! Caddy binary is ready at /root/caddy-build/caddy"
./caddy version