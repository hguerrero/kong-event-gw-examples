# Examples Index

This folder contains all Kong Event Gateway examples used in this repository.

## Numbered Phases (Cumulative)

Apply in order. Each phase includes all configuration from previous phases plus one new capability.

| Phase | Directory | Focus |
|---|---|---|
| 1 | [01-basic-proxy](01-basic-proxy/README.md) | Transparent proxy in front of Kafka |
| 2 | [03-topic-filter](03-topic-filter/README.md) | Topic namespace isolation per business unit |
| 3 | [04-auth-mediation](04-auth-mediation/README.md) | SASL/PLAIN auth mediation |
| 4 | [05-acl-enforcement](05-acl-enforcement/README.md) | Gateway-enforced ACL policies |
| 5 | [06-encryption](06-encryption/README.md) | Field-level encryption |
| 6 | [07-schema-validation](07-schema-validation/README.md) | Schema validation |

## Concept Reference

- [02-topic-alias](02-topic-alias/README.md): CEL-based topic name rewriting reference.

## Backend Variants (Alternative, Not Cumulative)

- [A1-confluent-cloud](A1-confluent-cloud/README.md): Uses Confluent Cloud as backend.
- [A2-redpanda](A2-redpanda/README.md): Uses Redpanda as backend.

## Notes

- Example directories include a local `kongctl/config.yaml` used with `kongctl apply -f`.
- For global bootstrap (Kafka, certificates, environment), see the repository root [README](../README.md).