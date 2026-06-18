# ACL Enforcement Example

This example demonstrates how to enforce ACLs at the Kong Event Gateway, controlling which operations authenticated clients can perform on Kafka topics and consumer groups.

> **Note:** This example uses a kongctl configuration at
> [`kongctl/config.yaml`](kongctl/config.yaml).

## What It Does

- Switches Team B's ACL mode from `passthrough` to `enforce_on_gateway`
- Defines two-tier ACL rules: read-only for anonymous, full access for authenticated users
- Unauthenticated requests to Team B are now rejected at the gateway
- Team A stays in `passthrough` mode to show the contrast

## How to Use

```bash
# Apply the phase configuration:
kongctl apply -f kongctl/config.yaml

# Test authenticated access to Team B (explicitly allowed):
kafkactl config use-context team-b-authed
kafkactl get topics

# Test unauthenticated access to Team B (will be rejected):
kafkactl config use-context team-b
kafkactl get topics  # Should fail
```

## Configuration Details

The phase-5 configuration adds ACL enforcement to Team B:

```yaml
virtual_clusters:
  - ref: team-b
    acl_mode: enforce_on_gateway

    cluster_policies:
      - ref: acl-team-b-readonly
        type: acls
        condition: "context.auth.principal.name != 'team-b-user'"
        config:
          rules:
            - action: allow
              resource_type: topic
              operations:
                - name: describe
                - name: read
              resource_names:
                - match: "*"
            - action: allow
              resource_type: group
              operations:
                - name: read
              resource_names:
                - match: "*"

      - ref: acl-team-b-fullaccess
        type: acls
        condition: "context.auth.principal.name == 'team-b-user'"
        config:
          rules:
            - action: allow
              resource_type: topic
              operations:
                - name: describe
                - name: read
                - name: write
              resource_names:
                - match: "*"
            - action: allow
              resource_type: group
              operations:
                - name: describe
                - name: read
                - name: write
                - name: create
              resource_names:
                - match: "*"
```

### ACL Modes

- **passthrough**: Gateway forwards ACL checks to Kafka — any authenticated client can do anything
- **enforce_on_gateway**: Gateway enforces ACL rules defined in `cluster_policies` — unlisted operations are denied

### How ACLs Affect User Behavior

| User | Auth | ACL Mode | Behavior |
|------|------|----------|----------|
| Team A | Anonymous | `passthrough` | Full access to `A.*` topics — no ACL enforcement |
| Team B (authed) | SASL/PLAIN | `enforce_on_gateway` | Full access (describe, read, write) |
| Team B (unauth) | None | `enforce_on_gateway` | Read-only (describe, read) — no write allowed |
| Team B (authed, restricted) | SASL/PLAIN | `enforce_on_gateway` | Denied if operation is not in the allow rules |

## Testing

```bash
# Team B with SASL/PLAIN auth (will succeed):
kafkactl config use-context team-b-authed
kafkactl get topics
kafkactl produce B.test.topic --value='hello'

# Team B without auth (read-only — can list topics but not write):
kafkactl config use-context team-b
kafkactl get topics

# Team B without auth trying to write (will be denied):
kafkactl produce B.test.topic --value='hello'  # Should fail — write not allowed for anonymous

# Team A still works without auth (passthrough mode):
kafkactl config use-context team-a
kafkactl get topics
```

## Lifecycle

Phase 5 builds on Phase 4. To move to Phase 6 (encryption):

```bash
export TRANSACTION_ENCRYPTION_KEY=$(openssl rand -base64 32)
kongctl apply -f ../06-encryption/kongctl/config.yaml
```

## See Also

- [Auth Mediation](../04-auth-mediation/kongctl/config.yaml)
- [Encryption](../06-encryption/kongctl/config.yaml)
- [Schema Validation](../07-schema-validation/kongctl/config.yaml)
- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
