package godaddy

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/libdns/libdns"
)

// Provider facilitates DNS record management with GoDaddy.
type Provider struct {
	APIKey    string `json:"api_key"`
	APISecret string `json:"api_secret"`
}

func (p *Provider) client() *http.Client {
	return &http.Client{Timeout: 30 * time.Second}
}

func (p *Provider) setHeaders(req *http.Request) {
	req.Header.Set("Authorization", fmt.Sprintf("sso-key %s:%s", p.APIKey, p.APISecret))
	req.Header.Set("Content-Type", "application/json")
}

func (p *Provider) AppendRecords(ctx context.Context, zone string, records []libdns.Record) ([]libdns.Record, error) {
	for _, record := range records {
		if record.Type != "TXT" {
			return nil, fmt.Errorf("only TXT records are supported")
		}

		name := record.Name // safe fallback; Name is populated during Append
		if name == "" {
			name = "@"
		}

		url := fmt.Sprintf("https://api.godaddy.com/v1/domains/%s/records/TXT/%s", zone, name)
		body := fmt.Sprintf(`[{"data":"%s","ttl":600}]`, record.Value)

		req, err := http.NewRequestWithContext(ctx, http.MethodPut, url, strings.NewReader(body))
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
			return nil, fmt.Errorf("GoDaddy API error: %s", resp.Status)
		}
	}

	return records, nil
}

func (p *Provider) DeleteRecords(ctx context.Context, zone string, records []libdns.Record) ([]libdns.Record, error) {
	for _, record := range records {
		name := record.Name
		if name == "" {
			name = "@"
		}

		url := fmt.Sprintf("https://api.godaddy.com/v1/domains/%s/records/TXT/%s", zone, name)

		req, err := http.NewRequestWithContext(ctx, http.MethodDelete, url, nil)
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
	return nil, errors.New("GetRecords is not implemented (not needed for ACME)")
}