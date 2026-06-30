# Phase 8 — Field-Level Encryption

> **Requires: Kong Event Gateway 1.2+**

Northwind Financial's compliance team has a new requirement: KYC (Know Your Customer) profile events on `nw.crm.customers.kyc-profiles.v1` contain SSNs and other PII. These must be encrypted at rest in Kafka, but downstream consumers that only need non-sensitive fields (like `customer_name` or `account_type`) should not require decryption keys.

This phase adds **field-level encryption** — only the specific JSON fields containing PII are encrypted. The rest of the message remains plaintext. Producers and consumers change nothing; the gateway handles encryption and decryption transparently.

This is separate from the whole-message encryption introduced in [Phase 6](../06-encryption/README.md), which is still active for wire transfer events.

## What It Does

- Encrypts only `personal.ssn` in messages produced to `nw.crm.customers.kyc-profiles.v1`
- Other fields (`personal.name`, `account_type`, etc.) remain readable in plaintext
- Decrypts transparently for consumers connecting through the virtual cluster
- Rejects produce requests where the value is not valid JSON
- A `kong/enc` header is appended to each message identifying the key used

## Comparison: Field Encryption vs. Whole-Message Encryption

| | Whole-message (Phase 6) | Field-level (Phase 8) |
|---|---|---|
| Policy type | `encrypt` / `decrypt` | `encrypt_fields` / `decrypt_fields` |
| What is encrypted | Full message value | Specific JSON field paths |
| Consumers without key | Cannot read anything | Can read non-sensitive fields |
| Message format required | Any | JSON |
| Use case | Maximum confidentiality | Selective PII protection |

## Setup

The `nw.crm.customers.kyc-profiles.v1` topic is created during the Kafka bootstrap step (`docker compose --profile init -f kafka/docker-compose.yaml up`). No manual topic creation is needed.

```bash
# Generate the field encryption key
export FIELD_ENCRYPTION_KEY=$(openssl rand -base64 32)

# Also required for the wire transfer encryption from phase 6
export TRANSACTION_ENCRYPTION_KEY=$(openssl rand -base64 32)

# Apply the configuration
kongctl apply -f examples/08-field-encryption/kongctl/config.yaml
```

## How to Test

```bash
# Produce a KYC profile message through the gateway (SSN will be encrypted at the edge)
kafkactl config use-context core-proxy
kafkactl produce nw.crm.customers.kyc-profiles.v1 \
  --value='{"personal":{"ssn":"100-00-00001","name":"Eleanor Hartwell"},"account_type":"savings","kyc_status":"verified"}'

# Consume through the gateway — SSN is decrypted transparently
kafkactl consume nw.crm.customers.kyc-profiles.v1 --from-beginning --exit
# Output: {"personal":{"ssn":"100-00-00001","name":"Eleanor Hartwell"},"account_type":"savings","kyc_status":"verified"}

# Read raw bytes directly from Kafka (bypassing the gateway) — SSN is ciphertext
docker exec -it kafka_cluster-kafka1-1 /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server kafka1:9092 \
  --topic nw.crm.customers.kyc-profiles.v1 \
  --from-beginning --max-messages 1
# Output: {"personal":{"ssn":"AHry69Jl4oJzafOlu/xOjVa37hpf...","name":"Eleanor Hartwell"},"account_type":"savings","kyc_status":"verified"}
```

## Configuration Details

```yaml
static_keys:
  - ref: field-encryption-key
    name: field-encryption-key
    value: !env FIELD_ENCRYPTION_KEY

virtual_clusters:
  - ref: core-proxy
    produce_policies:
      # JSON validation must run before field encryption can parse the value
      - ref: customer-data-json-validation
        type: schema_validation
        condition: 'context.topic.name == "nw.crm.customers.kyc-profiles.v1"'
        config:
          type: json
          value_validation_action: reject

      - ref: customer-data-field-encryption
        type: encrypt_fields
        condition: 'context.topic.name == "nw.crm.customers.kyc-profiles.v1"'
        parent_policy_id: !ref customer-data-json-validation        
        config:
          failure_mode: reject
          encrypt_fields:
            - paths:
                - match: "personal.ssn"
              encryption_key:
                type: static
                key:
                  name: field-encryption-key

    consume_policies:
      - ref: customer-data-json-validation-consume
        type: schema_validation
        condition: 'context.topic.name == "nw.crm.customers.kyc-profiles.v1"'
        config:
          type: json
          value_validation_action: mark

      - ref: customer-data-field-decryption
        type: decrypt_fields
        condition: 'context.topic.name == "nw.crm.customers.kyc-profiles.v1"'
        parent_policy_id: !ref customer-data-json-validation-consume
        config:
          failure_mode: error
          key_sources:
            - type: static
          decrypt_fields:
            paths:
              - match: "personal.ssn"
```

## Key Concepts

- **`encrypt_fields` policy**: Encrypts specific JSON field paths before the message reaches the broker. Requires the message value to be valid JSON.
- **`decrypt_fields` policy**: Decrypts field-encrypted values transparently for consumers. Uses the `kong/enc` header added during encryption to locate the correct key.
- **`failure_mode: reject`**: On produce, the entire batch is rejected if encryption fails. On consume, `failure_mode: error` prevents delivery of messages that cannot be decrypted.
- **`key_sources`**: On the consume side, `type: static` tells the gateway to look up all static keys registered in the control plane — no need to name the key explicitly.
- **JSON validation prerequisite**: Field encryption requires the value to be parseable JSON. The `schema_validation` policy with `type: json` must run first so the encrypt policy only runs on validated messages.

## Next

```bash
kongctl apply -f examples/07-schema-validation/kongctl/config.yaml
```

Returns to Phase 7 for schema validation on fraud risk score topics (independent feature, can be applied in any order after Phase 5).

## See Also

- [Phase 6 — Whole-Message Encryption](../06-encryption/README.md)
- [Encrypt Fields policy](https://developer.konghq.com/event-gateway/policies/encrypt-fields/)
- [Decrypt Fields policy](https://developer.konghq.com/event-gateway/policies/decrypt-fields/)
- [Static keys](https://developer.konghq.com/event-gateway/entities/static-key/)
- [Encrypt Kafka message fields how-to](https://developer.konghq.com/event-gateway/encrypt-kafka-message-fields-with-event-gateway/)
