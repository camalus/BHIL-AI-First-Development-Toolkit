# BHIL AI-First Development Toolkit

**Human-Directed. AI-Enabled. Commercially Tested.**

> *"The bottleneck in AI-assisted development is not code generation. It is specification quality."*

A production-grade methodology repository for building AI-native applications using iterative sprints, where AI coding agents are primary implementors and humans are architects, reviewers, and decision-makers.

**Optimized for:** Claude Code · RuFlo (Agentics Foundation) · RuVector · Solo practitioners building LLM-powered apps

---

## What this toolkit is

This is not a collection of disconnected templates. It is a **cohesive methodology system** where every artifact is designed to feed the next in a traceable, machine-actionable chain:

```
PRD (what) → SPEC (how) → ADR (why) → TASK (steps) → CODE → REVIEW → DEPLOY
     ↑                                                                      |
     └──────────────────── Sprint Retrospective ────────────────────────────┘
```

Each sprint produces all artifacts. Each artifact carries traceability IDs linking it to its parents and children. Claude Code reads the chain. RuFlo orchestrates agents across it. RuVector maintains persistent memory across sessions.

---

## Repository structure

```
/
├── README.md                          ← You are here
├── CLAUDE.md                          ← Claude Code project configuration
├── AGENTS.md                          ← Cross-tool agent context (symlink)
│
├── guides/                            ← How and why — narrative documentation
│   ├── 00-getting-started.md          ← 5-minute setup
│   ├── 01-methodology-overview.md     ← Core philosophy and principles
│   ├── 02-artifact-chain.md           ← How artifacts connect and flow
│   ├── 03-sprint-workflow.md          ← Sprint execution step-by-step
│   ├── 04-context-management.md       ← Preventing context fragmentation
│   ├── 05-ai-native-patterns.md       ← LLM-specific documentation patterns
│   ├── 06-solo-practitioner.md        ← Review cadence and daily workflow
│   └── 07-ruflo-ruvector-setup.md     ← Agentics Foundation integration
│
├── templates/                         ← Copy-and-fill production templates
│   ├── prd/PRD-TEMPLATE.md            ← Product requirements (per feature)
│   ├── spec/SPEC-TEMPLATE.md          ← Technical specification
│   ├── adr/
│   │   ├── ADR-TEMPLATE.md            ← Core ADR template (MADR-style)
│   │   ├── ADR-MODEL-SELECTION.md     ← LLM model choice template
│   │   ├── ADR-PROMPT-STRATEGY.md     ← Prompt engineering decision template
│   │   └── ADR-AGENT-ORCHESTRATION.md ← Agent architecture decision template
│   ├── task/TASK-TEMPLATE.md          ← Implementable task unit
│   ├── sprint/SPRINT-PLAN-TEMPLATE.md ← Sprint planning document
│   ├── eval/EVAL-SUITE-TEMPLATE.yaml  ← LLM evaluation configuration
│   └── guardrails/GUARDRAILS-SPEC-TEMPLATE.md ← Safety specification
│
├── examples/                          ← Completed templates with real content
│   ├── full-chain/                    ← End-to-end PRD→ADR→Task walkthrough
│   │   ├── PRD-001-rag-chat.md
│   │   ├── SPEC-001-rag-chat.md
│   │   ├── ADR-001-model-selection.md
│   │   ├── ADR-002-rag-architecture.md
│   │   ├── TASK-001-embeddings.md
│   │   └── SPRINT-01-plan.md
│   └── ai-specific/
│       ├── ADR-prompt-strategy-example.md
│       └── GUARDRAILS-example.md
│
├── .claude/                           ← Claude Code configuration
│   ├── settings.json                  ← Hooks, permissions, model routing
│   ├── rules/                         ← Path-scoped coding rules
│   ├── skills/                        ← On-demand workflow skills
│   └── agents/                        ← Custom subagent definitions
│
├── tools/                             ← Automation scripts
│   └── scripts/                       ← new-feature, new-adr, validate
│
└── .github/                           ← CI/CD and PR templates
    ├── workflows/
    └── PULL_REQUEST_TEMPLATE.md
```

---

## Quick start (5 minutes)

**Step 1 — Use as GitHub template**
Click "Use this template" on GitHub, or clone directly:
```bash
git clone https://github.com/barryhurd/ai-first-toolkit.git my-project
cd my-project
```

**Step 2 — Initialize for your project**
```bash
chmod +x tools/scripts/*.sh
./tools/scripts/init.sh "My Project Name" "TypeScript" "RAG chatbot for enterprise knowledge management"
```

**Step 3 — Load into Claude Code**
```bash
claude  # Opens Claude Code in project root
# Claude automatically reads CLAUDE.md and all skills
```

**Step 4 — Start your first sprint**
In Claude Code, type: `Use the new-sprint skill to start Sprint 1`

---

## Artifact traceability system

Every artifact carries a **traceability ID** in its YAML frontmatter:

| Artifact | ID Format | Example |
|---|---|---|
| Product Requirement | `PRD-NNN` | `PRD-001` |
| Specification | `SPEC-NNN` | `SPEC-001` |
| Architecture Decision | `ADR-NNN` | `ADR-003` |
| Task | `TASK-NNN` | `TASK-007` |
| Sprint | `S-NN` | `S-01` |
| Prompt Version | `PV-NNN` | `PV-002` |

Links are **asymmetric** — children reference parents, parents list children:
- PRDs reference nothing upstream
- SPECs reference `parent: PRD-NNN`
- ADRs reference `related_prds: [PRD-NNN]` and `related_specs: [SPEC-NNN]`
- TASKs reference `spec: SPEC-NNN` and `adrs: [ADR-NNN]`

---

## AI-native ADR categories

Beyond standard architecture decisions, AI-native apps require three additional ADR types included in this toolkit:

**Model Selection ADRs** — Document LLM choice with benchmark scores, cost projections, latency targets, and re-evaluation triggers. See `templates/adr/ADR-MODEL-SELECTION.md`.

**Prompt Strategy ADRs** — Capture prompting approach (zero-shot, few-shot, CoT, RAG), versioning scheme, evaluation dataset, and quality thresholds. See `templates/adr/ADR-PROMPT-STRATEGY.md`.

**Agent Orchestration ADRs** — Record the chosen orchestration pattern (orchestrator-worker, pipeline, swarm, mesh, hierarchical) with rationale. See `templates/adr/ADR-AGENT-ORCHESTRATION.md`.

---

## Relationship to the ADR module

This toolkit extends the [BHIL ADR Blueprint](../adr-ai-toolkit/) with four additional process modules. The ADR templates here are designed to work alongside the full ADR methodology from that module. When in doubt, the ADR module's gold-standard template and enforcement guidance takes precedence for architectural ADRs.

---

## About

**Author:** Barry Hurd
**Organization:** Barry Hurd Intelligence Lab (BHIL)
**Tagline:** Human-Directed. AI-Enabled. Commercially Tested.

---

## License

MIT License

Copyright (c) [2026] [BarryHurd.com]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Attribution format: *BHIL AI-First Development Toolkit by Barry Hurd (barryhurd.com)*
