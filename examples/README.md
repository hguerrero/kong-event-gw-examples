# Examples Index

This folder contains all Kong Event Gateway examples used in this repository.

## Numbered Phases (Cumulative)

Apply in order. Each phase includes all configuration from previous phases plus one new capability.

| Phase | Directory | Focus |
|---|---|---|
| 1 | [01-basic-proxy](01-basic-proxy/README.md) | Transparent proxy in front of Kafka |
| 2 | [02-topic-alias](02-topic-alias/README.md) | Topic aliases — friendly names for backend topics (v1.2+) |
| 3 | [03-topic-filter](03-topic-filter/README.md) | Topic namespace isolation per business unit |
| 4 | [04-auth-mediation](04-auth-mediation/README.md) | SASL/PLAIN auth mediation |
| 5 | [05-acl-enforcement](05-acl-enforcement/README.md) | Gateway-enforced ACL policies |
| 6 | [06-encryption](06-encryption/README.md) | Whole-message encryption on wire transfers |
| 7 | [07-schema-validation](07-schema-validation/README.md) | Schema validation |
| 8 | [08-field-encryption](08-field-encryption/README.md) | Field-level encryption of specific JSON fields (v1.2+) |

## Backend Variants (Alternative, Not Cumulative)

- [A1-confluent-cloud](A1-confluent-cloud/README.md): Uses Confluent Cloud as backend.
- [A2-redpanda](A2-redpanda/README.md): Uses Redpanda as backend.

## Notes

- Example directories include a local `kongctl/config.yaml` used with `kongctl apply -f`.
- Examples marked **v1.2+** require Kong Event Gateway 1.2 or later.
- For global bootstrap (Kafka, certificates, environment), see the repository root [README](../README.md).
