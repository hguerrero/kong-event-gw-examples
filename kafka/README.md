# Kafka Infrastructure

This folder contains the local Kafka environment used by the examples.

## Purpose

- Starts a local 3-broker Kafka KRaft cluster for testing.
- Initializes business topics and example schemas used by Northwind scenarios.

## Files

- `docker-compose.yaml`: Kafka and supporting services.
- `config/topics.txt`: Topic bootstrap list used during initialization.
- `config/schemas/`: Example schema payloads used by schema-related exercises.

## Usage

From repository root:

```bash
docker compose -f kafka/docker-compose.yaml up -d
docker compose --profile init -f kafka/docker-compose.yaml up -d
```

## Related Docs

- Root bootstrap flow: [README](../README.md)
- Schema validation phase: [examples/07-schema-validation/README.md](../examples/07-schema-validation/README.md)