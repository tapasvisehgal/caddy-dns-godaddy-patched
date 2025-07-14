#!/bin/bash
set -e

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

echo "🧹 Cleaning old build environment..."
rm -rf /root/caddy-build /root/go/pkg/mod/github.com/tapasvisehgal /home/$(whoami)/caddy
go clean -modcache

echo "📦 Installing xcaddy if not already installed..."
if ! command -v xcaddy &> /dev/null; then
    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
fi

echo "🔨 Building Caddy v2.7.6 with your patched GoDaddy plugin..."
mkdir -p /root/caddy-build
cd /root/caddy-build

xcaddy build v2.7.6 --output ./caddy \
  --with github.com/tapasvisehgal/caddy-dns-godaddy-patched@main

echo "✅ Caddy built successfully at /root/caddy-build/caddy"