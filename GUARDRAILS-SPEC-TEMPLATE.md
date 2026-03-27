---
id: GUARDRAILS-NNN
title: "[Feature/System] Safety and Guardrails Specification"
status: draft
date: YYYY-MM-DD
feature: [PRD-NNN / SPEC-NNN]
sprint: S-NN
risk_level: high           # high | medium | low
external_facing: true      # true if user-accessible
---

# Guardrails Specification: [Feature/System Name]

## Risk profile

**Risk level:** [High / Medium / Low]
**Rationale:** [Why this risk level — e.g., "Customer-facing LLM with access to internal data"]

**What can go wrong (threat model):**
- [Threat 1: e.g., Prompt injection allowing system prompt extraction]
- [Threat 2: e.g., Model hallucinating factual claims that damage user trust]
- [Threat 3: e.g., PII leakage from retrieval context into responses]
- [Threat 4: e.g., Cost runaway from adversarial users sending large inputs]

---

## Layer 1: Input guardrails

*Applied before user input reaches the LLM.*

### 1.1 Content validation

| Check | Method | Action on violation | Latency |
|---|---|---|---|
| Prompt injection detection | Regex + neural classifier | Reject with `INVALID_INPUT` error | <50ms |
| Input length limit | Character count | Truncate to [N] chars or reject | <1ms |
| Topic boundary | [Classifier / keyword list] | Reject with `OUT_OF_SCOPE` error | [X]ms |
| PII detection | [Library: e.g., Presidio] | [Redact / Reject / Log] | [X]ms |
| Language filter | [Library] | [Accept / Reject non-[language]] | [X]ms |

**Implementation:**
```typescript
// Location: src/guardrails/input-validator.ts

async function validateInput(input: string): Promise<ValidationResult> {
  // 1. Length check (synchronous, first)
  if (input.length > [N]) return { valid: false, code: 'INPUT_TOO_LONG' };
  
  // 2. Prompt injection (fast regex patterns)
  if (INJECTION_PATTERNS.test(input)) return { valid: false, code: 'INJECTION_DETECTED' };
  
  // 3. PII detection (async, before any logging)
  const piiResult = await detectPII(input);
  if (piiResult.hasPII) {
    if ([POLICY] === 'redact') input = piiResult.redactedText;
    else return { valid: false, code: 'PII_DETECTED' };
  }
  
  return { valid: true, sanitizedInput: input };
}
```

### 1.2 Rate limiting

| Scope | Limit | Window | Action |
|---|---|---|---|
| Per user | [N] requests | Per minute | 429 Too Many Requests |
| Per session | [N] tokens | Per session | Terminate session |
| Global | [N] requests | Per minute | 503 Service Unavailable |

---

## Layer 2: Output guardrails

*Applied before LLM output reaches the user.*

### 2.1 Quality checks

| Check | Method | Threshold | Action on violation |
|---|---|---|---|
| Toxicity | [Perspective API / Detoxify] | Score < 0.1 | Block output, return fallback |
| Factuality (RAG) | NLI verification vs. context | Entailment ≥ 0.75 | Flag for review or block |
| Output schema | JSON schema validation | 100% compliance | Retry once, then error |
| Length | Token count | ≤ [N] tokens | Truncate with notice |
| PII in output | [Presidio / custom] | Zero PII leakage | Redact before returning |

**Implementation:**
```typescript
// Location: src/guardrails/output-validator.ts

async function validateOutput(
  output: string,
  retrievedContext?: string[]
): Promise<ValidationResult> {
  // 1. Toxicity (always run)
  const toxicity = await checkToxicity(output);
  if (toxicity.score > 0.1) return { valid: false, code: 'TOXIC_OUTPUT' };
  
  // 2. PII in output
  const pii = await detectPII(output);
  if (pii.hasPII) output = pii.redactedText;
  
  // 3. Factuality check (only for RAG-grounded responses)
  if (retrievedContext) {
    const faithfulness = await checkFaithfulness(output, retrievedContext);
    if (faithfulness < 0.75) return { valid: false, code: 'HALLUCINATION_DETECTED' };
  }
  
  // 4. Schema validation (if structured output required)
  if (REQUIRES_SCHEMA) {
    const schemaValid = validateSchema(output, OUTPUT_SCHEMA);
    if (!schemaValid) return { valid: false, code: 'SCHEMA_VIOLATION' };
  }
  
  return { valid: true, sanitizedOutput: output };
}
```

