#!/bin/bash

set -e

echo "📝 Creating systemd unit file..."
sudo tee /etc/systemd/system/caddy.service > /dev/null <<EOF
[Unit]
Description=Caddy web server with automatic HTTPS
Documentation=https://caddyserver.com/docs/
After=network.target

[Service]
User=tapasvi
Group=tapasvi
ExecStart=/usr/local/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/local/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

echo "📁 Creating config and log directories..."
sudo mkdir -p /etc/caddy /var/log/caddy
sudo touch /etc/caddy/Caddyfile
sudo chown -R tapasvi:tapasvi /etc/caddy /var/log/caddy

echo "🔁 Reloading systemd and enabling Caddy service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable caddy
sudo systemctl start caddy

echo "✅ Caddy systemd service is now active:"
systemctl status caddy --no-pager