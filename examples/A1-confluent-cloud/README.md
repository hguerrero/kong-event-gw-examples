# Confluent Cloud Integration Example

This example demonstrates how to configure Kong Event Gateway to connect to a Confluent Cloud Kafka cluster using SASL/PLAIN authentication and TLS encryption.

> **Note:** This example uses a kongctl configuration at
> [`kongctl/config.yaml`](kongctl/config.yaml).

## What It Does

- Secure connection to Confluent Cloud with SASL/PLAIN authentication
- TLS encryption for data in transit
- Anonymous mediation — credentials stay at the gateway
- Alternative backend to the local Kafka cluster

## How to Use

```bash
# 1. Set your Confluent Cloud credentials:
export KAFKA_USERNAME=<your-confluent-cloud-api-key>
export KAFKA_PASSWORD=<your-confluent-cloud-api-secret>

# 2. Update bootstrap_servers in kongctl/variant-confluent-cloud.yaml
#    with your Confluent Cloud endpoint

# 3. Apply the variant configuration (replaces any phase config):
kongctl apply -f kongctl/config.yaml

# 4. Test the connection:
kafkactl get topics --bootstrap-server localhost:9092
```

## Configuration Details

The variant configuration defines:

```yaml
backend_clusters:
  - ref: confluent-cloud
    authentication:
      type: sasl_plain
      sasl_plain:
        username: !env KAFKA_USERNAME
        password: !env KAFKA_PASSWORD
    bootstrap_servers:
      - <your-bootstrap-server>:9092
    tls:
      enabled: true
      insecure_skip_verify: true

virtual_clusters:
  - ref: confluent-proxy
    authentication:
      - type: anonymous
        mediation: use_backend_cluster
```

### Authentication Modes

- **Anonymous mediation** (`use_backend_cluster`): Clients connect without credentials; gateway uses its own Confluent Cloud credentials to connect to the backend
- **Credential forwarding** (`forward`): Clients provide SASL/PLAIN credentials that are forwarded to Confluent Cloud

## Variant vs Phase

Variants are **alternative** configurations, not cumulative phases. Apply a variant
instead of the phase files to use a different backend. The variant replaces the entire
configuration on the gateway.

## See Also

- [Redpanda variant](../A2-redpanda/kongctl/config.yaml)
- [Basic Proxy](../01-basic-proxy/kongctl/config.yaml)
- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
- [Confluent Cloud Documentation](https://docs.confluent.io/cloud/current/overview.html)