### 2.2 Fallback responses

| Violation code | User-facing message | Internal action |
|---|---|---|
| `TOXIC_OUTPUT` | "I'm unable to provide that response. Please try rephrasing." | Log with full context |
| `HALLUCINATION_DETECTED` | "I don't have enough information to answer that accurately." | Log + alert |
| `SCHEMA_VIOLATION` | "An error occurred. Please try again." | Retry once, then alert |
| `INJECTION_DETECTED` | "That input cannot be processed." | Log IP + rate limit |

---

## Layer 3: Tool and action guardrails

*Applied when the LLM has access to tools or can take actions. Skip if feature is response-only.*

### 3.1 Tool allowlist

| Tool | Permitted roles | Requires approval | Max calls/session |
|---|---|---|---|
| `web_search` | All users | No | [N] |
| `read_file` | Authenticated users | No | [N] |
| `write_file` | Authenticated users | Yes (human-in-loop) | [N] |
| `delete_[resource]` | Admin only | Yes (human-in-loop) | [N] |
| `call_external_api` | Authenticated users | No | [N] |

### 3.2 Human-in-the-loop requirements

The following actions **must** pause for explicit human approval before execution:
- [ ] [Action 1: e.g., "Any database write operation affecting > [N] records"]
- [ ] [Action 2: e.g., "External API calls that incur cost > $[X]"]
- [ ] [Action 3: e.g., "File system operations outside /tmp/"]

### 3.3 Audit logging

All tool invocations must be logged with:
```json
{
  "timestamp": "ISO-8601",
  "user_id": "string",
  "session_id": "string",
  "tool_name": "string",
  "tool_input": "[sanitized — PII redacted]",
  "tool_output_preview": "[first 200 chars — sanitized]",
  "approved_by": "user | system | [human reviewer ID]",
  "cost_tokens": "integer"
}
```

---

## Latency budget

Total guardrail overhead target: < [X]ms added to P95 response time

| Guardrail | Method | Target latency | Priority |
|---|---|---|---|
| Input length check | Synchronous | <1ms | Always |
| Injection regex | Synchronous | <5ms | Always |
| PII detection (input) | Async | [X]ms | Always |
| Toxicity (output) | Neural | [X]ms | Always |
| Factuality check | LLM-as-judge | [X]ms | RAG only |
| Schema validation | Sync | <5ms | Structured output |
| **Total** | — | **<[X]ms** | — |

If actual latency exceeds budget, prioritize: Safety → Accuracy → Quality (drop quality checks first under load).

---

## Acceptance criteria

- [ ] Prompt injection test suite: [N]/[N] injection attempts blocked (0% bypass rate)
- [ ] Toxicity: 0 toxic outputs in [N]-case safety eval set
- [ ] PII: 0 PII leakage instances in [N]-case privacy eval set
- [ ] Factuality: Hallucination detection catches ≥[X]% of injected hallucinations
- [ ] Latency: Guardrail overhead < [X]ms P95 (measured in load test)
- [ ] Schema: 100% of outputs validate against schema

---

## Monitoring in production

| Metric | Alert threshold | Alert channel |
|---|---|---|
| Injection detection rate | > [X]% of requests | [Slack channel / PagerDuty] |
| Toxicity block rate | > [X]% of requests | [Slack channel] |
| Hallucination detection rate | > [X]% of RAG responses | [Slack channel] |
| Guardrail latency P95 | > [X]ms | [PagerDuty] |
| Error rate (all guardrails) | > [X]% | [PagerDuty] |

---

*Template version 1.0 — BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
