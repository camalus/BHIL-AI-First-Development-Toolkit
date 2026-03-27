---
id: ADR-NNN
title: "Use [Pattern Name] orchestration for [System/Feature]"
status: proposed
type: agent-orchestration
date: YYYY-MM-DD
decision_makers: [name]
related_prds: [PRD-NNN]
related_specs: [SPEC-NNN]
related_adrs: [ADR-NNN]   # Model selection ADR(s)
sprint: S-NN
tags: [agent, orchestration, multi-agent, architecture]
---

# ADR-NNN: Use [Pattern Name] Orchestration for [System/Feature]

## Context and problem statement

[2–3 sentences describing the workflow being orchestrated, the complexity that makes single-agent approaches insufficient, and the operational requirements that constrain the pattern choice.]

**Decision question:** What agent orchestration pattern best handles [workflow description] given requirements for [cost / latency / reliability / observability]?

---

## Decision drivers

- **Workflow complexity:** [e.g., Task requires document extraction → analysis → synthesis → validation — four distinct specialized capabilities]
- **Latency budget:** [e.g., Total workflow must complete < 30 seconds P95]
- **Cost ceiling:** [e.g., Max [N] LLM calls per user request to stay within $[X] cost]
- **Error tolerance:** [e.g., Partial failures must not surface to user — graceful degradation required]
- **Observability:** [e.g., Each agent step must be individually traceable for debugging]
- **Scalability:** [e.g., System must handle [N] concurrent workflows]

---

## Orchestration patterns evaluated

### Pattern 1: Orchestrator-Worker (Hierarchical)
An orchestrator agent decomposes the task and delegates to specialized worker agents. Workers return results to orchestrator for synthesis.

**Strengths:** Clear delegation, easy to add workers, orchestrator maintains context, debuggable.
**Weaknesses:** Orchestrator is a bottleneck and single point of failure. Worker specialization requires well-defined interfaces.
**Token overhead:** Orchestrator LLM call + N worker calls = N+1 total LLM calls minimum.

### Pattern 2: Pipeline (Sequential)
Output of Agent A becomes input to Agent B becomes input to Agent C.

**Strengths:** Simple, predictable, easy to monitor. Each agent is independently testable.
**Weaknesses:** Sequential — total latency = sum of all agent latencies. No parallel execution.
**Token overhead:** N LLM calls in series. Context grows with each stage.

### Pattern 3: Swarm (Parallel + Aggregate)
Multiple agents tackle the same task independently. Results aggregated (voting, best-of-N, consensus).

**Strengths:** Diversity reduces errors. Best for high-stakes decisions.
**Weaknesses:** [N]× cost of single agent. Aggregation logic can be complex.
**Token overhead:** N × single agent cost.

### Pattern 4: Mesh (Peer-to-peer)
Agents communicate directly without a central coordinator.

**Strengths:** No single point of failure. Emergent coordination for poorly-defined tasks.
**Weaknesses:** Hard to debug, observe, or control. Cost unpredictable. Not recommended for production without strong guardrails.
**Token overhead:** Unpredictable — monitor carefully.

### Pattern 5: Hybrid
Combines patterns — e.g., hierarchical at top level with pipeline workers.

**Strengths:** Matches pattern to sub-task characteristics.
**Weaknesses:** Highest implementation complexity.

---

## Decision outcome

**Chosen pattern: [Pattern Name]**

**Rationale:** [Pattern X] best fits this workflow because [specific reasons tied to decision drivers]. The [key tradeoff] is acceptable because [justification].

---

## Architecture specification

```
[Orchestrator Agent]
    ├── [Worker Agent A] — Responsibility: [single task]
    │       Tools: [tool1, tool2]
    │       Model: [model name]
    │       Max tokens: [N]
    │
    ├── [Worker Agent B] — Responsibility: [single task]
    │       Tools: [tool1]
    │       Model: [model name]
    │       Max tokens: [N]
    │
    └── [Worker Agent C] — Responsibility: [single task]
            Tools: [tool1, tool2, tool3]
            Model: [model name]
            Max tokens: [N]
```

### Agent definitions

Each agent is defined in `.claude/agents/[agent-name].md`:

**Orchestrator:**
```yaml
---
name: [orchestrator-name]
description: "[When this agent is invoked]"
model: claude-opus-4  # Reserve Opus for orchestration
tools: [Task, Read, Write]
---
```

