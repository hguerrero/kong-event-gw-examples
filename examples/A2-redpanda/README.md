# Redpanda Integration Example

This example demonstrates how to configure Kong Event Gateway to connect to a Redpanda cluster as the backend.

> **Note:** This example uses a kongctl configuration at
> [`kongctl/config.yaml`](kongctl/config.yaml).

## What It Does

- Replaces the local Kafka cluster with a Redpanda backend
- Anonymous authentication to Redpanda
- Flat passthrough virtual cluster
- Alternative backend for testing with Redpanda

## How to Use

```bash
# 1. Start Redpanda (separately, or use a Redpanda docker-compose)

# 2. Apply the variant configuration (replaces any phase config):
kongctl apply -f kongctl/config.yaml

# 3. Test the connection:
kafkactl get topics --bootstrap-server localhost:9192
```

## Configuration Details

The variant configuration defines:

```yaml
backend_clusters:
  - ref: redpanda-local
    authentication:
      type: anonymous
    bootstrap_servers:
      - redpanda-0:9092
    tls:
      enabled: false

virtual_clusters:
  - ref: redpanda-proxy
    authentication:
      - type: anonymous
```

## Variant vs Phase

Variants are **alternative** configurations, not cumulative phases. Apply a variant
instead of the phase files to use a different backend platform.

## See Also

- [Confluent Cloud variant](../A1-confluent-cloud/kongctl/config.yaml)
- [Basic Proxy](../01-basic-proxy/kongctl/config.yaml)
- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
- [Redpanda Documentation](https://docs.redpanda.com/)
