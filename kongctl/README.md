# Kongctl Assets

This folder contains Kong Konnect control-plane resources used by the repository bootstrap.

## Files

- `data_plane_certificate.yaml`: Registers the gateway data-plane certificate object in Konnect.
- `certs/tls.crt`: Local certificate used by the data plane for Konnect mTLS.
- `certs/key.crt`: Private key paired with `tls.crt`.

## How It Is Used

1. Generate a certificate/key pair into `certs/`.
2. Apply `data_plane_certificate.yaml` with `kongctl`.
3. Append certificate and key values into `konnect.env`.

Detailed bootstrap commands are documented in the root [README](../README.md).

## Security Notes

- Do not commit private keys from `certs/`.
- Rotate certificates if they are shared or exposed.