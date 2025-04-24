# Message-Level Encryption Example

This example demonstrates how to configure Kong Event Gateway for automatic message encryption and decryption using symmetric key encryption.

## Overview

The setup provides:
- Automatic encryption of messages during production
- Automatic decryption of messages during consumption
- Symmetric key encryption using a 128-bit key
- Transparent encryption/decryption (clients don't need to handle encryption)

## Components

- Kafka broker (localhost:9092)
- Kong Event Gateway with encryption configuration (localhost:19092)
- Key generation utilities

## Quick Start

1. Generate an encryption key:
```bash
./generate_key.sh
```

2. Update the `config.yaml` file with your generated key:
```yaml
key_sources:
  - type: static
    name: inline-key
    static:
      - id: "static://key-0"
        key:
          type: bytes
          bytes:
            value: "YOUR_GENERATED_KEY"
```

3. Start the services:
```bash
docker-compose up -d
```

## Testing

Using kafkactl, you can test the encryption:

1. Produce a message through the proxy (will be encrypted):
```bash
echo "secret message" | kafkactl -c virtual produce my-topic
```

2. Consume through the proxy (will be decrypted):
```bash
kafkactl -c virtual consume my-topic
```

3. Consume directly from Kafka (will be encrypted):
```bash
kafkactl -c default consume my-topic
```

## Configuration Details

The configuration includes:

- Produce policies that encrypt all message values
- Consume policies that decrypt all message values
- Error handling for encryption/decryption failures
- Static key configuration for simplicity

## Security Considerations

- The encryption key is stored in plain text in the configuration file
- In production environments, use secure key management solutions
- The example uses network_mode: host for simplicity; adjust for production
- Messages are encrypted at rest in Kafka
- Only consumers through the proxy can decrypt messages

## Troubleshooting

Common issues:

1. Encryption failures:
   - Verify the key is correctly base64 encoded
   - Ensure the key is exactly 16 bytes (128 bits) before base64 encoding

2. Decryption failures:
   - Confirm the same key is used in both produce and consume policies
   - Verify messages were produced through the proxy

## Directory Structure

```
04-encryption/
├── config.yaml           # Gateway configuration with encryption
├── docker-compose.yaml   # Service definitions
├── generate_key.sh       # Key generation utility
└── README.md            # This file
```

## Related Documentation

- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
- [Message Encryption Documentation](https://docs.konghq.com/gateway/latest/kong-event-gateway/)

## Environment Variables

Required environment variables:
- `KONNECT_CP_HOST`: Konnect Control Plane host
- `KONNECT_PAT`: Personal Access Token

## Limitations

- Only message values are encrypted (not keys or headers)
- Single encryption key for all messages
- Symmetric encryption only