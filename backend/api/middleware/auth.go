package middleware

import (
	"context"
	"fmt"
	"os"

	"github.com/lestrrat-go/httprc/v3"
	"github.com/lestrrat-go/jwx/v3/jwk"
)

var jwksCache *jwk.Cache

func InitJWKS(ctx context.Context) error {
	// Step 1 - Get the Supabase JWKS URL
	jwksURL := os.Getenv("SUPABASE_JWKS_URL")
	if jwksURL == "" {
		return fmt.Errorf("SUPABASE_JWKS_URL is not set")
	}

	// Step 2 - Create auto-refreshing JWKS cache
	cache, err := jwk.NewCache(ctx, httprc.NewClient())
	if err != nil {
		return fmt.Errorf("Error while creating auto-refreshing JWKS cache: %v", err.Error())
	}

	// Step 3 - Register the Supabase JWKS URL to the cache
	if err := cache.Register(ctx, jwksURL); err != nil {
		return fmt.Errorf("Failed to register the Supabase JWKS URL to the cache: %v", err.Error())
	}

	// Step. 4 - Initial refresh to ensure everything works
	if _, err := cache.Refresh(ctx, jwksURL); err != nil {
		return fmt.Errorf("Failed to fetch JWKS: %v", err.Error())
	}

	jwksCache = cache

	return nil
}
