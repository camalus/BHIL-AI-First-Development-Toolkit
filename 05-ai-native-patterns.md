# Guide 05: AI-Native Documentation Patterns

**Documenting LLM-powered applications: where traditional patterns break and what replaces them**

---

## The non-determinism problem

Traditional software specifications assume deterministic behavior: given input X, output is always Y. LLM-powered applications violate this assumption fundamentally. The same prompt produces different outputs across runs, across model versions, and across temperature settings.

This is not a bug to engineer around. It is the core property that makes LLMs useful. The documentation challenge is to specify **quality bands** rather than exact outputs.

---

## Writing probabilistic acceptance criteria

### What not to write

```yaml
# WRONG — deterministic assertion on non-deterministic system
acceptance_criteria:
  - "GIVEN user question 'What is the capital of France?', 
     THEN output is 'Paris'"
```

This test fails whenever the model says "The capital of France is Paris" or "Paris is the capital" — both correct, both failures.

### What to write instead

```yaml
# CORRECT — probabilistic quality band
acceptance_criteria:
  - metric: factual_accuracy
    method: llm-judge (Claude Sonnet)
    threshold: "≥0.90 across 50 runs"
    
  - metric: semantic_similarity
    method: cosine similarity to reference answer
    threshold: "≥0.85 cosine similarity"
    
  - metric: structural_compliance  
    method: JSON schema validation
    threshold: "100% of runs" # deterministic — schema is exact
    
  - metric: latency
    method: wall clock P95
    threshold: "<3000ms"  # deterministic
    
  - metric: toxicity
    method: Perspective API
    threshold: "<0.1 score on all runs"
```

**Pattern:** Separate deterministic criteria (schema, latency, error rate) from probabilistic criteria (semantic quality, factuality, relevance). Apply exact thresholds to deterministic properties and statistical thresholds to probabilistic properties.

---

## Model selection documentation

Every LLM model choice is an architectural decision with significant cost, latency, and capability implications. Document it with `templates/adr/ADR-MODEL-SELECTION.md`.

The key dimensions to capture:

**Capability fit** — Run your specific task against candidate models on a representative sample (minimum 20 inputs). Document task-specific performance, not general benchmarks. General benchmarks (MMLU, HumanEval) predict general capability. They do not predict performance on your specific prompt and domain.

**Cost projection** — Calculate at three volumes: current (MVP), 10× growth, and 100× growth. Include input tokens, output tokens, and any structured output overhead. Models that seem cheap at MVP scale often become prohibitive at scale, and vice versa.

**Latency measurement** — Measure P50, P95, and P99 latency on your actual prompt with your actual input size. Streaming vs. non-streaming changes the perceived latency profile. Time to first token matters as much as total generation time for interactive applications.

**Re-evaluation triggers** — Model providers release updates frequently. Specify the conditions that would prompt revisiting the decision: performance regression >10%, cost change >20%, new model release with published benchmark improvements >15% on your task type.

---

## Prompt engineering documentation

### Prompt versioning

Prompts are code. Version them with semantic versioning:
- **Major** (1.0.0 → 2.0.0): Output format change, persona change, or fundamental approach change that breaks existing evals
- **Minor** (1.0.0 → 1.1.0): New capability, new few-shot examples, expanded instructions that are backward-compatible
- **Patch** (1.0.0 → 1.0.1): Typo fix, minor wording clarification, no behavioral change

Store all prompt versions in `project/prompts/`:
```
project/prompts/
├── v1/
│   ├── system-prompt.md
│   ├── user-template.md
│   └── few-shot-examples.json
├── v2/
│   └── ...
└── PROMPT-REGISTRY.md  # version history and eval results per version
```

Never modify a deployed prompt version in-place. Create a new version.

### The prompt strategy ADR

Use `templates/adr/ADR-PROMPT-STRATEGY.md` to document:
- Why zero-shot vs. few-shot vs. chain-of-thought vs. RAG
- What evaluation evidence supports the choice
- What the eval dataset looks like
- What failure modes were observed in rejected approaches

The most common failure mode in AI-native apps is choosing a prompting strategy based on intuition rather than evidence. The ADR forces evidence-based decision-making.

---

## RAG architecture documentation

RAG (Retrieval-Augmented Generation) systems have multiple architectural decisions that each deserve an ADR:

**Chunking strategy** — How documents are split affects retrieval quality. Common choices: fixed-size, sentence-boundary, semantic, hierarchical (parent-child). Document the chunk size, overlap, and the evaluation results that support the choice.

**Embedding model** — The embedding model determines semantic search quality. Choices: OpenAI text-embedding-3, Cohere embed, sentence-transformers, domain-specific fine-tuned models. Document dimension count, max tokens, cost per token, and retrieval quality metrics.

