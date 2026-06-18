# Topic Filter Example — Namespace Isolation

This example demonstrates how to configure Kong Event Gateway with multiple virtual clusters, each with isolated topic namespaces using prefix-based filtering.

> **Note:** This example uses a kongctl configuration at
> [`kongctl/config.yaml`](kongctl/config.yaml).

## What It Does

- Two virtual clusters with namespace prefix isolation
- **team-a** (ports 19192-19290): prefix `A.` — clients see unprefixed topics
- **team-b** (ports 19292-19390): prefix `B.` — clients see unprefixed topics
- Shared topics (`nw.*`) injected into both views
- Transparent prefix handling for clients

## How to Use

```bash
# Apply the phase configuration:
kongctl apply -f kongctl/config.yaml

# Test Team A through the gateway:
kafkactl config use-context team-a
kafkactl get topics

# Test Team B through the gateway:
kafkactl config use-context team-b
kafkactl get topics
```

## Configuration Details

The phase-2 configuration uses the `namespace` block with `hide_prefix` mode:

```yaml
virtual_clusters:
  - ref: team-a
    namespace:
      mode: hide_prefix
      prefix: "A."
      additional:
        topics:
          - type: glob
            glob: "nw.*"
    authentication:
      - type: anonymous
```

### How Namespace Isolation Works

- Topics on the broker are stored with the prefix (e.g., `A.orders.v1`)
- Clients connecting through team-a's listener port (19192-19290) see `orders.v1`
- The prefix is automatically stripped on consume and added on produce
- `additional.topics` injects shared topics (like `nw.*`) into each team's view

### Port Allocation

| Virtual Cluster | Listener Ports | Min Broker ID |
|----------------|---------------|---------------|
| core-proxy     | 19092-19190   | 0             |
| team-a         | 19192-19290   | 0             |
| team-b         | 19292-19390   | 0             |

## Testing

```bash
# Create topics directly in Kafka:
kafkactl config use-context default
kafkactl create topic A.orders.v1 B.inventory.v1 A.payments.v1

# Team A sees only their topics (without prefix):
kafkactl config use-context team-a
kafkactl get topics  # Shows: orders.v1, payments.v1

# Team B sees only their topics (without prefix):
kafkactl config use-context team-b
kafkactl get topics  # Shows: inventory.v1
```

## Lifecycle

This configuration builds on the Basic Proxy example. To move to auth mediation:

```bash
kongctl apply -f ../04-auth-mediation/kongctl/config.yaml
```

## See Also

- [Basic Proxy](../01-basic-proxy/kongctl/config.yaml)
- [Auth Mediation](../04-auth-mediation/kongctl/config.yaml)
- [ACL Enforcement](../05-acl-enforcement/kongctl/config.yaml)
- [Encryption](../06-encryption/kongctl/config.yaml)
- [Schema Validation](../07-schema-validation/kongctl/config.yaml)
- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
