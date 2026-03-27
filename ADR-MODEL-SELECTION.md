---
# === TRACEABILITY METADATA ===
id: ADR-NNN
title: "Use [Model Name] for [Capability/Feature]"
status: proposed           # proposed | accepted | deprecated | superseded
type: model-selection      # Identifies this as an AI-native ADR type
date: YYYY-MM-DD
decision_makers: [name]
related_prds: [PRD-NNN]
related_specs: [SPEC-NNN]
sprint: S-NN
review_trigger: "YYYY-QN"  # Mandatory for model decisions — models change fast
tags: [llm, model-selection, cost, latency]
---

# ADR-NNN: Use [Model Name] for [Capability/Feature]

## Context and problem statement

[2–3 sentences. Describe the LLM-powered capability being built, the performance and cost requirements, and why model selection is a significant architectural decision for this feature.]

**Decision question:** Which LLM should power [capability] given the requirements of [latency / quality / cost / privacy]?

---

## Decision drivers

<!--
Quantified. "Good quality" is not a driver — "≥0.85 factuality score on domain-specific eval" is.
-->

- **Quality:** [e.g., Factuality score ≥0.85 on our 50-case legal document eval set]
- **Latency:** [e.g., P95 time-to-first-token < 500ms; total generation < 3000ms]
- **Cost:** [e.g., ≤$0.02 per request at 100K requests/day = ≤$2,000/day budget]
- **Context:** [e.g., Must support 128K context window for full document analysis]
- **Privacy:** [e.g., Must not send PII to third-party APIs — requires on-premise or zero-data-retention]
- **Reliability:** [e.g., ≥99.5% uptime SLA required]

---

## Candidates evaluated

| Model | Provider | Context | Input ($/1M) | Output ($/1M) | Latency P95 |
|---|---|---|---|---|---|
| [Model A] | [Provider] | [Xk] | $[X.XX] | $[X.XX] | [X]ms |
| [Model B] | [Provider] | [Xk] | $[X.XX] | $[X.XX] | [X]ms |
| [Model C] | [Provider] | [Xk] | $[X.XX] | $[X.XX] | [X]ms |

---

## Evaluation results

<!--
Task-specific benchmark results — NOT general benchmarks.
Run your actual prompt on your actual eval dataset.
Minimum 20 test cases for meaningful comparison.
-->

### Evaluation methodology

- **Eval dataset:** `evals/golden/[capability]-selection-eval.jsonl` ([N] cases)
- **Evaluation method:** [LLM-as-judge using Claude Sonnet / RAGAS / human review]
- **Temperature:** [X.X] (fixed across all models for comparability)
- **Prompt version:** PV-NNN (identical prompt used for all candidates)

### Results

| Model | Factuality | Relevance | Latency P95 | Cost/1K req |
|---|---|---|---|---|
| **[Model A] ✓** | **[0.XX]** | **[0.XX]** | **[X]ms** | **$[X.XX]** |
| [Model B] | [0.XX] | [0.XX] | [X]ms | $[X.XX] |
| [Model C] | [0.XX] | [0.XX] | [X]ms | $[X.XX] |

### Failure mode analysis

| Model | Primary failure mode | Frequency | Impact |
|---|---|---|---|
| [Model A] | [e.g., Verbose responses, hallucinated citations] | [X]% of runs | [Low/Med/High] |
| [Model B] | [e.g., Refused borderline queries] | [X]% of runs | [Low/Med/High] |

---

## Decision outcome

**Chosen model: [Model Name] ([Provider])**

**Rationale:** [Model A] achieves the highest [primary metric] score ([X.XX]) on our domain-specific eval set while meeting the latency requirement (P95: [X]ms) and staying within cost budget ($[X.XX]/request vs. $[X.XX] budget). [Model B] performed [X.XX]% better on [secondary metric] but exceeded the latency requirement at [X]ms P95.

---

## Configuration

```yaml
# Exact configuration to use — no ambiguity for implementation
model: "[exact model identifier string]"
temperature: [X.X]
max_tokens: [NNNN]
top_p: [X.X]
stop_sequences: ["[stop token if any]"]
stream: true | false

# Cost controls
max_retries: 3
timeout_ms: [NNNN]
fallback_model: "[cheaper/faster model for timeout scenarios]"
```

---

## Cost projection

| Volume | Input tokens/req | Output tokens/req | Cost/request | Monthly cost |
|---|---|---|---|---|
| MVP (1K req/day) | [N] | [N] | $[X.XXXX] | $[XX] |
| Growth (10K req/day) | [N] | [N] | $[X.XXXX] | $[XXX] |
| Scale (100K req/day) | [N] | [N] | $[X.XXXX] | $[X,XXX] |

**Cost optimization note:** [Any token reduction strategies — prompt compression, output length limits, caching strategy]

---

## Acceptance criteria for this decision

- [ ] Eval suite passes at threshold (≥[X.XX] [metric] across [N] runs) in CI
- [ ] P95 latency < [X]ms measured on production traffic sample
- [ ] Daily cost stays within $[X] budget at current volume
- [ ] Fallback model configured and tested

---

## Rejected candidates

### [Model B]
**Rejected because:** [Specific reason tied to decision drivers — e.g., "P95 latency of [X]ms exceeds the [X]ms requirement, and the quality improvement ([X.XX] vs [X.XX] on factuality) does not justify the latency cost for our interactive use case."]

### [Model C]
**Rejected because:** [e.g., "Privacy requirement prohibits sending customer data to third-party APIs. [Model C]'s API terms do not include a zero-data-retention agreement."]

---

## Consequences

**Positive:**
- [Concrete benefit with metric, e.g., "Factuality of [X.XX] meets the ≥0.85 requirement"]
- [Cost benefit at expected volume]

**Negative:**
- [Accepted tradeoff, e.g., "Token cost is [X]× more expensive than [cheaper model] — acceptable at current scale, triggers review at 10× volume"]
- [Known limitation, e.g., "Model occasionally over-formats responses — prompt v1.1 includes explicit formatting instructions to mitigate"]

---

## Mandatory review triggers

This decision **must** be revisited when:
- [ ] Monthly LLM cost exceeds $[threshold] for two consecutive months
- [ ] P95 latency exceeds [X]ms on production traffic for 3+ consecutive days
- [ ] Eval score drops below [X.XX] following a model update
- [ ] Provider releases a new model version with published benchmark improvements ≥15%
- [ ] Scheduled review: [YYYY-QN]
- [ ] Privacy or compliance requirements change

**Next scheduled review:** [YYYY-QN]

---

## Related decisions

- **Prompt strategy:** [ADR-NNN]
- **Agent orchestration:** [ADR-NNN]
- **RAG architecture:** [ADR-NNN if applicable]

---

*Template version 1.0 — BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
