# Topic Alias — CEL-Based Name Rewriting (Concept Reference)

This is a concept reference, not a runnable phase. It documents how to use CEL (Common Expression Language) expressions for fine-grained bidirectional topic name mapping — an alternative to the prefix-based namespace isolation used in the main phase sequence.

In the Northwind Financial story, the prefix approach (`RETAIL_NY.`, `WEALTH_LA.`) is used for its simplicity. CEL-based aliasing is useful when you need non-prefix transformations: renaming legacy topic names, exposing a canonical alias while the backend uses a versioned name, or mapping across naming conventions.

## What It Does

- Dynamic topic name transformation using CEL expressions
- Bidirectional mapping: virtual → backend and backend → virtual
- Transparent to clients — they never see the underlying broker name

## CEL Expression Pattern

```cel
{
  "payments.card-dispatch.v1": "RETAIL_NY.payments.card-dispatch.v1",
  "wire-transfers.v1": "nw.ledger.transactions.high-value-wire-transfers.v1"
}.has(topic.name) ?
  {
    "payments.card-dispatch.v1": "RETAIL_NY.payments.card-dispatch.v1",
    "wire-transfers.v1": "nw.ledger.transactions.high-value-wire-transfers.v1"
  }[topic.name] : topic.name
```

## How to Add to a Virtual Cluster

```yaml
virtual_clusters:
  - ref: retail-banking-ny
    # ...
    topic_rewrite:
      virtual_to_backend:
        type: cel
        cel:
          expression: >
            { "payments.card-dispatch.v1": "RETAIL_NY.payments.card-dispatch.v1" }.has(topic.name) ?
            { "payments.card-dispatch.v1": "RETAIL_NY.payments.card-dispatch.v1" }[topic.name] : topic.name
      backend_to_virtual:
        type: cel
        cel:
          expression: >
            { "RETAIL_NY.payments.card-dispatch.v1": "payments.card-dispatch.v1" }.has(topic.name) ?
            { "RETAIL_NY.payments.card-dispatch.v1": "payments.card-dispatch.v1" }[topic.name] : topic.name
```

## When to Use CEL vs Prefix Namespaces

Use the `namespace` prefix block (as in examples 03–07) when each business unit owns a clean topic prefix. Use CEL `topic_rewrite` when you need non-prefix transformations, legacy name compatibility, or multiple disjoint mappings within a single virtual cluster.

## See Also

- [Topic Filter (prefix-based isolation)](../03-topic-filter/README.md)
- [Common Expression Language Specification](https://github.com/google/cel-spec)
- [Kong Event Gateway Documentation](https://docs.konghq.com/gateway/)
