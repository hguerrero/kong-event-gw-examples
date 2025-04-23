# Basic Kafka Proxy Example

This example demonstrates the basic proxy functionality of Kong Event Gateway, allowing clients to connect to a Kafka cluster through a proxy layer with anonymous authentication.

## Overview

The setup provides:
- Simple proxy configuration for Kafka
- Anonymous authentication
- Direct pass-through of Kafka operations
- No message transformation or additional processing

## Components

- Apache Kafka broker (localhost:9092)
- Kong Event Gateway proxy (localhost:19092)

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

The `config.yaml` file contains the minimal configuration needed for a Kafka proxy:

```yaml
virtual_clusters:
  - name: proxy
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
```

Key configuration points:
- Virtual cluster listening on port 19092
- Anonymous authentication for easy testing
- Direct routing to backend Kafka cluster

## Testing

Using kafkactl, you can test both direct and proxied connections:

1. Direct connection to Kafka:
```bash
kafkactl config use-context default
kafkactl topic create test-topic
kafkactl produce test-topic --value="Hello World"
kafkactl consume test-topic
```

2. Connection through proxy:
```bash
kafkactl config use-context virtual
kafkactl topic create test-topic
kafkactl produce test-topic --value="Hello World"
kafkactl consume test-topic
```

## Directory Structure

```
01-basic-proxy/
├── config.yaml           # Gateway configuration
├── docker-compose.yaml   # Service definitions
└── README.md            # This file
```

## Environment Variables

Required environment variables for Kong Event Gateway:
- `KONNECT_CP_HOST`: Konnect Control Plane host
- `KONNECT_PAT`: Personal Access Token

Make sure to set these in your environment or update the docker-compose.yaml file before starting the services.

## Use Cases

This basic proxy setup is ideal for:
- Learning and testing Kong Event Gateway
- Development environments
- Simple Kafka proxy needs
- Network segmentation scenarios

## Troubleshooting

Common issues:

1. Connection refused:
   - Verify all services are running (`docker ps`)
   - Check if ports are available (19092 for proxy, 9092 for Kafka)
   - Ensure KONNECT environment variables are set correctly

2. Topics not visible:
   - Verify Kafka broker is healthy
   - Check if you're using the correct kafkactl context
   - Ensure proxy is properly connected to the backend cluster

## Limitations

- No authentication (uses anonymous access)
- No message transformation
- No topic rewriting
- Basic networking setup (uses host network mode)

## Next Steps

After mastering this basic setup, explore other examples:
- Topic rewriting (02-topic-rewrite)
- Authentication (03-auth-mediation)
- Message encryption (04-encryption)
- Schema validation (05-schema-validation)

## Related Documentation

- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
- [Kafka Documentation](https://kafka.apache.org/documentation/)