**Vector store** — RuVector (for self-learning vector storage with GNN intelligence), Pinecone, Qdrant, pgvector. Document read/write latency at expected scale, cost model, and any special capabilities used (e.g., RuVector's GNN-based routing).

**Retrieval strategy** — Dense retrieval, sparse retrieval (BM25), or hybrid. Top-k value. Re-ranking with cross-encoder. Document the RAGAS metrics (context precision, context recall) that validate the choice.

**Context assembly** — How retrieved chunks are assembled into the prompt context. Document max context tokens allocated to retrieved content, ordering strategy (recency, relevance score, MMR), and how conflicts between chunks are handled.

### RAGAS as evaluation framework

RAGAS provides four metrics for RAG pipeline evaluation:
- **Context Precision**: Were the retrieved chunks relevant to the question?
- **Context Recall**: Were all relevant chunks retrieved?
- **Faithfulness**: Does the answer follow from the context (no hallucination)?
- **Answer Relevance**: Does the answer address the question?

Target thresholds for a production RAG system: Context Precision ≥0.75, Context Recall ≥0.70, Faithfulness ≥0.85, Answer Relevance ≥0.80. Document these in your eval suite template.

---

## Agent orchestration documentation

### The five canonical patterns

**Orchestrator-worker** (~70% of production deployments): A coordinator agent decomposes tasks and delegates to specialized worker agents. Best for complex, multi-step tasks where sub-tasks are well-defined. Document the orchestrator's decomposition logic and the worker specializations.

**Pipeline (sequential)**: Output of Agent A feeds Agent B feeds Agent C. Best for content transformation chains (extract → analyze → synthesize). Document the interface contract at each stage.

**Swarm**: Multiple peer agents tackle the same problem independently; results are aggregated or the best is selected. Best for high-stakes decisions where diverse perspectives reduce error. Document the consensus mechanism.

**Mesh**: Agents communicate peer-to-peer without a central coordinator. Best for emergent problem-solving where task decomposition is not known upfront. Hardest to debug and monitor. Document when this pattern is appropriate vs. orchestrator-worker.

**Hierarchical**: Teams of agents with internal coordination plus a top-level orchestrator. Most scalable pattern for complex systems. RuFlo's "Hive Mind" implements this natively.

### What must be in an orchestration ADR

Beyond pattern selection, document:
- **Error handling**: What happens when a worker agent fails? Retry policy? Fallback?
- **Observability**: How are agent tool calls logged? How are inter-agent messages traced?
- **Cost control**: What is the maximum number of LLM calls per user request? What circuit breakers prevent runaway costs?
- **Context isolation**: Does each agent get a fresh context window or shared history?

---

## Guardrails specification

Safety and alignment requirements for LLM-powered features must be documented in `templates/guardrails/GUARDRAILS-SPEC-TEMPLATE.md`. The three-layer model:

**Input guardrails** — What is validated before the user's input reaches the LLM. Document: prompt injection detection (required for all customer-facing features), PII detection and redaction policy, topic boundary enforcement (what the LLM is permitted to discuss), content length limits, and rate limiting.

**Output guardrails** — What is validated before the LLM's output reaches the user. Document: toxicity threshold (<0.1 on Perspective API), hallucination detection approach (RAG grounding check, NLI verification, or LLM-as-critic), schema validation requirements, and sensitive data filtering.

**Tool/action guardrails** — For agentic systems that can take actions. Document: allowlisted tools per user role, actions requiring human-in-the-loop approval, maximum resource consumption per session, and audit logging requirements.

### Latency budget for guardrails

Guardrails add latency. Plan the budget explicitly:

| Guardrail type | Typical latency | Notes |
|---|---|---|
| Regex validation | <1ms | Always affordable |
| Neural classifier | 10–100ms | Use for high-risk checks |
| LLM-as-judge | 500–2000ms | Reserve for critical paths |
| Synchronous human review | Minutes–hours | Only for irreversible actions |

If total guardrail latency exceeds your P95 target, document the prioritization decision in an ADR.

---

## The prompt registry

Maintain `project/prompts/PROMPT-REGISTRY.md` as a living index of all prompts in the system:

```markdown
| Prompt ID | Version | Description | Deployed | Eval Score | Last Updated |
|---|---|---|---|---|---|
| PV-001 | v2.1.0 | Customer support triage | Yes | 0.87 factuality | 2026-03-20 |
| PV-002 | v1.0.0 | Document summarizer | Yes | 0.91 relevance | 2026-03-15 |
| PV-003 | v1.2.0 | Extraction agent | No (testing) | 0.78 precision | 2026-03-25 |
```

This registry is read by Claude Code at the start of any session involving prompt modifications, preventing unversioned prompt changes.

---

*Next: Read `guides/06-solo-practitioner.md` for the daily workflow and review cadence designed for a solo practitioner.*

*BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
