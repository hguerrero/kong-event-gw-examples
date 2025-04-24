# Topic Alias Example

This example demonstrates how to configure Kong Event Gateway to perform topic name aliasing using Common Expression Language (CEL) expressions.

## Overview

The setup provides:
- Dynamic topic name transformation
- Bidirectional name mapping
- Predefined name aliases (e.g., "Jonathan" ↔ "Jon")
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

The `config.yaml` file demonstrates topic aliasing configuration:

```yaml
topic_rewrite:
  type: cel
  cel:
    virtual_to_backend_expression: >
      {
        "Jonathan":"Jon",
        "Katherine":"Kate",
        "William":"Will",
        "Elizabeth":"Liz"
      }.has(topic.name) ? 
      {
        "Jonathan":"Jon",
        "Katherine":"Kate",
        "William":"Will",
        "Elizabeth":"Liz"
      }[topic.name] : topic.name
    backend_to_virtual_expression: >
      {
        "Jon":"Jonathan",
        "Kate":"Katherine",
        "Will":"William",
        "Liz":"Elizabeth"
      }.has(topic.name) ? 
      {
        "Jon":"Jonathan",
        "Kate":"Katherine",
        "Will":"William",
        "Liz":"Elizabeth"
      }[topic.name] : topic.name
```

Key configuration points:
- CEL expressions for bidirectional name mapping
- Predefined name aliases
- Fallback to original name if no mapping exists
- Transparent transformation for clients

## Testing

Using kafkactl, test the topic aliasing:

1. Create and use topics with full names:
```bash
kafkactl config use-context virtual
kafkactl topic create Jonathan
kafkactl produce Jonathan --value="Hello World"
kafkactl consume Jonathan
```

2. Verify the actual topic name in Kafka:
```bash
kafkactl config use-context default
kafkactl topic list
# Should see "Jon" instead of "Jonathan"
```

## Directory Structure

```
02-topic-alias/
├── config.yaml           # Gateway configuration
├── docker-compose.yaml   # Service definitions
└── README.md            # This file
```

## Environment Variables

Required environment variables:
- `KONNECT_CP_HOST`: Konnect Control Plane host
- `KONNECT_PAT`: Personal Access Token

## Use Cases

This topic alias setup is ideal for:
- Standardizing topic naming conventions
- Supporting legacy topic names
- Providing friendly names for clients
- Maintaining backward compatibility

## Troubleshooting

Common issues:

1. Topic names not transforming:
   - Verify the proxy configuration is loaded correctly
   - Ensure you're connecting through the proxy port (19092)
   - Check if the topic name matches exactly (case-sensitive)

2. Unexpected topic names:
   - Verify the CEL expressions in the configuration
   - Check the mapping dictionary for the expected names
   - Ensure bidirectional mappings are consistent

## Limitations

- Fixed name mappings (requires configuration update to change)
- Case-sensitive name matching
- No wildcard or pattern matching
- Single transformation rule per direction

## Next Steps

Explore other examples:
- Authentication Mediation (03-auth-mediation)
- Topic Filter (04-topic-filter)
- Encryption (05-encryption)
- Schema Validation (06-schema-validation)

## Related Documentation

- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
- [Common Expression Language Specification](https://github.com/google/cel-spec)
- [Kafka Documentation](https://kafka.apache.org/documentation/)