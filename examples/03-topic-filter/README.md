# Phase 2 — Tenant Isolation: Retail Banking NY and Wealth Management LA

Northwind Financial's two business units have been stepping on each other's consumer groups. Retail branch apps occasionally drift into Wealth topics because all services share the same bootstrap servers. This phase puts each business unit behind its own virtual cluster with a namespace prefix — they can only see their own topics.

## Setup Diagram

```mermaid
flowchart TD
    C1["🏦 Branch App\nanonymous"] -->|":19192"| RVC
    C2["💼 Advisor App\nanonymous"] -->|":19292"| WVC
    C3["⚙️ Ops / Core\nanonymous"] -->|":19092"| CVC

    subgraph DP["KEG Data Plane"]
        CVC["core-proxy VC\npassthrough · all topics"]
        RVC["retail-banking-ny VC\nprefix RETAIL_NY.\nhides WEALTH_LA.*"]
        WVC["wealth-management-la VC\nprefix WEALTH_LA.\nhides RETAIL_NY.*"]
    end

    subgraph K["Kafka Cluster"]
        T1["RETAIL_NY.payments.card-dispatch.v1\nRETAIL_NY.markets.exchange-ticker.v1\nRETAIL_NY.branches.commuter-foot-traffic.v1"]
        T2["WEALTH_LA.clients.sentiment-signals.v1\nWEALTH_LA.advisor.daily-client-activity.v1\nWEALTH_LA.portfolios.esg-allocation-adjustments.v1"]
        T3["nw.* shared topics\ninfosec.security.*"]
    end

    RVC -->|"RETAIL_NY.* + nw.*"| T1
    RVC -->|"injected"| T3
    WVC -->|"WEALTH_LA.* + nw.*"| T2
    WVC -->|"injected"| T3
    CVC --> T1 & T2 & T3
```

## What It Does

- Two virtual clusters with namespace prefix isolation
- **retail-banking-ny** (ports 19192–19290): prefix `RETAIL_NY.` — Retail branch services
- **wealth-management-la** (ports 19292–19390): prefix `WEALTH_LA.` — Wealth advisory services
- Shared `nw.*` topics injected into both views via `additional.topics`
- Each business unit sees only its own topics — cross-unit topics are invisible

## How to Use

```bash
kongctl apply -f kongctl/config.yaml

# Retail Banking NY view:
kafkactl config use-context retail-banking-ny
kafkactl get topics
# → payments.card-dispatch.v1, markets.exchange-ticker.v1, nw.*, ...

# Wealth Management LA view:
kafkactl config use-context wealth-management-la
kafkactl get topics
# → clients.sentiment-signals.v1, advisor.daily-client-activity.v1, nw.*, ...
```

## Configuration Details

The namespace block strips the prefix transparently for clients:

```yaml
virtual_clusters:
  - ref: retail-banking-ny
    namespace:
      mode: hide_prefix
      prefix: "RETAIL_NY."
      additional:
        topics:
          - type: glob
            glob: "nw.*"
    authentication:
      - type: anonymous
```

The prefix is automatically stripped on consume and added on produce. Clients never see `RETAIL_NY.` — the gateway handles the translation.

## Next

```bash
kongctl apply -f ../04-auth-mediation/kongctl/config.yaml
```

Moves to Phase 3: Wealth Management advisors authenticate with SASL/PLAIN at the gateway.
