---
# === TRACEABILITY METADATA ===
id: PRD-NNN
title: "[Feature name — 5 words max]"
status: draft              # draft | in-review | approved | complete
date: YYYY-MM-DD
author: [Your name]
sprint: S-NN
priority: high             # high | medium | low
children:                  # Populated after SPEC creation
  - SPEC-NNN
adrs: []                   # Populated as ADRs are created
---

# PRD-NNN: [Feature Name]

## Problem statement

<!--
One sentence. Describe the gap or pain point — no solution hints.
Format: "[User type] cannot [accomplish goal] because [root cause]."
-->

[User type] cannot [accomplish goal] because [specific barrier or gap].

---

## User stories (EARS format)

<!--
EARS patterns:
- Event-driven:    WHEN [trigger], the system SHALL [response]
- State-driven:    WHILE [condition], the system SHALL [response]
- Unwanted:        IF [error condition], THEN the system SHALL [response]
- Complex:         WHILE [precondition], WHEN [trigger], the system SHALL [response]

Each story gets an ID for traceability to acceptance criteria.
-->

**US-001:**
WHEN [trigger], the system SHALL [response].

**US-002:**
WHILE [condition], the system SHALL [response].

**US-003:**
IF [error condition], THEN the system SHALL [fallback behavior].

---

## Success metrics

<!--
Quantified measures of whether this feature succeeded.
Must be measurable without human judgment. No "improves" without a number.
-->

| Metric | Baseline | Target | Measurement method |
|---|---|---|---|
| [Metric name] | [Current value] | [Goal value] | [How measured] |
| [Metric name] | [Current value] | [Goal value] | [How measured] |

**For AI-native features, add:**

| AI Quality Metric | Threshold | N Runs | Evaluation method |
|---|---|---|---|
| [Factuality / Relevance / etc.] | ≥ [X.XX] | [N] | [LLM-judge / RAGAS / embedding] |
| [Latency P95] | < [Xms] | N/A | Wall clock |

---

## Non-functional requirements

<!--
Constraints that apply across all user stories.
Be specific — "fast" is not a requirement; "<200ms P95" is.
-->

- **Performance:** [e.g., P95 response time < 200ms under 500 concurrent users]
- **Availability:** [e.g., 99.9% uptime in business hours]
- **Security:** [e.g., All inputs validated; no PII stored beyond session]
- **Cost:** [e.g., Estimated LLM cost ≤ $0.02 per user request at 100K requests/day]

---

## Out of scope

<!--
Explicit exclusions. Prevents scope creep and agent hallucination.
List things that might seem related but are NOT part of this feature.
-->

The following are explicitly NOT part of this feature:
- [Exclusion 1]
- [Exclusion 2]
- [Exclusion 3]

---

## Constraints and assumptions

<!--
Constraints: non-negotiable limits.
Assumptions: things believed to be true that would invalidate this PRD if wrong.
-->

**Constraints:**
- [e.g., Must use existing authentication system — no new auth flows]
- [e.g., No new external API dependencies without architecture review]

**Assumptions:**
- [e.g., Users have JavaScript enabled in browser]
- [e.g., Average user query is < 500 tokens]

---

## Dependencies

| Dependency | Type | Status |
|---|---|---|
| [Service / ADR / Feature] | Internal / External / ADR | [Available / In progress / Blocked] |

---

## Open questions

<!--
Questions that must be resolved before this PRD is approved.
Delete this section when all questions are resolved.
-->

- [ ] [Question 1] — Owner: [Name], Due: [Date]
- [ ] [Question 2] — Owner: [Name], Due: [Date]

---

## Approval checklist

Before setting `status: approved`:
- [ ] Problem statement is one sentence with no solution hints
- [ ] All user stories use EARS format
- [ ] Success metrics are quantified
- [ ] Out-of-scope items are listed
- [ ] All open questions are resolved
- [ ] No implementation details appear in this document

---

*Template version 1.0 — BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
