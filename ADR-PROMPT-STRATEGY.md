---
id: ADR-NNN
title: "Use [Strategy Name] prompting for [Capability]"
status: proposed
type: prompt-strategy
date: YYYY-MM-DD
decision_makers: [name]
related_prds: [PRD-NNN]
related_specs: [SPEC-NNN]
related_adrs: [ADR-NNN]   # Model selection ADR for this capability
sprint: S-NN
prompt_version: PV-NNN    # The prompt version this ADR governs
review_trigger: "YYYY-QN"
tags: [prompt-engineering, llm, strategy]
---

# ADR-NNN: Use [Strategy] Prompting for [Capability]

## Context and problem statement

[2–3 sentences describing the LLM task, the quality requirements, and why the prompting strategy is a meaningful architectural decision worth documenting.]

**Decision question:** What prompting strategy should be used for [capability] to achieve ≥[X.XX] [quality metric] while staying within the [latency/cost] constraints?

---

## Decision drivers

- **Quality target:** [e.g., Factuality ≥0.85 on 50-case eval set]
- **Latency constraint:** [e.g., Total prompt + generation < 3000ms P95]
- **Cost constraint:** [e.g., ≤[X] tokens per request at expected volume]
- **Output format:** [e.g., Structured JSON matching schema at SPEC-NNN §API Contracts]
- **Consistency:** [e.g., Format must be identical across all runs for downstream parsing]

---

## Strategies evaluated

| Strategy | Description | Avg eval score | Avg tokens | Notes |
|---|---|---|---|---|
| Zero-shot | No examples, direct instruction | [0.XX] | [N] | [Observation] |
| Few-shot ([N]-shot) | [N] examples in prompt | [0.XX] | [N] | [Observation] |
| Chain-of-thought | Explicit reasoning steps | [0.XX] | [N] | [Observation] |
| RAG-augmented | Retrieved context + instruction | [0.XX] | [N] | [Observation] |
| ReAct | Reasoning + action loop | [0.XX] | [N] | [Observation] |

---

## Chosen strategy: [Strategy Name]

**Rationale:** [Strategy X] achieves [score] on the eval set, exceeding the ≥[X.XX] threshold, with [N] tokens per request meeting the cost constraint. [Key differentiating observation — e.g., "Few-shot examples were critical: zero-shot achieved only [X.XX] because the output format is non-standard and requires demonstration."]

---

## Prompt specification

### Prompt version: [PV-NNN]

**File locations:**
- System prompt: `project/prompts/v[N]/system-prompt.md`
- User template: `project/prompts/v[N]/user-template.md`
- Few-shot examples: `project/prompts/v[N]/few-shot-examples.json`

**System prompt structure:**
```markdown
# Role
[Persona and capability framing]

# Instructions
[Numbered, specific instructions — no prose paragraphs]
1. [Instruction]
2. [Instruction]

# Output format
[Exact schema or format specification]

# Constraints
- [Hard constraint — always follow]
- [Hard constraint — always follow]
```

**User template:**
```
{{context_if_any}}

User input: {{user_input}}

[Any additional framing or output reminders]
```

**Few-shot examples structure (if used):**
```json
[
  {
    "input": "[Example input]",
    "output": "[Ideal output matching exact format]",
    "explanation": "[Why this is ideal — for documentation, not sent to model]"
  }
]
```

---

## Versioning policy

| Event | Version bump | Action required |
|---|---|---|
| Output format change | Major (1.0 → 2.0) | New eval suite run; update all downstream consumers |
| New few-shot examples | Minor (1.0 → 1.1) | Re-run eval suite; update PROMPT-REGISTRY.md |
| Wording clarification | Patch (1.0 → 1.0.1) | Spot-check 10 cases; update PROMPT-REGISTRY.md |

**Version freeze policy:** Once a prompt version is deployed to production, it is **immutable**. Changes create a new version. No exceptions.

---

## Evaluation dataset

- **Dataset location:** `evals/golden/[capability].jsonl`
- **Dataset size:** [N] curated examples (minimum 50 for production features)
- **Dataset composition:** [Describe the distribution — e.g., "30% typical queries, 40% edge cases, 30% adversarial inputs"]
- **Eval method:** [LLM-as-judge / RAGAS / embedding similarity / human review]
- **Pass threshold:** [Metric] ≥ [X.XX] across all [N] cases

**Adding to the dataset:**
- Add examples whenever a production failure is discovered
- Add adversarial examples from red-teaming sessions
- Never modify existing examples — add new ones with `_v[N]` suffix if replacing

---

## Acceptance criteria

- [ ] Eval suite passes at threshold ([metric] ≥ [X.XX]) in CI via `npx promptfoo eval`
- [ ] Prompt version registered in `project/prompts/PROMPT-REGISTRY.md`
- [ ] Output format validated by JSON schema on [N]% of test cases
- [ ] No jailbreak vulnerability in adversarial test set (all [N] red-team cases rejected)

---

## Rejected strategies

### [Strategy B: Chain-of-thought]
**Rejected because:** CoT increased token consumption by [X]× and exceeded the [X]ms latency budget (measured P95: [X]ms vs. budget [X]ms), without a meaningful quality improvement ([X.XX] vs. [X.XX] on factuality).

### [Strategy C: RAG-augmented]
**Rejected because:** This capability does not benefit from external knowledge retrieval — all relevant context is provided in the user input. RAG added [X]ms latency and [N] tokens without improving eval scores. Revisit if [specific scenario that would change this].

---

## Consequences

**Positive:**
- [Specific quality benefit with metric]
- [Cost or latency benefit with metric]

**Negative:**
- [Accepted limitation, e.g., "N-shot prompting adds [X] tokens per request — monitoring in place for cost impact"]
- [Known failure mode, e.g., "Model occasionally ignores output format instructions on inputs > [X] tokens — output validation guardrail catches this"]

---

## Review triggers

Revisit this decision when:
- [ ] Eval score drops below [X.XX] following model update
- [ ] Latency target changes (would enable or eliminate CoT)
- [ ] New few-shot technique (e.g., dynamic few-shot via RAG) becomes viable
- [ ] Scheduled review: [YYYY-QN]

---

## Related decisions

- **Model selection:** [ADR-NNN]
- **Agent orchestration:** [ADR-NNN if applicable]
- **Guardrails:** [ADR-NNN if applicable]

---

*Template version 1.0 — BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
