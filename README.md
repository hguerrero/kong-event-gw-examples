# Kong Event Gateway Examples

This repository contains example configurations and docker-compose files demonstrating various features of Kong Event Gateway (Kiburi).

## Prerequisites

- Docker and Docker Compose
- kafkactl (optional, for testing)

## Examples

### 1. Basic Proxy (`examples/01-basic-proxy`)
Basic setup demonstrating Kafka proxy functionality:
- Simple proxy configuration
- Anonymous authentication
- Direct pass-through of Kafka operations
- Ideal for development environments and testing

### 2. Topic Alias (`examples/02-topic-alias`)
Shows how to configure topic name aliasing using CEL expressions:
- Dynamic topic name transformation
- Bidirectional name mapping
- Predefined name aliases
- Transparent operation for clients
- Ideal for standardizing naming conventions

### 3. Topic Filter (`examples/03-topic-filter`)
Shows how to configure automatic topic name filtering:
- Automatic topic name prefixing
- Prefix-based topic filtering
- Transparent operation for clients
- Ideal for multi-tenant environments and namespace isolation

### 4. Authentication Mediation (`examples/04-auth-mediation`)
Demonstrates JWT authentication configuration with two clusters:
- Anonymous authentication cluster (port 19092)
- JWT-authenticated cluster (port 29092)
- Separate authentication methods per virtual cluster
- Perfect for mixed security requirements and gradual security implementation

### 5. Encryption (`examples/05-encryption`)
Showcases message-level encryption/decryption capabilities:
- Automatic encryption of produced messages
- Automatic decryption of consumed messages
- Uses symmetric key encryption (128-bit)
- Includes key generation scripts (`generate_key.sh`)
- Messages encrypted at rest in Kafka

### 6. Schema Validation (`examples/06-schema-validation`)
Example of schema validation configuration:
- Message schema validation
- Integration with Schema Registry
- Validation before message production
- Error handling for invalid messages
- Ideal for ensuring data quality and contract-first development

### Additional Examples
- Confluent Cloud Integration (`examples/A1-confluent-cloud`)
  - Secure connection to Confluent Cloud
  - SASL/PLAIN authentication
  - TLS encryption
  - SNI-based routing
  - Secrets management for credentials

## Quick Start

Each example directory contains:
- `config.yaml`: Kong Event Gateway configuration
- `docker-compose.yaml`: Required services configuration
- `README.md`: Detailed documentation and usage instructions

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

## Common Use Cases

1. Development and Testing
   - Use the Basic Proxy example
   - Anonymous authentication
   - Direct pass-through functionality

2. Multi-tenant Environments
   - Topic Filter example for namespace isolation
   - Authentication Mediation for security
   - Schema Validation for data governance

3. Security Implementation
   - Authentication Mediation for access control
   - Encryption for data protection
   - Multiple authentication methods

4. Data Quality
   - Schema Validation for message format enforcement
   - Topic Filter for organizational standards
   - Error handling and validation

5. Cloud Integration
   - Confluent Cloud integration for managed Kafka
   - Secure credential management
   - TLS and SASL authentication

## Troubleshooting

Common issues across examples:

1. Connection Issues
   - Verify services are running (`docker ps`)
   - Check port availability
   - Confirm environment variables are set

2. Authentication Problems
   - Verify correct context in kafkactl
   - Check JWT token validity
   - Confirm proxy port usage

3. Configuration
   - Validate config.yaml syntax
   - Check service dependencies
   - Verify network connectivity

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.
