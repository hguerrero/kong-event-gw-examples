# Kong Event Gateway Examples

This repository contains example configurations and docker-compose files demonstrating various features of Kong Event Gateway (Kiburi).

## Prerequisites

- Docker and Docker Compose
- kafkactl (optional, for testing)

## Examples

### 1. Basic Proxy (`examples/01-basic-proxy`)
Basic setup demonstrating Kafka proxy functionality with anonymous authentication.

### 2. Topic Rewrite (`examples/02-topic-rewrite`)
Shows how to configure topic name rewriting using prefixes.

### 3. Authentication Mediation (`examples/03-auth-mediation`)
Demonstrates JWT authentication configuration with two clusters:
- Anonymous authentication cluster (port 19092)
- JWT-authenticated cluster (port 29092)

### 4. Encryption (`examples/04-encryption`)
Showcases message-level encryption/decryption capabilities:
- Automatic encryption of produced messages
- Automatic decryption of consumed messages
- Uses symmetric key encryption
- Includes key generation scripts (`generate_key.sh`)

### 5. Schema Validation (`examples/05-schema-validation`)
Example of schema validation configuration.

### Additional Examples
- Redpanda Integration (`examples/A1-redpanda`)

## Quick Start

Each example directory contains:
- `config.yaml`: Kong Event Gateway configuration
- `docker-compose.yaml`: Required services configuration

To run any example:

```bash
cd examples/[example-directory]
docker-compose up -d
```

## Testing with kafkactl

The `.kafkactl.yml` configuration includes three contexts:
- `default`: Direct connection to Kafka (localhost:9092)
- `virtual`: Connection through basic proxy (localhost:19092)
- `secured`: Connection through authenticated proxy (localhost:29092)

Switch contexts using:
```bash
kafkactl config use-context [context-name]
```

## Components

The main docker-compose file includes:
- Apache Kafka
- Schema Registry
- Kong Event Gateway (Kiburi)
- Kafka UI (available at http://localhost:8080)

## Environment Variables

Required environment variables for Kong Event Gateway:
- `KONNECT_CP_HOST`: Konnect Control Plane host
- `KONNECT_PAT`: Personal Access Token

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.
