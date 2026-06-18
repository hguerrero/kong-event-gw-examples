# Authentication Mediation Example

This example demonstrates how to configure Kong Event Gateway with SASL/PLAIN authentication, where credentials are terminated at the gateway and never forwarded to Kafka.

> **Note:** This example uses a kongctl configuration at
> [`kongctl/config.yaml`](kongctl/config.yaml).

## What It Does

- SASL/PLAIN authentication for Team B with `mediation: terminate`
- Team A stays anonymous (network-level access)
- Credentials are validated at the gateway — Kafka never sees them
- Gateway handles auth so Kafka can remain in anonymous mode

## How to Use

```bash
# Apply the phase configuration:
kongctl apply -f kongctl/config.yaml

# Test authenticated access to Team B:
kafkactl config use-context team-b-authed
kafkactl get topics

# Test anonymous access (still works for Team A):
kafkactl config use-context team-a
kafkactl get topics
```

## Configuration Details

The phase-3 configuration adds SASL/PLAIN to Team B:

```yaml
virtual_clusters:
  - ref: team-b
    authentication:
      - type: anonymous
      - type: sasl_plain
        mediation: terminate
        principals:
          - username: team-b-user
            password: secret
```

### Auth Mediation Modes

- **terminate**: Gateway validates credentials, then connects to Kafka anonymously
- **forward**: Gateway forwards credentials to Kafka for backend validation
- **use_backend_cluster**: Gateway uses the backend cluster's authentication

## Testing

```bash
# Team B with SASL/PLAIN auth:
kafkactl config use-context team-b-authed
kafkactl get topics

# Team B without auth (will fail if auth is required):
kafkactl config use-context team-b
kafkactl get topics  # May fail depending on acl_mode

# Team A stays anonymous:
kafkactl config use-context team-a
kafkactl get topics
```

## Lifecycle

Phase 3 builds on Phase 2. To move to Phase 4 (encryption):

```bash
kongctl apply -f ../05-encryption/kongctl/config.yaml
```

## See Also

- [Topic Filter](../03-topic-filter/kongctl/config.yaml)
- [Encryption](../05-encryption/kongctl/config.yaml)
- [Schema Validation](../06-schema-validation/kongctl/config.yaml)
- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
