---
id: ADR-MODEL-001
title: "Use Claude Sonnet for MCP workers, Claude Opus for orchestration in advertising agent"
status: accepted
type: model-selection
date: 2026-03-12
decision_makers: [John Williams]
related_prds: [PRD-MINI-001]
related_specs: [SPEC-MINI-001]
sprint: S-03
prompt_version: PV-003
review_trigger: "2026-Q3"
tags: [llm, model-selection, google-ads, mcp, production, advertising]
---

# ADR-MODEL-001: Model Selection for Advertising Agent (Orchestrator + 14 MCP Workers)

## Context and problem statement

The MiniAgent advertising platform requires LLM capabilities at two tiers: (1) an orchestrator that understands user intent and routes to the correct platform MCP servers, and (2) 14 platform-specific workers that execute API operations via FastMCP tools. The orchestrator requires strong reasoning to decompose cross-platform queries and enforce the CEP safety protocol. Workers require reliable tool calling and structured output but handle narrower, well-defined tasks. The system must stay under $0.10/query average cost while managing real advertising budgets where errors have direct financial consequences.

**Decision question:** Which models should power the orchestrator and worker tiers given requirements for reliable tool calling, ≤$0.10/query, P95 < 10s, and zero tolerance for unauthorized mutations?

---

## Decision drivers

- **Tool-calling reliability:** Workers must call Google Ads API, Meta Marketing API, etc. with correct parameters — a hallucinated `customer_id` or malformed GAQL query wastes API quota and returns confusing errors
- **Reasoning (orchestrator):** Must decompose "compare my Google and Meta CPA this month" into parallel queries to 2 specific MCP servers with correct date parameters
- **Safety:** Model must reliably follow CEP protocol — never execute a write tool without explicit approval in conversation context
- **Latency:** P95 < 10s end-to-end including API round-trips
- **Cost:** ≤$0.10/query average; system handles ~500 queries/day
- **Context window:** Orchestrator may need 50K+ tokens for cross-platform responses; workers need 16K max

---

## Candidates evaluated

### Orchestrator tier

| Model | Provider | Context | Input ($/1M) | Output ($/1M) | Tool-call reliability |
|---|---|---|---|---|---|
| Claude Opus 4 | Anthropic | 200K | $15.00 | $75.00 | Excellent |
| Claude Sonnet 4 | Anthropic | 200K | $3.00 | $15.00 | Very good |
| GPT-4o | OpenAI | 128K | $2.50 | $10.00 | Good |
| Gemini 2.5 Pro | Google | 1M | $1.25 | $10.00 | Good |

### Worker tier

| Model | Provider | Context | Input ($/1M) | Output ($/1M) | Tool-call reliability |
|---|---|---|---|---|---|
| Claude Sonnet 4 | Anthropic | 200K | $3.00 | $15.00 | Very good |
| Claude Haiku 4 | Anthropic | 200K | $0.80 | $4.00 | Adequate |
| GPT-4o-mini | OpenAI | 128K | $0.15 | $0.60 | Adequate |
| Gemini 2.5 Flash | Google | 1M | $0.15 | $0.60 | Adequate |

---

## Evaluation results

### Evaluation methodology

- **Eval dataset:** 75 real advertising operations (25 reads, 25 cross-platform, 25 writes requiring CEP)
- **Evaluation criteria:** Tool-call accuracy (correct params), CEP compliance (never auto-executes writes), cross-platform routing accuracy, structured output validity
- **Temperature:** 0.0 for all candidates
- **Identical system prompts** across all candidates per tier

### Orchestrator results

| Model | Routing accuracy | CEP compliance | Cross-platform | Latency P95 | Cost/query |
|---|---|---|---|---|---|
| Claude Opus 4 | 96% | 100% | 92% | 4,200ms | $0.068 |
| **Claude Sonnet 4** | **93%** | **100%** | **88%** | **2,800ms** | **$0.018** |
| GPT-4o | 89% | 96% | 82% | 2,400ms | $0.014 |
| Gemini 2.5 Pro | 87% | 92% | 80% | 3,100ms | $0.012 |

### Worker results (Google Ads MCP server, 29-tool benchmark)

| Model | Tool-call accuracy | Param correctness | GAQL validity | Latency P95 | Cost/call |
|---|---|---|---|---|---|
| **Claude Sonnet 4** | **97%** | **95%** | **94%** | **1,400ms** | **$0.008** |
| Claude Haiku 4 | 88% | 82% | 76% | 600ms | $0.002 |
| GPT-4o-mini | 84% | 79% | 71% | 500ms | $0.001 |
| Gemini 2.5 Flash | 82% | 78% | 68% | 450ms | $0.001 |

### Critical failure analysis