**Worker agents:**
```yaml
---
name: [worker-name]
description: "[Specialized capability]"
model: claude-sonnet-4  # Use Sonnet for workers
tools: [Read, Grep, WebSearch]
---
```

### Context isolation policy

- [ ] Each worker gets a **fresh context window** — no shared conversational history
- [ ] Workers receive only the context needed for their specific task
- [ ] Worker outputs are structured (JSON or markdown with defined schema)
- [ ] Orchestrator assembles final response from worker outputs

---

## Error handling specification

| Failure scenario | Detection | Recovery action |
|---|---|---|
| Worker timeout | [X]s timeout per worker | Retry once → fallback to [simpler approach] |
| Worker hallucination | Output schema validation | Re-run with temperature 0 → flag for human review |
| Orchestrator failure | Exception handling | Return graceful error to user; log full trace |
| Cost runaway | Token count pre-check | Reject requests exceeding [N] tokens; alert |
| All workers fail | Aggregate error state | Return cached response if available; escalate |

---

## Observability requirements

All agent invocations must emit:
```json
{
  "trace_id": "[request-level unique ID]",
  "agent_name": "[name]",
  "model": "[model identifier]",
  "input_tokens": "[N]",
  "output_tokens": "[N]",
  "latency_ms": "[N]",
  "status": "success | error | timeout",
  "error_type": "[null or error class]"
}
```

Tracing dashboard: [Langfuse / Helicone / custom] at [URL/config location]

---

## Cost and latency model

| Scenario | LLM calls | Total tokens | Estimated cost | Estimated latency |
|---|---|---|---|---|
| Happy path | [N] | [N] | $[X.XXXX] | [X]ms |
| With retry | [N+1] | [N+K] | $[X.XXXX] | [X]ms |
| Worst case | [N+M] | [N+K+L] | $[X.XXXX] | [X]ms |

**Circuit breaker:** If cost per request exceeds $[X], abort workflow and return error.

---

## RuFlo integration (if using Agentics Foundation toolchain)

```javascript
// ruflo configuration for this orchestration pattern
{
  "topology": "[hierarchical | pipeline | swarm | mesh]",
  "queen_type": "[Strategic | Tactical | Adaptive]",
  "workers": [
    { "name": "[agent-a]", "specialization": "[domain]", "model_tier": 2 },
    { "name": "[agent-b]", "specialization": "[domain]", "model_tier": 2 }
  ],
  "memory": "ruvector",  // Enable RuVector persistent memory
  "max_concurrent": [N],
  "cost_ceiling_per_request": [X.XX]
}
```

---

## Acceptance criteria

- [ ] End-to-end workflow completes in < [X]ms P95 (load test with [N] concurrent requests)
- [ ] Maximum [N] LLM calls per user request (monitored via Langfuse)
- [ ] Worker failures trigger correct recovery path ([N]% of injected failures handled correctly)
- [ ] All agent invocations emit structured telemetry (verified in integration tests)
- [ ] Cost per request ≤ $[X.XXXX] at [N] test cases

---

## Rejected patterns

### [Pattern B: Swarm]
**Rejected because:** Swarm cost ([N]× single agent) would exceed $[X] cost ceiling at expected volume. Quality improvement from [N]-way diversity would need to exceed [X]% to justify cost, and our eval results show only [X]% improvement — insufficient.

### [Pattern C: Mesh]
**Rejected because:** Mesh observability requirements cannot be met without custom instrumentation beyond current tooling scope. The emergent coordination model also makes cost prediction impossible, violating the cost ceiling requirement.

---

## Consequences

**Positive:**
- [Specific benefit, e.g., "Worker isolation means any worker can be upgraded independently without affecting orchestrator"]
- [Observability benefit]

**Negative:**
- [Accepted overhead, e.g., "Orchestrator LLM call adds [X]ms and [N] tokens per request — within latency budget"]
- [Scaling limitation, e.g., "Adding workers beyond [N] requires re-evaluating orchestrator model capacity"]

---

## Related decisions

- **Model selection (orchestrator):** [ADR-NNN]
- **Model selection (workers):** [ADR-NNN]
- **Prompt strategy:** [ADR-NNN]
- **RAG architecture:** [ADR-NNN if applicable]

---

*Template version 1.0 — BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
