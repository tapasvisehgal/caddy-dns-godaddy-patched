package godaddy

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/libdns/libdns"
	"github.com/caddyserver/caddy/v2"
)

type Provider struct {
	APIKey    string `json:"api_key,omitempty"`
	APISecret string `json:"api_secret,omitempty"`
}

// Implement libdns.Provider interface
var _ libdns.Provider = (*Provider)(nil)

func (p *Provider) client() *http.Client {
	return &http.Client{Timeout: 30 * time.Second}
}

func (p *Provider) setHeaders(req *http.Request) {
	auth := fmt.Sprintf("sso-key %s:%s", p.APIKey, p.APISecret)
	req.Header.Set("Authorization", auth)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
}

func (p *Provider) AppendRecords(ctx context.Context, zone string, records []libdns.Record) ([]libdns.Record, error) {
	zone = strings.TrimSuffix(zone, ".")

	for _, record := range records {
		url := fmt.Sprintf("https://api.godaddy.com/v1/domains/%s/records/%s/%s", zone, record.Type, record.Name)
		body := fmt.Sprintf(`[{"data":"%s","ttl":%d}]`, record.Value, int(record.TTL.Seconds()))

		req, err := http.NewRequestWithContext(ctx, "PUT", url, strings.NewReader(body))
		if err != nil {
			return nil, err
		}

		p.setHeaders(req)

		resp, err := p.client().Do(req)
		if err != nil {
			return nil, err
		}
		defer resp.Body.Close()

		if resp.StatusCode >= 400 {
			return nil, fmt.Errorf("GoDaddy API error (append): %s", resp.Status)
		}
	}

	return records, nil
}

func (p *Provider) DeleteRecords(ctx context.Context, zone string, records []libdns.Record) ([]libdns.Record, error) {
	zone = strings.TrimSuffix(zone, ".")

	for _, record := range records {
		url := fmt.Sprintf("https://api.godaddy.com/v1/domains/%s/records/%s/%s", zone, record.Type, record.Name)

		req, err := http.NewRequestWithContext(ctx, "DELETE", url, nil)
		if err != nil {
			return nil, err
		}

		p.setHeaders(req)

		resp, err := p.client().Do(req)
		if err != nil {
			return nil, err
		}
		defer resp.Body.Close()

		if resp.StatusCode >= 400 {
			return nil, fmt.Errorf("GoDaddy API error (delete): %s", resp.Status)
		}
	}

	return records, nil
}

func (p *Provider) GetRecords(ctx context.Context, zone string) ([]libdns.Record, error) {
	return nil, errors.New("not implemented")
}

//
// 🔧 Caddy plugin registration block (auto-detects newer module system)
//
func init() {
	// Attempt to register if using Caddy module system
	// (Will only work if caddy.RegisterModule is available in the build)
	defer func() {
		if r := recover(); r != nil {
			// likely older caddy build, ignore
		}
	}()

	caddy.RegisterModule(Provider{})
}

// CaddyModule exposes module name for DNS plugin system
func (Provider) CaddyModule() caddy.ModuleInfo {
	return caddy.ModuleInfo{
		ID:  "dns.providers.godaddy",
		New: func() caddy.Module { return new(Provider) },
	}
}