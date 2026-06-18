# Basic Kafka Proxy Example

This example demonstrates the basic proxy functionality of Kong Event Gateway — putting a transparent gateway in front of Kafka without touching any broker configuration.

> **Note:** This example uses a kongctl configuration at
> [`kongctl/config.yaml`](kongctl/config.yaml).

## What It Does

- Registers a 3-broker Kafka cluster as a backend in Konnect
- Creates a flat passthrough virtual cluster
- Exposes Kafka on ports 19092-19190 with anonymous authentication
- Gateway acts as a transparent proxy — no namespace isolation, no auth, no policies

## How to Use

```bash
# Prerequisites: Kafka running, cert registered, konnect.env configured
# See root README for bootstrap instructions.

# Apply the phase configuration:
kongctl apply -f kongctl/config.yaml

# Test with kafkactl:
kafkactl config use-context core-proxy
kafkactl get topics
kafkactl create topic hello-world
kafkactl produce hello-world --value="Hello via KEG!"
kafkactl consume hello-world --from-beginning --exit
```

## Configuration Details

The configuration in `phase-1-basic-proxy.yaml` defines:

- **Backend cluster**: Points to the 3 Kafka brokers (kafka1:9092, kafka2:9092, kafka3:9092)
- **Listener**: Port range 19092-19190, with a `forward_to_virtual_cluster` policy
- **Virtual cluster**: Flat passthrough (`acl_mode: passthrough`), anonymous authentication

## Key Concepts

- **Backend Cluster**: Defines the upstream Kafka brokers the gateway connects to
- **Listener**: A port or port range that clients connect to
- **Virtual Cluster**: A tenant/domain isolation unit that maps clients to a backend
- **Port Mapping**: Routes traffic from a listener port range to a specific virtual cluster

## Testing

Using kafkactl, you can test both direct and proxied connections:

```bash
# Direct connection to Kafka:
kafkactl config use-context default
kafkactl get topics

# Connection through gateway proxy:
kafkactl config use-context core-proxy
kafkactl get topics
```

Both should show the same topics — the gateway is transparent.

## Lifecycle

When you move to the next phase, apply the new phase file — it replaces the entire configuration:

```bash
kongctl apply -f ../03-topic-filter/kongctl/config.yaml
```

## Next Steps

After mastering this basic setup, explore:
- [Topic Filter](../03-topic-filter/kongctl/config.yaml) — namespace isolation  
- [Auth Mediation](../04-auth-mediation/kongctl/config.yaml) — SASL/PLAIN authentication  
- [Encryption](../05-encryption/kongctl/config.yaml) — message-level encryption  
- [Schema Validation](../06-schema-validation/kongctl/config.yaml) — schema enforcement

## See Also

- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
- [kongctl CLI Reference](https://konghq.com/products/kong-konnect/event-gateway)
