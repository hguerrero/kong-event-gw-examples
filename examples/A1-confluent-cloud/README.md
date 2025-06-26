# Confluent Cloud Integration Example

This example demonstrates how to configure Kong Event Gateway to connect to a Confluent Cloud Kafka cluster.

## Overview

The setup provides:
- Secure connection to Confluent Cloud
- SASL/PLAIN authentication
- TLS encryption
- SNI-based routing
- Secrets management for credentials

## Components

- Confluent Cloud Kafka cluster
- Kong Event Gateway proxy (localhost:9092)
- TLS certificates for secure communication

## Quick Start

1. Configure your Confluent Cloud credentials:
   - Update `config/username.txt` with your Confluent Cloud API key
   - Update `config/password.txt` with your Confluent Cloud API secret

2. Start the services:
```bash
docker-compose up -d
```

3. Verify the service is running:
```bash
docker ps
```

You should see the Kong Event Gateway container running.

## Configuration Details

The `config/config.yaml` file demonstrates Confluent Cloud integration:

```yaml
backend_clusters:
  - name: confluent-cloud
    bootstrap_servers: 
      - pkc-921jm.us-east-2.aws.confluent.cloud:9092
    authentication:
      type: sasl_plain
      sasl_plain:
        username:
          type: file
          file:
            path: /run/secrets/confluent_cloud_username
        password:
          type: file
          file:
            path: /run/secrets/confluent_cloud_password
    tls:
      insecure_skip_verify: true
```

Key configuration points:
- SASL/PLAIN authentication for Confluent Cloud
- Secure credential management using Docker secrets
- TLS configuration for encrypted communication
- SNI-based routing for virtual clusters

## Testing

Using kafkactl, test the connection to Confluent Cloud:

1. Configure kafkactl for SNI-based routing:
```bash
cat << EOF > .kafkactl.yml
contexts:
  confluent:
    brokers:
      - team-c.127-0-0-1.sslip.io:9092
    tls:
      enabled: true
      insecure_skip_verify: true
current-context: confluent
EOF
```

2. List topics and produce/consume messages:
```bash
kafkactl get topics
kafkactl produce my-topic --value="Hello Confluent Cloud"
kafkactl consume my-topic
```

## Directory Structure

```
A1-confluent-cloud/
├── config/
│   ├── config.yaml        # Gateway configuration
│   ├── certs/             # TLS certificates
│   ├── username.txt       # Confluent Cloud API key
│   └── password.txt       # Confluent Cloud API secret
├── docker-compose.yaml    # Service definition
└── README.md              # This file
```

## Environment Variables

Required environment variables:
- `KONNECT_TOKEN`: Konnect Personal Access Token
- `KONNECT_CONTROL_PLANE_ID`: Konnect Control Plane ID

## Use Cases

This Confluent Cloud integration is ideal for:
- Production Kafka deployments
- Managed Kafka services
- Secure cloud-based Kafka access
- Multi-region Kafka deployments

## Troubleshooting

Common issues:

1. Authentication failures:
   - Verify your Confluent Cloud API key and secret are correct
   - Check if the credentials files are properly mounted as secrets
   - Ensure the Confluent Cloud cluster is accessible

2. TLS connection issues:
   - Verify TLS certificates are properly configured
   - Check SNI configuration in client tools
   - Ensure proper hostname resolution

## Limitations

- Requires valid Confluent Cloud credentials
- TLS configuration is required
- Client tools must support SNI for hostname-based routing

## Next Steps

Explore other examples:
- Basic Proxy (01-basic-proxy)
- Topic Alias (02-topic-alias)
- Topic Filter (03-topic-filter)
- Authentication Mediation (04-auth-mediation)

## Related Documentation

- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
- [Confluent Cloud Documentation](https://docs.confluent.io/cloud/current/overview.html)
- [Kafka Documentation](https://kafka.apache.org/documentation/)

## Cleanup

When you're done experimenting with this example, you can clean up the resources:

```bash
docker-compose down
```


