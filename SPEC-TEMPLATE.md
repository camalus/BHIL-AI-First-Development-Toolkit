---
# === TRACEABILITY METADATA ===
id: SPEC-NNN
title: "[Technical spec title matching PRD]"
status: draft              # draft | in-review | approved | complete
date: YYYY-MM-DD
parent: PRD-NNN
sprint: S-NN
adrs: []                   # Populated as ADRs are written
tasks: []                  # Populated after task decomposition
---

# SPEC-NNN: [Feature Name] — Technical Specification

## Specification summary

<!--
2–3 sentences connecting the PRD's "what" to this spec's "how."
State the chosen approach without re-explaining the business need.
-->

This specification describes the implementation of [PRD-NNN feature] using [chosen approach].
The implementation introduces [key component/pattern] and modifies [affected existing components].

---

## Architecture overview

<!--
System context: how this feature fits into the broader system.
Include a text-based C4 diagram if the feature introduces new components.
-->

```
[Existing Component A] ──→ [New Component: Feature Module] ──→ [Existing Component B]
                                    ↓
                         [New Component: Data Store]
```

**New components introduced:**
- `[ComponentName]` — [single-line description of responsibility]

**Existing components modified:**
- `[ComponentName]` — [what changes and why]

**Architectural decisions governing this feature:**
- [ADR-NNN: Decision title] — [one-line impact on this feature]

---

## API contracts

<!--
Exact request/response schemas. No ambiguity.
Use JSON Schema for complex payloads.
For AI-native features: include the expected prompt interface.
-->

### [Endpoint or function name]

**Request:**
```json
{
  "field_name": "string",          // required — [description]
  "optional_field": "integer",     // optional — [description], default: [value]
  "enum_field": "value_a | value_b" // required — [description]
}
```

**Response (success — 200):**
```json
{
  "id": "string",
  "result": "string",
  "metadata": {
    "processing_time_ms": "integer"
  }
}
```

**Response (error — 4xx/5xx):**
```json
{
  "error": "string",
  "code": "ERROR_CODE",
  "details": "string | null"
}
```

**For AI-native features — prompt interface:**
```markdown
System prompt version: PV-NNN (see project/prompts/v1/system-prompt.md)
User template: "{{user_input}}" — max 2000 tokens
Expected output format: [structured | free text | JSON schema at path X]
```

---

## Data models

<!--
Exact field definitions. Types, constraints, defaults, and indexes.
For AI features: include embedding dimensions and vector store schema.
-->

### [Model name]

| Field | Type | Constraints | Description |
|---|---|---|---|
| `id` | UUID | NOT NULL, PRIMARY KEY | Unique identifier |
| `[field]` | [type] | [constraints] | [description] |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation timestamp |

**For vector/embedding storage:**
| Field | Type | Dimensions | Index |
|---|---|---|---|
| `embedding` | VECTOR | [NNN] | HNSW, cosine similarity |
| `content` | TEXT | — | Full-text search |

---

## Component design

<!--
For each new component: responsibility, interface, and implementation notes.
Function/class signatures for AI agent implementation.
-->

### [ComponentName]

**Responsibility:** [Single sentence — what this component does and nothing else]

**Interface:**
```typescript
// Exact signatures — agent implements these
class ComponentName {
  constructor(config: ComponentConfig) {}
  
  async methodName(
    param1: ParamType,
    param2: ParamType
  ): Promise<ReturnType> {}
}

interface ComponentConfig {
  field: type;
}
```

**Implementation notes:**
- [Key constraint or pattern the agent must follow]
- [Error handling requirement]
- [Performance requirement with metric]

---

## Dependency boundaries

<!--
What this feature is ALLOWED and FORBIDDEN to import.
Copy into the relevant ADR's dependency boundaries section.
-->

```
ALLOWED:
  [new-module/] → [existing-shared/], [external-approved-package]

FORBIDDEN:
  [new-module/] ✗ [other-domain/internal/]
  [new-module/] ✗ external: [forbidden-packages]
```

---

## Acceptance criteria

<!--
Measurable conditions that define "done" for this specification.
Deterministic criteria: exact values.
Probabilistic criteria: statistical thresholds across N runs.
Every criterion maps to a test.
-->

### Functional
- [ ] **AC-001:** GIVEN [condition], WHEN [action], THEN [exact expected outcome]
- [ ] **AC-002:** GIVEN [condition], WHEN [action], THEN [exact expected outcome]

### Performance
- [ ] **AC-003:** P95 response time < [X]ms under [N] concurrent users (load test)
- [ ] **AC-004:** [Component] initializes in < [X]ms on cold start

### AI-native quality (include only for LLM-powered components)
- [ ] **AC-005:** Factuality score ≥ [0.XX] across [N] runs (LLM-judge evaluation)
- [ ] **AC-006:** Semantic similarity ≥ [0.XX] to reference answers on golden dataset
- [ ] **AC-007:** Context precision ≥ [0.XX] (RAGAS) on [N] evaluation queries
- [ ] **AC-008:** Zero toxicity violations across [N] runs (Perspective API < 0.1)

### Safety and compliance
- [ ] **AC-009:** Prompt injection attempt rejected with [error type] in [N]% of cases
- [ ] **AC-010:** PII fields redacted before [storage/logging/display]

---

## Test requirements

<!--
What tests the agent must write. Precise — not "write tests."
-->

**Unit tests** (deterministic logic only):
- `tests/unit/[component]-[method].test.ts` — [what to test]
- `tests/unit/[component]-error-handling.test.ts` — [error scenarios]

**Integration tests:**
- `tests/integration/[feature]-flow.test.ts` — [end-to-end happy path]
- `tests/integration/[feature]-edge-cases.test.ts` — [boundary conditions]

**AI evaluation suite:**
- `evals/[feature]-suite.yaml` — minimum [N] test cases
- Golden dataset: `evals/golden/[feature].jsonl` — minimum [N] examples
- Pass threshold: [criterion] ≥ [threshold] across all test cases

---

## Implementation order

<!--
Dependency-sequenced. Agent implements tasks in this order.
[P] = can run in parallel with other [P] tasks.
-->

1. [ ] Database migrations and data model (TASK-NNN)
2. [ ] Core service logic with unit tests (TASK-NNN) [P]
3. [ ] API endpoints with integration tests (TASK-NNN) [P]
4. [ ] AI component with eval suite (TASK-NNN)
5. [ ] Feature flag integration (TASK-NNN)

---

## Open technical questions

<!--
Must be resolved before status → approved.
-->

- [ ] [Question] — Resolved by: [ADR-NNN or decision text]

---

*Template version 1.0 — BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
