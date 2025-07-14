#!/bin/bash

# Always add Go binary paths explicitly (useful when running with sudo -E)
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

set -e

echo "🧹 Cleaning old build environment..."
rm -rf /root/caddy-build "$HOME/caddy"
go clean -modcache

echo "📦 Installing xcaddy if not already installed..."
if ! command -v xcaddy &> /dev/null; then
    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
    export PATH="$PATH:$(go env GOPATH)/bin"
fi

echo "🔨 Building Caddy v2.7.6 with your patched GoDaddy plugin..."
mkdir -p /root/caddy-build
cd /root/caddy-build

go get -u github.com/tapasvisehgal/caddy-dns-godaddy-patched@main

# Use pinned Caddy version to prevent v2.10.0 conflict
xcaddy build v2.7.6 \
  --output ./caddy \
  --with github.com/tapasvisehgal/caddy-dns-godaddy-patched@main

echo "✅ Caddy built successfully at /root/caddy-build/caddy"