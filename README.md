# Kong Event Gateway Examples

This repository contains progressive examples demonstrating Kong Event Gateway features using **kongctl** declarative configuration with Kong Konnect.

Each example is self-contained in its own directory with its own `kongctl/config.yaml` configuration. Examples build on each other cumulatively — each includes all configuration from prior examples plus the new feature.

## Architecture

```
                        ┌──────────────────┐
                        │  Konnect Control  │
                        │  Plane (kongctl)  │
                        └────────┬─────────┘
                                 │ kongctl apply
                        ┌────────▼─────────┐
  kafkactl ────────────►│  KEG Data Plane  │◄──── kong/kong-event-gateway:latest
  (port 19092-19389)    │  (localhost)      │
                        └────────┬─────────┘
                                 │
                        ┌────────▼─────────┐
                        │  Kafka Cluster   │
                        │  (3 brokers)     │
                        │  + Apicurio SR   │
                        └──────────────────┘
```

## Prerequisites

- Docker and Docker Compose
- [kongctl](https://konghq.com/products/kong-konnect/event-gateway) CLI
- [kafkactl](https://deviceinsight.github.io/kafkactl/) (optional, for testing)
- A Kong Konnect account (free tier works)

## One-Time Bootstrap

### Step 1 — Start Kafka

```bash
docker compose -f kafka/docker-compose.yaml up -d
docker compose --profile init -f kafka/docker-compose.yaml up
```

### Step 2 — Register the Data Plane Certificate

Generate a self-signed certificate:

```bash
openssl req -new -x509 -nodes -newkey rsa:2048 \
  -subj "/CN=event-gateway/C=US" \
  -keyout kongctl/certs/key.crt \
  -out    kongctl/certs/tls.crt
```

Register it in Konnect:

```bash
export KONGCTL_DEFAULT_KONNECT_PAT=<your-personal-access-token>
kongctl apply -f kongctl/data_plane_certificate.yaml
```

Retrieve the cluster ID:

```bash
kongctl get event-gateway keg-examples-gateway --output json --jq '.id' --jq-raw-output
```

### Step 3 — Configure konnect.env

```bash
cp konnect.env.example konnect.env
```

Edit `konnect.env` with your region, domain, and cluster ID, then load the TLS identity:

```bash
printf 'KONG_KONNECT_CLIENT_CERT="%s"\n' "$(cat kongctl/certs/tls.crt)" >> konnect.env
printf 'KONG_KONNECT_CLIENT_KEY="%s"\n'  "$(cat kongctl/certs/key.crt)"  >> konnect.env
```

### Step 4 — Start the Gateway

```bash
docker compose up -d
```

## Examples (Cumulative Phases)

Apply them in order — each replaces the previous configuration with one that adds new capabilities:

| # | Directory | kongctl Apply | Feature | Topic Alias |
|---|-----------|--------------|---------|-------------|
| 1 | [`examples/01-basic-proxy/`](examples/01-basic-proxy/README.md) | `kongctl apply -f examples/01-basic-proxy/kongctl/config.yaml` | Backend cluster + flat passthrough VC | — |
| 2 | [`examples/03-topic-filter/`](examples/03-topic-filter/README.md) | `kongctl apply -f examples/03-topic-filter/kongctl/config.yaml` | Multi-VC namespace isolation | [`02-topic-alias`](examples/02-topic-alias/README.md) (CEL concept) |
| 3 | [`examples/04-auth-mediation/`](examples/04-auth-mediation/README.md) | `kongctl apply -f examples/04-auth-mediation/kongctl/config.yaml` | SASL/PLAIN auth termination | — |
| 4 | [`examples/05-encryption/`](examples/05-encryption/README.md) | `kongctl apply -f examples/05-encryption/kongctl/config.yaml` | Encrypt/decrypt policies | — |
| 5 | [`examples/06-schema-validation/`](examples/06-schema-validation/README.md) | `kongctl apply -f examples/06-schema-validation/kongctl/config.yaml` | Schema validation + ACLs | — |

### [1 — Basic Proxy](examples/01-basic-proxy/README.md)

```bash
kongctl apply -f examples/01-basic-proxy/kongctl/config.yaml
kafkactl config use-context core-proxy
kafkactl get topics
```

Registers the Kafka backend and exposes it through a flat passthrough virtual cluster. No namespace isolation, no auth, no policies — just a transparent proxy.

### [2 — Topic Filter (Namespace Isolation)](examples/03-topic-filter/README.md)

```bash
kongctl apply -f examples/03-topic-filter/kongctl/config.yaml
kafkactl config use-context team-a
kafkactl get topics
```

Adds two namespace-isolated VCs:
- **team-a** (ports 19192-19290): prefix `A.`
- **team-b** (ports 19292-19390): prefix `B.`

### [3 — Auth Mediation](examples/04-auth-mediation/README.md)

```bash
kongctl apply -f examples/04-auth-mediation/kongctl/config.yaml
kafkactl config use-context team-b-authed
kafkactl get topics
```

Adds SASL/PLAIN authentication to Team B with `mediation: terminate`.

### [4 — Message Encryption](examples/05-encryption/README.md)

```bash
export TRANSACTION_ENCRYPTION_KEY=$(openssl rand -base64 32)
kongctl apply -f examples/05-encryption/kongctl/config.yaml
```

Adds field-level encryption for high-value wire transfer events (produce encrypt, consume decrypt).

### [5 — Schema Validation](examples/06-schema-validation/README.md)

```bash
export TRANSACTION_ENCRYPTION_KEY=$(openssl rand -base64 32)
kongctl apply -f examples/06-schema-validation/kongctl/config.yaml
```

Adds Apicurio Schema Registry with schema validation on fraud risk score topics, plus ACL enforcement on Team B.

## Variants (Alternative Backends)

These replace the local Kafka backend entirely (apply instead of the phases above):

| Directory | kongctl Apply | Backend |
|-----------|--------------|---------|
| [`examples/A1-confluent-cloud/`](examples/A1-confluent-cloud/README.md) | `kongctl apply -f examples/A1-confluent-cloud/kongctl/config.yaml` | Confluent Cloud (SASL/PLAIN + TLS) |
| [`examples/A2-redpanda/`](examples/A2-redpanda/README.md) | `kongctl apply -f examples/A2-redpanda/kongctl/config.yaml` | Redpanda |

## Testing with kafkactl

| Context | Port | Auth | Notes |
|---------|------|------|-------|
| `default` | 9092 | None | Direct to Kafka |
| `core-proxy` | 19092 | Anonymous | Flat passthrough VC |
| `team-a` | 19192 | Anonymous | Team A namespace |
| `team-b` | 19292 | Anonymous | Team B (unauthenticated) |
| `team-b-authed` | 19292 | SASL/PLAIN | Team B (team-b-user/secret) |
| `team-b-schema` | 19292 | SASL/PLAIN + SR | Team B with Schema Registry |

```bash
kafkactl config use-context core-proxy
kafkactl get topics
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `KONG_KONNECT_REGION` | Yes | Konnect region (us, eu, au) |
| `KONG_KONNECT_DOMAIN` | Yes | Konnect domain (konghq.com) |
| `KONG_KONNECT_GATEWAY_CLUSTER_ID` | Yes | Gateway cluster ID from Konnect |
| `KONG_KONNECT_CLIENT_CERT` | Yes | Data plane TLS certificate (PEM) |
| `KONG_KONNECT_CLIENT_KEY` | Yes | Data plane TLS private key (PEM) |
| `KAFKA_USERNAME` | Variant | Confluent Cloud username |
| `KAFKA_PASSWORD` | Variant | Confluent Cloud password |
| `TRANSACTION_ENCRYPTION_KEY` | Examples 4-5 | Base64-encoded 32-byte encryption key |

## Directory Structure

```
kong-event-gw-examples/
├── docker-compose.yaml              # Gateway data plane
├── kafka/
│   ├── docker-compose.yaml          # Kafka cluster + Apicurio
│   └── config/
│       ├── topics.txt
│       └── schemas/
├── kongctl/
│   ├── certs/                       # TLS identity (gitignored)
│   └── data_plane_certificate.yaml  # Register gateway in Konnect
├── examples/
│   ├── 01-basic-proxy/
│   │   ├── kongctl/config.yaml      # Phase 1 config
│   │   └── README.md
│   ├── 02-topic-alias/
│   │   └── README.md                # CEL concept reference
│   ├── 03-topic-filter/
│   │   ├── kongctl/config.yaml      # Phase 2 config
│   │   └── README.md
│   ├── 04-auth-mediation/
│   │   ├── kongctl/config.yaml      # Phase 3 config
│   │   └── README.md
│   ├── 05-encryption/
│   │   ├── kongctl/config.yaml      # Phase 4 config
│   │   └── README.md
│   ├── 06-schema-validation/
│   │   ├── kongctl/config.yaml      # Phase 5 config
│   │   └── README.md
│   ├── A1-confluent-cloud/
│   │   ├── kongctl/config.yaml      # Confluent variant
│   │   └── README.md
│   └── A2-redpanda/
│       ├── kongctl/config.yaml      # Redpanda variant
│       └── README.md
├── konnect.env.example
├── .kafkactl.yml
└── README.md
```

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.
