# Authentication Mediation Example

This example demonstrates how to configure Kong Event Gateway with different authentication methods, specifically showing both anonymous and JWT authentication configurations.

## Overview

The setup provides:
- Dual authentication configurations
- Anonymous access on port 19092
- JWT-authenticated access on port 29092
- Authentication mediation between clients and Kafka

## Components

- Apache Kafka broker (localhost:9092)
- Kong Event Gateway proxy with:
  - Anonymous auth endpoint (localhost:19092)
  - JWT auth endpoint (localhost:29092)

## Quick Start

1. Start the services:
```bash
docker-compose up -d
```

2. Verify the services are running:
```bash
docker ps
```

You should see two containers running:
- `kafka`: The Apache Kafka broker
- `kiburi`: The Kong Event Gateway proxy

## Configuration Details

The `config.yaml` file demonstrates two authentication configurations:

```yaml
virtual_clusters:
  - name: no-auth
    backend_cluster_name: kafka-localhost
    route_by:
      type: port
      port:
        listen_start: 19092
        min_broker_id: 1
    authentication:
      - type: anonymous
        mediation:
          type: anonymous
  - name: jwt-auth
    backend_cluster_name: kafka-localhost
    route_by:
      type: port
      port:
        listen_start: 29092
        min_broker_id: 1
    auth:
      mode: jwt
      jwt:
        keys:
          # JWT configuration details
```

Key configuration points:
- Two virtual clusters with different authentication methods
- Separate ports for different auth methods
- JWT configuration for secured access

## Testing

Using kafkactl, test both authentication methods:

1. Anonymous access:
```bash
kafkactl config use-context virtual
kafkactl topic create test-topic
kafkactl produce test-topic --value="Hello World"
```

2. JWT-authenticated access:
```bash
# First, set your JWT token
export KAFKA_TOKEN="your.jwt.token"
kafkactl config use-context secured
kafkactl topic create secure-topic
```

## Directory Structure

```
03-auth-mediation/
├── config.yaml           # Gateway configuration
├── docker-compose.yaml   # Service definitions
└── README.md            # This file
```

## Environment Variables

Required environment variables:
- `KONNECT_CP_HOST`: Konnect Control Plane host
- `KONNECT_PAT`: Personal Access Token

## Use Cases

This authentication setup is ideal for:
- Multi-tenant environments
- Mixed security requirements
- Development and production workloads
- Gradual security implementation

## Troubleshooting

Common issues:

1. JWT authentication failures:
   - Verify JWT token is valid and not expired
   - Check if token contains required claims
   - Ensure correct JWT configuration in config.yaml

2. Connection issues:
   - Verify correct port usage (19092 for anonymous, 29092 for JWT)
   - Check if services are running
   - Confirm JWT token is properly set in environment

## Limitations

- Single JWT configuration per virtual cluster
- No dynamic JWT key rotation
- Basic JWT claim validation
- No OAuth2 or other authentication methods

## Next Steps

Explore other examples:
- Message encryption (04-encryption)
- Schema validation (05-schema-validation)
- Redpanda integration (A1-redpanda)

## Related Documentation

- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
- [JWT Authentication](https://jwt.io/)
- [Kafka Security Documentation](https://kafka.apache.org/documentation/#security)