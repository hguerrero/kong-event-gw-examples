# Topic Alias Example

This example demonstrates how to configure topic name aliasing using CEL (Common Expression Language) expressions — mapping topic names bidirectionally between what clients see and what exists on the broker.

> **Note:** The CEL-based topic alias pattern is a more flexible alternative to the
> prefix-based namespace isolation shown in [examples/03-topic-filter](../03-topic-filter/).
> For this example set, prefix-based isolation is used for simplicity; CEL-based
> renaming can be added to any virtual cluster for fine-grained name mapping.

## What It Does

- Dynamic topic name transformation using CEL expressions
- Bidirectional name mapping (virtual → backend and backend → virtual)
- Predefined name aliases (e.g., "Jonathan" ↔ "Jon", "Katherine" ↔ "Kate")
- Transparent operation for clients — they never see the aliasing

## CEL Expression Pattern

The core CEL expression for topic renaming:

```cel
{
  "Jonathan": "Jon",
  "Katherine": "Kate",
  "William": "Will",
  "Elizabeth": "Liz"
}.has(topic.name) ?
  {
    "Jonathan": "Jon",
    "Katherine": "Kate",
    "William": "Will",
    "Elizabeth": "Liz"
  }[topic.name] : topic.name
```

## How to Use with kongctl

To add CEL-based topic aliasing to an existing phase, add a `topic_rewrite` block to any
virtual cluster in the kongctl YAML:

```yaml
virtual_clusters:
  - ref: my-vc
    # ...
    topic_rewrite:
      virtual_to_backend:
        type: cel
        cel:
          expression: >
            { "Jonathan":"Jon", "Katherine":"Kate" }.has(topic.name) ?
            { "Jonathan":"Jon", "Katherine":"Kate" }[topic.name] : topic.name
      backend_to_virtual:
        type: cel
        cel:
          expression: >
            { "Jon":"Jonathan", "Kate":"Katherine" }.has(topic.name) ?
            { "Jon":"Jonathan", "Kate":"Katherine" }[topic.name] : topic.name
```

## Alternative: Prefix-Based Namespace Isolation

If you need simpler team-level isolation, use the `namespace` block instead of CEL:

```yaml
virtual_clusters:
  - ref: team-a
    namespace:
      mode: hide_prefix
      prefix: "A."
```

This is the approach used in [examples/03-topic-filter](../03-topic-filter/kongctl/config.yaml).

## Key Concepts

- **virtual_to_backend**: Maps client-visible topic names to backend topic names
- **backend_to_virtual**: Maps backend topic names to client-visible names
- **CEL expressions**: Google's Common Expression Language for safe, side-effect-free transformations

## Testing

```bash
# Create a topic with aliased name through virtual cluster:
kafkactl config use-context core-proxy
kafkactl create topic Jonathan

# The topic exists as "Jon" in Kafka:
kafkactl config use-context default
kafkactl get topics  # Shows "Jon"

# Via virtual cluster, it appears as "Jonathan":
kafkactl config use-context core-proxy
kafkactl get topics  # Shows "Jonathan"
```

## See Also

- [Topic Filter (prefix-based isolation)](../03-topic-filter/kongctl/config.yaml)
- [Common Expression Language Specification](https://github.com/google/cel-spec)
- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
