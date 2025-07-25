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

1. Set up Konnect connection:
   - Copy `../../konnect.env.example` to `../../konnect.env` in the repository root
   - Update `../../konnect.env` with your Konnect credentials:
     ```bash
     KONNECT_API_HOSTNAME=<your-konnect-api-hostname>
     KONNECT_CONTROL_PLANE_ID=<your-konnect-control-plane-id>
     KONNECT_API_TOKEN=<your-konnect-api-token>
     ```

2. Configure your Confluent Cloud settings:
   - Update `config/username.txt` with your Confluent Cloud API key
   - Update `config/password.txt` with your Confluent Cloud API secret
   - Update the bootstrap server in your chosen configuration file (see Configuration Examples below)

3. Choose your authentication configuration and deploy it to Konnect:
   - For anonymous authentication: Use `config/config-auth-anonymous.yaml`
   - For credential forwarding: Use `config/config-auth-forward.yaml`

   Deploy your chosen configuration to Konnect using the Kong Event Gateway control plane.

4. Start the services:
```bash
docker-compose up -d
```

5. Verify the service is running:
```bash
docker ps
```

You should see the Kong Event Gateway container running and connected to your Konnect control plane.

## Configuration Examples

This example provides two different authentication configurations for Confluent Cloud integration. These configurations should be deployed to your Konnect control plane:

### 1. Anonymous Authentication (`config-auth-anonymous.yaml`)

This configuration allows clients to connect without providing credentials, with the gateway handling authentication to Confluent Cloud:

```yaml
virtual_clusters:
  - authentication:
      - type: anonymous
        mediation:
          type: use_backend_cluster
    backend_cluster_name: confluent-cloud
    name: team-c
    route_by:
      type: sni
```

**Use case**: When you want to hide Confluent Cloud credentials from clients and provide simplified access.

### 2. Credential Forwarding (`config-auth-forward.yaml`)

This configuration forwards client credentials directly to Confluent Cloud:

```yaml
virtual_clusters:
  - authentication:
      - type: sasl_plain
        mediation:
          type: forward
    backend_cluster_name: confluent-cloud
    name: team-c
    route_by:
      type: sni
```

**Use case**: When clients have their own Confluent Cloud credentials and you want to forward them directly.

### Common Backend Configuration

Both configurations share the same backend cluster setup:

```yaml
backend_clusters:
  - name: confluent-cloud
    bootstrap_servers:
      - <replace-with-your-bootstrap-server>:<replace-with-your-port>
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

### Key Configuration Points:
- SASL/PLAIN authentication for Confluent Cloud backend
- Secure credential management using Docker secrets
- TLS configuration for encrypted communication
- SNI-based routing for virtual clusters
- Choice between anonymous access or credential forwarding
- Configuration deployed and managed through Konnect control plane

## Testing

Using kafkactl, test the connection to Confluent Cloud. The testing approach depends on which configuration you're using:

### Testing Anonymous Authentication

1. Configure kafkactl for SNI-based routing (no authentication required):
```bash
cat << EOF > .kafkactl.yml
contexts:
  confluent:
    brokers:
      - bootstrap.team-c.127-0-0-1.sslip.io:9092
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

### Testing Credential Forwarding

1. Configure kafkactl with your Confluent Cloud credentials:
```bash
cat << EOF > .kafkactl.yml
contexts:
  confluent:
    brokers:
      - bootstrap.team-c.127-0-0-1.sslip.io:9092
    tls:
      enabled: true
      insecure_skip_verify: true
    sasl:
      mechanism: plain
      username: <your-confluent-cloud-api-key>
      password: <your-confluent-cloud-api-secret>
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
│   ├── config-auth-anonymous.yaml  # Anonymous authentication configuration
│   ├── config-auth-forward.yaml    # Credential forwarding configuration
│   ├── certs/                      # TLS certificates
│   ├── username.txt                # Confluent Cloud API key
│   └── password.txt                # Confluent Cloud API secret
├── docker-compose.yaml             # Service definition
└── README.md                       # This file
```

## Environment Variables

Required environment variables (configured in `../../konnect.env`):
- `KONNECT_API_HOSTNAME`: Your Konnect API hostname
- `KONNECT_API_TOKEN`: Konnect Personal Access Token
- `KONNECT_CONTROL_PLANE_ID`: Konnect Control Plane ID

These values should be copied from `../../konnect.env.example` and updated with your actual Konnect credentials.

## Use Cases

This Confluent Cloud integration is ideal for:

### Anonymous Authentication Use Cases:
- Simplifying client access by hiding backend credentials
- Providing unified access to multiple Confluent Cloud clusters
- Implementing centralized authentication and authorization
- Development and testing environments

### Credential Forwarding Use Cases:
- Multi-tenant environments where each client has their own credentials
- Production environments requiring direct credential validation
- Compliance scenarios requiring credential traceability
- Integration with existing Confluent Cloud RBAC policies

## Troubleshooting

Common issues:

1. Authentication failures:
   - Verify your Confluent Cloud API key and secret are correct
   - Check that you have the correct permissions for the API key
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