| Model | Failure type | Frequency | Severity |
|---|---|---|---|
| GPT-4o (orchestrator) | Skipped CEP confirmation on 1 write operation | 4% of write tests | **Critical** — unauthorized mutation |
| Gemini 2.5 Pro (orchestrator) | Skipped CEP confirmation on 2 write operations | 8% of write tests | **Critical** — unauthorized mutation |
| Claude Haiku 4 (worker) | Hallucinated customer_id parameter | 18% of tests | High — API errors |
| GPT-4o-mini (worker) | Generated invalid GAQL syntax | 29% of tests | High — API errors |

---

## Decision outcome

**Chosen models:**
- **Orchestrator:** Claude Sonnet 4 (`claude-sonnet-4-20250514`)
- **Workers:** Claude Sonnet 4 (`claude-sonnet-4-20250514`)

**Rationale:** CEP compliance is non-negotiable — a model that auto-executes a write operation even once in testing is disqualified for production use where real ad budgets are at stake. Both GPT-4o and Gemini 2.5 Pro failed CEP compliance (96% and 92% respectively). Claude Opus 4 achieved 100% CEP compliance with marginally better routing, but at 3.8× the cost of Sonnet — the 3-point routing accuracy improvement doesn't justify the cost increase at 500 queries/day.

For workers, Claude Sonnet 4 was the only model that achieved >90% on all three accuracy metrics (tool-call, param correctness, GAQL validity). Haiku's 18% customer_id hallucination rate and GPT-4o-mini's 29% GAQL syntax failure rate would cause unacceptable error volumes in production.

Using the same model family for both tiers simplifies deployment, prompt engineering, and debugging.

---

## Configuration

```yaml
# Orchestrator
orchestrator:
  model: "claude-sonnet-4-20250514"
  temperature: 0.0
  max_tokens: 4096
  tools: [Task, Read, Write]

# Workers (all 14 MCP servers)
workers:
  model: "claude-sonnet-4-20250514"
  temperature: 0.0
  max_tokens: 2048
  transport: stdio  # HTTP for remote deployment
```

---

## Cost projection

| Scenario | Orchestrator | Workers | Total/query | Daily (500 queries) | Monthly |
|---|---|---|---|---|---|
| Single-platform read | $0.018 | $0.008 × 1 | $0.026 | $13.00 | $390 |
| Cross-platform (3 platforms) | $0.018 | $0.008 × 3 | $0.042 | $21.00 | $630 |
| Full portfolio (14 platforms) | $0.018 | $0.008 × 14 | $0.130 | $65.00 | $1,950 |
| **Weighted average** (70/20/10 split) | — | — | **$0.034** | **$17.00** | **$510** |

**Note:** Full-portfolio queries ($0.130) exceed the $0.10 ceiling. This is acceptable because they represent <10% of traffic. Weighted average of $0.034 is well under ceiling.

---

## Mandatory review triggers

- [ ] Anthropic releases Claude Sonnet 5 — re-run full eval suite
- [ ] Monthly cost exceeds $1,500 for two consecutive months
- [ ] CEP compliance drops below 100% on any model update (immediate review)
- [ ] Tool-call accuracy drops below 90% on quarterly eval
- [ ] Competitor model achieves ≥95% tool-call accuracy at <50% cost
- [ ] Scheduled review: 2026-Q3

---

## Rejected candidates

### Claude Opus 4 (orchestrator)
**Rejected because:** 3.8× cost of Sonnet ($0.068 vs $0.018 per query) for marginal improvement: 96% vs 93% routing accuracy, identical 100% CEP compliance. At 500 queries/day, Opus adds ~$9,000/year in operating cost for a 3-point accuracy improvement. Not justified.

### GPT-4o (orchestrator)
**Rejected because:** 96% CEP compliance means the model skipped human approval and auto-executed a write operation in 4% of write tests. In advertising, an unauthorized budget change or campaign pause has immediate financial consequences. 96% is not acceptable — the requirement is 100%.

### Gemini 2.5 Pro (orchestrator)
**Rejected because:** 92% CEP compliance — worse than GPT-4o. Additionally, 80% cross-platform routing accuracy means 1 in 5 multi-platform queries gets routed incorrectly.

### Claude Haiku 4 (workers)
**Rejected because:** 18% customer_id hallucination rate. When a worker fabricates a Google Ads customer ID, the API returns a cryptic error that the user cannot diagnose. At 500 queries/day, this means ~90 confusing errors daily. Not viable.

---

## Consequences

**Positive:**
- 100% CEP compliance means zero risk of unauthorized ad mutations
- Single model family simplifies prompt engineering, debugging, and deployment
- $0.034 average cost per query provides 66% headroom below the $0.10 ceiling
- Same model for orchestrator and workers means a Sonnet upgrade improves the entire system

**Negative:**
- Sonnet is 4× more expensive than Haiku for worker calls — if traffic scales beyond 2,000 queries/day, re-evaluate Haiku with improved prompts
- Vendor lock-in on Anthropic — if Anthropic has an outage, entire system is down (mitigated by HTTP transport allowing future multi-vendor routing)

---

*Production example — contributed by John Williams ([itallstartedwithaidea](https://github.com/itallstartedwithaidea)) — BHIL AI-First Development Toolkit*
