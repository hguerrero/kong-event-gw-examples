# Topic Rewrite Example

This example demonstrates how to configure Kong Event Gateway to automatically rewrite topic names using prefixes.

## Overview

The setup provides:
- Automatic topic name rewriting
- Prefix-based topic transformation
- Transparent operation for clients
- Anonymous authentication for easy testing

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

The `config.yaml` file demonstrates topic rewriting configuration:

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
    topic_rewrite:
      type: prefix
      prefix:
        value: proxy.
```

Key configuration points:
- Topic rewriting enabled with prefix "proxy."
- All topics accessed through the proxy will be prefixed
- Original topic names preserved in the client view

## Testing

Using kafkactl, test the topic rewriting:

1. Create and use a topic through the proxy:
```bash
kafkactl config use-context virtual
kafkactl topic create my-topic
kafkactl produce my-topic --value="Hello World"
kafkactl consume my-topic
```

2. Verify the actual topic name in Kafka:
```bash
kafkactl config use-context default
kafkactl topic list
# Should see "proxy.my-topic"
```

## Directory Structure

```
02-topic-rewrite/
├── config.yaml           # Gateway configuration
├── docker-compose.yaml   # Service definitions
└── README.md            # This file
```

## Environment Variables

Required environment variables:
- `KONNECT_CP_HOST`: Konnect Control Plane host
- `KONNECT_PAT`: Personal Access Token

## Use Cases

This topic rewrite setup is ideal for:
- Multi-tenant environments
- Topic namespace isolation
- Environment segregation
- Service mesh patterns

## Troubleshooting

Common issues:

1. Topics not appearing with prefix:
   - Verify the proxy configuration is loaded correctly
   - Ensure you're connecting through the proxy port (19092)
   - Check if topic rewrite rules are correctly configured

2. Cannot access original topic names:
   - This is expected - always use unprefixed names through the proxy
   - Direct Kafka access will show prefixed names

## Limitations

- Single prefix for all topics
- No regex-based rewriting
- No conditional rewriting
- Prefix cannot be changed dynamically

## Next Steps

Explore other examples:
- Authentication (03-auth-mediation)
- Message encryption (04-encryption)
- Schema validation (05-schema-validation)

## Related Documentation

- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
- [Kafka Documentation](https://kafka.apache.org/documentation/)