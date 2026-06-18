# Message-Level Encryption Example

This example demonstrates how to configure Kong Event Gateway for automatic message encryption and decryption using symmetric key encryption.

> **Note:** This example uses a kongctl configuration at
> [`kongctl/config.yaml`](kongctl/config.yaml).

## What It Does

- Automatic encryption of message values during produce
- Automatic decryption of message values during consume
- Static encryption key loaded from environment variable
- Transparent encryption/decryption — clients don't handle crypto
- No changes required to producers or consumers

## How to Use

```bash
# Generate an encryption key:
export TRANSACTION_ENCRYPTION_KEY=$(openssl rand -base64 32)

# Apply the phase configuration:
kongctl apply -f kongctl/config.yaml

# Test producing through the gateway (encrypted):
kafkactl config use-context core-proxy
kafkactl produce nw.ledger.transactions.high-value-wire-transfers.v1 \
  --value='{"transaction_id":"tx-001","amount":500000}'

# Consume through the gateway (decrypted):
kafkactl consume nw.ledger.transactions.high-value-wire-transfers.v1 \
  --from-beginning --exit

# Consume directly from Kafka (encrypted — unreadable):
kafkactl config use-context default
kafkactl consume nw.ledger.transactions.high-value-wire-transfers.v1 \
  --from-beginning --exit --print-headers
```

## Configuration Details

The phase-6 configuration adds:

```yaml
static_keys:
  - ref: transaction-encryption-key
    value: !env TRANSACTION_ENCRYPTION_KEY

virtual_clusters:
  - ref: core-proxy
    produce_policies:
      - ref: wire-transfer-encryption-policy
        type: encrypt
        condition: 'context.topic.name == "nw.ledger.transactions.high-value-wire-transfers.v1"'
        config:
          part_of_record:
            - value
          encryption_key:
            type: static
            key:
              id: !ref transaction-encryption-key

    consume_policies:
      - ref: wire-transfer-decryption-policy
        type: decrypt
        condition: 'context.topic.name == "nw.ledger.transactions.high-value-wire-transfers.v1"'
        config:
          part_of_record:
            - value
          key_sources:
            - type: static
              key:
                id: !ref transaction-encryption-key
```

### Key Concepts

- **Static Key**: A fixed encryption key stored in the gateway configuration, loaded from environment
- **Produce Policy**: Applied to messages being produced — can encrypt, validate schema, etc.
- **Consume Policy**: Applied to messages being consumed — can decrypt, transform, etc.
- **failure_mode: error**: If encryption/decryption fails, the operation is rejected

## Lifecycle

Phase 6 builds on Phase 5 (ACL enforcement). To move to Phase 7 (schema validation):

```bash
export TRANSACTION_ENCRYPTION_KEY=$(openssl rand -base64 32)
kongctl apply -f ../07-schema-validation/kongctl/config.yaml
```

## See Also

- [Auth Mediation](../04-auth-mediation/kongctl/config.yaml)
- [ACL Enforcement](../05-acl-enforcement/kongctl/config.yaml)
- [Schema Validation](../07-schema-validation/kongctl/config.yaml)
- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
