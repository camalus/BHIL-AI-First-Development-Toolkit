---
id: ADR-001
title: "Use Claude Sonnet 4 for RAG chat response generation"
status: accepted
type: model-selection
date: 2026-03-26
decision_makers: [Barry Hurd]
related_prds: [PRD-001]
related_specs: [SPEC-001]
sprint: S-01
prompt_version: PV-001
review_trigger: "2026-Q3"
tags: [llm, model-selection, rag, cost]
---

# ADR-001: Use Claude Sonnet 4 for RAG Chat Response Generation

## Context and problem statement

The RAG-powered enterprise knowledge chat feature (PRD-001) requires a language model to synthesize retrieved document chunks into accurate, cited responses. The model must handle domain-specific enterprise content, follow strict citation instructions, and stay within a 5-second P95 latency budget and $0.05 per-query cost ceiling. Three Anthropic models were evaluated; the choice has significant cost and quality implications at production scale.

**Decision question:** Which Anthropic model should power response generation for the RAG chat feature given requirements of ≥0.85 faithfulness, P95 < 5,000ms, and ≤$0.05/query at 1K queries/day?

---

## Decision drivers

- **Faithfulness:** ≥0.85 RAGAS faithfulness score — responses must be grounded in retrieved context with no hallucination
- **Latency:** P95 total response time < 5,000ms (including retrieval); streaming first token < 1,000ms
- **Cost:** ≤$0.05/query at 1,000 queries/day = ≤$50/day operating cost
- **Citation following:** Must reliably follow structured citation format instructions
- **Context length:** Must support 32K+ tokens (retrieved chunks + conversation)

---

## Candidates evaluated

| Model | Provider | Context | Input ($/1M) | Output ($/1M) | Latency P95 |
|---|---|---|---|---|---|
| Claude Sonnet 4 | Anthropic | 200K | $3.00 | $15.00 | 2,800ms |
| Claude Haiku 4.5 | Anthropic | 200K | $0.80 | $4.00 | 1,100ms |
| Claude Opus 4 | Anthropic | 200K | $15.00 | $75.00 | 4,200ms |

---

## Evaluation results

### Evaluation methodology

- **Eval dataset:** `evals/golden/rag-chat-model-selection.jsonl` (50 enterprise Q&A pairs)
- **Evaluation method:** RAGAS (faithfulness, context precision, answer relevance)
- **Temperature:** 0.1 (fixed across all models)
- **Prompt version:** PV-001 (identical prompt used for all candidates)
- **Retrieved context:** 5 chunks per query (k=5), average 800 tokens per chunk

### Results

| Model | Faithfulness | Context Precision | Answer Relevance | Latency P95 | Cost/1K queries |
|---|---|---|---|---|---|
| **Claude Sonnet 4 ✓** | **0.91** | **0.82** | **0.88** | **2,800ms** | **$18.00** |
| Claude Haiku 4.5 | 0.74 | 0.71 | 0.79 | 1,100ms | $4.80 |
| Claude Opus 4 | 0.93 | 0.85 | 0.91 | 4,200ms | $90.00 |

### Failure mode analysis

| Model | Primary failure mode | Frequency | Impact |
|---|---|---|---|
| Claude Sonnet 4 | Occasionally adds hedge language not requested | 8% of runs | Low — acceptable |
| Claude Haiku 4.5 | Generates plausible but ungrounded claims | 26% of runs | High — violates faithfulness requirement |
| Claude Opus 4 | Exceeds P95 latency under load (4,200ms) | Baseline | High — violates latency requirement |

---

## Decision outcome

**Chosen model: Claude Sonnet 4 (claude-sonnet-4-20250514)**

**Rationale:** Claude Sonnet 4 achieves a faithfulness score of 0.91 — exceeding the ≥0.85 requirement — while staying within the 5,000ms latency budget (P95: 2,800ms) and the $0.05/query cost ceiling ($0.018/query at the 1,000 query/day volume). Claude Haiku 4.5 was 73% cheaper but failed the faithfulness requirement (0.74 vs. ≥0.85), generating ungrounded claims in 26% of test cases. Claude Opus 4 achieved marginally higher faithfulness (0.93) but exceeded the latency budget under load and was 5× more expensive.

---

## Configuration

```yaml
model: "claude-sonnet-4-20250514"
temperature: 0.1
max_tokens: 1024
top_p: 0.95
stream: true

# Cost controls
max_retries: 2
timeout_ms: 8000
fallback_model: "claude-haiku-4-5-20251001"  # Cheaper fallback on timeout
```

---

## Cost projection

| Volume | Input tokens/req | Output tokens/req | Cost/request | Monthly cost |
|---|---|---|---|---|
| MVP (1K req/day) | ~4,200 | ~450 | $0.0194 | $582 |
| Growth (5K req/day) | ~4,200 | ~450 | $0.0194 | $2,910 |
| Scale (20K req/day) | ~4,200 | ~450 | $0.0194 | $11,640 |

**Cost optimization:** Prompt caching enabled for system prompt (saves ~$0.003/request at full prompt cache hit rate). Estimated 40% of requests will benefit from caching.

---

## Acceptance criteria

- [x] Eval suite achieves faithfulness ≥0.85 on 50-case golden dataset (actual: 0.91)
- [x] P95 latency < 5,000ms measured on staging traffic sample (actual: 2,800ms)
- [x] Cost per query ≤ $0.05 at 1,000 queries/day (actual: $0.019)
- [x] Fallback model configured and timeout tested

---

## Rejected candidates

### Claude Haiku 4.5
**Rejected because:** Faithfulness score of 0.74 violates the ≥0.85 requirement. In 26% of test cases, Haiku generated responses containing claims not supported by the retrieved context — a hallucination rate unacceptable for enterprise knowledge management where accuracy is a trust requirement. The 73% cost saving does not outweigh the faithfulness failure.

### Claude Opus 4
**Rejected because:** P95 latency of 4,200ms exceeds the 5,000ms budget by a small margin and would violate it under load. More critically, at $0.090/query ($0.05 ceiling), Opus exceeds the cost constraint by 80%, making it economically non-viable at production scale. The marginal quality improvement (0.93 vs. 0.91 faithfulness) does not justify the cost.

---

## Consequences

**Positive:**
- Faithfulness of 0.91 comfortably exceeds the ≥0.85 requirement with 6-point headroom
- Latency of 2,800ms P95 provides 2,200ms buffer against the 5,000ms SLA
- Cost of $0.019/query is 62% below the $0.05 ceiling, giving room for context length growth

**Negative:**
- Sonnet is 4× more expensive than Haiku — if volume exceeds projections, cost escalates faster
- Fallback to Haiku on timeout degrades quality — monitor fallback rate; if >5% triggers review

---

## Mandatory review triggers

- [ ] Monthly LLM cost exceeds $15,000 for two consecutive months (triggers Haiku re-evaluation with improved prompt)
- [ ] Faithfulness score drops below 0.82 following a model update
- [ ] Latency P95 exceeds 4,000ms on production traffic for 3+ consecutive days
- [ ] Anthropic releases Claude Sonnet 5 with published benchmark improvements ≥10%
- [ ] Scheduled review: 2026-Q3

---

## Related decisions

- **Prompt strategy:** ADR-002
- **RAG architecture (embedding model + retrieval):** ADR-003
- **Agent orchestration:** N/A (single LLM call, not orchestrated)

---

*Example — BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
