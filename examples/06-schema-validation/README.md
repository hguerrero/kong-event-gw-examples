# Schema Validation Example

This example demonstrates how to configure Kong Event Gateway to enforce schema validation on Kafka messages using Apicurio Schema Registry.

> **Note:** This example uses a kongctl configuration at
> [`kongctl/config.yaml`](kongctl/config.yaml).

## What It Does

- Registers Apicurio Schema Registry (Confluent-compatible mode) in the gateway
- Enforces JSON schema validation on fraud risk score topics
- Rejects non-conformant produce requests before they reach the broker
- Enables ACL enforcement on Team B for fine-grained access control

## How to Use

```bash
# Ensure encryption key is set (carried over from Phase 4):
export TRANSACTION_ENCRYPTION_KEY=$(openssl rand -base64 32)

# Apply the phase configuration:
kongctl apply -f kongctl/config.yaml

# Produce valid message through Team B:
kafkactl config use-context team-b-authed
kafkactl produce B.infosec.security.fraud.risk-scores.v3 \
  --value='{"score":0.85,"account_id":"NW-001234","reason":"velocity_spike","evaluated_at":"2025-01-15T10:30:00Z"}'

# Produce invalid message (will be rejected):
kafkactl produce B.infosec.security.fraud.risk-scores.v3 \
  --value='{"invalid":"data"}'
```

## Configuration Details

The phase-5 configuration adds schema validation to Team B:

```yaml
schema_registries:
  - ref: apicurio-schema-registry
    type: confluent
    config:
      schema_type: json
      endpoint: http://apicurio-registry:8080/apis/ccompat/v7
      timeout_seconds: 8

virtual_clusters:
  - ref: team-b
    acl_mode: enforce_on_gateway
    produce_policies:
      - ref: fraud-risk-schema-validation
        type: schema_validation
        condition: "context.topic.name == 'B.infosec.security.fraud.risk-scores.v3'"
        config:
          type: confluent_schema_registry
          schema_registry:
            id: !ref apicurio-schema-registry
          value_validation_action: reject
```

### Schema Registration

The fraud risk score schema is registered at topic creation via the Kafka init container.
It uses JSON Schema (draft-07) and is stored in `kafka/config/schemas/fraud_risk_scores.json`.

## Testing

```bash
# Valid fraud risk score event (will succeed):
kafkactl produce B.infosec.security.fraud.risk-scores.v3 \
  --value='{"score":0.42,"account_id":"NW-005678","reason":"geo_anomaly","evaluated_at":"2025-01-15T14:00:00Z"}'

# Invalid — missing required field "score":
kafkactl produce B.infosec.security.fraud.risk-scores.v3 \
  --value='{"account_id":"NW-005678","reason":"geo_anomaly","evaluated_at":"2025-01-15T14:00:00Z"}'

# Invalid — score out of range:
kafkactl produce B.infosec.security.fraud.risk-scores.v3 \
  --value='{"score":1.5,"account_id":"NW-005678","reason":"geo_anomaly","evaluated_at":"2025-01-15T14:00:00Z"}'
```

## See Also

- [Encryption](../05-encryption/kongctl/config.yaml)
- [Kafka schema definitions](../../kafka/config/schemas/)
- [Apicurio Registry Documentation](https://www.apicur.io/registry/)
- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
