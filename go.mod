module github.com/tapasvisehgal/caddy-dns-godaddy-patched

go 1.18

require (
    github.com/caddyserver/caddy/v2 v2.7.6 // or the latest
    github.com/libdns/libdns v0.2.1
)

replace github.com/libdns/libdns => github.com/libdns/libdns v0.2.1