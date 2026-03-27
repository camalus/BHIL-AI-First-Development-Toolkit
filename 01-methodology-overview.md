# Guide 01: Methodology Overview

**The philosophy behind AI-first development for solo practitioners**

---

## The fundamental shift

Traditional software development answers three questions in sequence: What to build (requirements), how to build it (design), then builds it (implementation). In this model, implementation is the primary human activity — consuming 60–70% of engineering time.

AI-first development inverts this. With AI coding agents as primary implementors, **specification quality becomes the constraint on development velocity**. A well-specified feature can be implemented by Claude Code with minimal human intervention. A poorly specified feature generates implementation loops, hallucinations, and rework that consume more time than writing the code manually.

The shift in human time allocation:

| Activity | Traditional | AI-First |
|---|---|---|
| Requirements & specification | 10% | 40% |
| Architecture & ADRs | 10% | 15% |
| Review & oversight | 20% | 35% |
| Implementation | 60% | 10% |

You are no longer primarily a developer. You are an **architect, specification writer, and quality gatekeeper** who happens to deploy software.

---

## The three laws of AI-first development

**Law 1: Specifications are the source of truth — not code.**

Code is the last-mile output of a specification process. If a spec is wrong, no amount of correct code will produce the right system. If a spec is right, even imperfect code is fixable. Store specs in version control. Evolve specs when requirements change. Never let the codebase diverge from its specification without updating the spec first.

Sean Grove's formulation is definitive: *"Discarding specs while keeping generated code is like compiling a JAR and checking in the binary while throwing away the source."*

**Law 2: If an AI agent needs human clarification, the specification failed.**

The Golden Rule from the BHIL ADR Blueprint applies equally to all artifacts: if Claude Code has to ask you a question about what to build or how to build it, the PRD or SPEC was insufficient. That question is documentation debt — the answer belongs in the artifact, not in the chat history.

Track every question Claude Code asks during implementation. Each one reveals a specification gap. Fill it before the next sprint.

**Law 3: Non-determinism is a first-class architectural concern.**

LLM-powered applications behave differently on repeated invocations. Acceptance criteria must account for this. "Output matches expected value" is not a valid test for an AI component. Valid tests express statistical quality bands: "achieves ≥85% semantic similarity to reference answers across 50 runs" or "factuality score ≥0.8 on LLM-judge evaluation."

This is not a workaround — it is the correct specification model for probabilistic systems.

---

## Why iterative sprints, not waterfall

AI-first development might look like waterfall at first glance — heavy upfront specification before implementation begins. It is not, for a critical reason: **each sprint closes a learning loop** that updates specifications for the next sprint.

Sprint N produces: PRD slice → SPEC → ADRs → implemented feature → evaluation results → specification gaps discovered. Those gaps flow directly into the Sprint N+1 PRD. The spec becomes progressively more accurate, the agent becomes progressively more autonomous, and human intervention per feature decreases over time.

ThoughtWorks describes this as moving from "vibe coding" through "supervised agents" to "context engineering as discipline." Each sprint is a context engineering improvement cycle.

---

## The artifact chain and why every link matters

```
PRD → SPEC → ADR → TASK → CODE → REVIEW → DEPLOY
```

Each artifact serves a distinct function that no other artifact can substitute:

**PRD (Product Requirements Document)** answers *what* to build and *why*. It contains user stories in EARS format, success metrics, and out-of-scope declarations. It does not contain implementation details.

**SPEC (Technical Specification)** answers *how* to build what the PRD describes. It contains architecture decisions, API contracts, data models, and dependency choices. It does not re-explain the business need.

**ADR (Architecture Decision Record)** answers *why this approach* over alternatives. It is immutable once accepted — changes require a new superseding ADR. It provides the agent with the reasoning it needs to avoid re-litigating settled decisions.

**TASK** answers *what specifically* to implement in one agent session. It contains file paths, function signatures, test requirements, and definition-of-done criteria. It is sized to fit within one Claude Code session without context degradation.

**CODE** is the implementation. It is generated primarily by Claude Code from the TASK specification.

**REVIEW** is the human gate. For a solo practitioner, this means PR-to-self — reviewing Claude Code's PR with the checklist from `templates/sprint/SPRINT-PLAN-TEMPLATE.md`.

**DEPLOY** releases validated code using feature flags (off by default) and canary analysis.

Skipping any link creates ambiguity that the agent resolves through assumption. Assumptions accumulate into technical debt faster in AI-assisted development than in human development, because agents work faster and make more of them.

---

## AI-native ADRs: the three additional categories

Standard ADRs cover infrastructure decisions (database choice, service architecture, auth strategy). AI-native apps require three additional categories that have no equivalent in traditional architecture documentation:

**Model Selection ADRs** — Every time you choose which LLM to use for a capability, document it. Model capabilities, pricing, and availability change constantly. Without a record of why you chose a model, you cannot evaluate whether to change it. Include benchmark scores, cost projections at expected volume, latency measurements, and specific failure modes observed.

**Prompt Strategy ADRs** — Prompt engineering decisions are architectural decisions. Choosing chain-of-thought over zero-shot, choosing few-shot examples over RAG, choosing structured output over free text — these choices have measurable performance implications and should be recorded with evaluation evidence.

**Agent Orchestration ADRs** — Whether you use a single LLM call, an orchestrator-worker pattern, a pipeline, or a swarm affects cost, latency, reliability, and debuggability. Document the choice, the alternatives considered, and the specific workload characteristics that drove the decision.

---

## The solo practitioner leverage model

The observed leverage ratio for solo practitioners using Claude Code for AI-native apps is 20–30× human hours. One documented case: ~35 hours of human effort produced what would have required ~800 hours without AI. This is not magic — it is the result of three specific practices.

**Parallel async implementation.** While reviewing yesterday's PRs, Claude Code is implementing today's tasks. Each agent session runs independently; the practitioner orchestrates rather than implements.

**Specification as capital.** Every hour spent improving a PRD or SPEC reduces the downstream implementation loop time by more than an hour. Well-specified features ship on the first attempt. Poorly specified features generate multiple clarification sessions.

**Structured review, not line-by-line scrutiny.** The PR review checklist (included in `templates/sprint/SPRINT-PLAN-TEMPLATE.md`) guides review toward what matters: specification alignment, security implications, test coverage, and performance boundaries. This takes 20–30 minutes per PR for a well-implemented task.

---

*Next: Read `guides/02-artifact-chain.md` for detailed instructions on creating and linking artifacts.*

*BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
