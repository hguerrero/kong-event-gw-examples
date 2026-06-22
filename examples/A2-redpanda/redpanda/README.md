# Redpanda Runtime Assets

This folder contains local Redpanda runtime and helper assets used by the A2 backend variant.

## Purpose

- Launches a local Redpanda broker for gateway backend testing.
- Provides profile/bootstrap artifacts and sample transaction schema resources.
- Includes a transform submodule with its own documentation.

## Files

- `docker-compose.yml`: Starts Redpanda locally.
- `bootstrap.yml`: Redpanda bootstrap/runtime settings.
- `generate-profiles.yaml`: Helper definitions for profile generation.
- `rpk-profile.yaml`: `rpk` profile configuration.
- `transactions-schema.json`: Example transaction schema payload.
- `transactions.md`: Notes for transaction data/schema flow.
- `transform/`: Transform module and docs; see [transform/README.adoc](transform/README.adoc).

## Usage

From the repository root:

```bash
docker compose -f examples/A2-redpanda/redpanda/docker-compose.yml up -d
kongctl apply -f examples/A2-redpanda/kongctl/config.yaml
```

For full variant context, see [../README.md](../README.md).