---
project: "[Your Project Name]"
stack: "[Your Stack]"
last_updated: YYYY-MM-DD
sprint: S-01
---

# [Project Name] — Architecture Context

> **Load this file at the start of every implementation session.**
> Updated at the end of each sprint retrospective by the practitioner.
> Maximum 500 lines — summarize, do not inline full ADRs.

---

## Project description

[One paragraph: what this project is, who it's for, and what problem it solves.]

---

## Tech stack

| Layer | Technology | Version | ADR |
|---|---|---|---|
| Language | [e.g., TypeScript] | [X.X] | — |
| Runtime | [e.g., Node.js] | [X.X] | — |
| Framework | [e.g., Fastify] | [X.X] | — |
| Database | [e.g., PostgreSQL] | [X.X] | [ADR-NNN] |
| Vector store | [e.g., RuVector] | [X.X] | [ADR-NNN] |
| LLM provider | [e.g., Anthropic] | — | [ADR-NNN] |
| Primary model | [e.g., claude-sonnet-4] | — | [ADR-NNN] |
| Eval framework | [e.g., Promptfoo] | [X.X] | — |
| CI/CD | GitHub Actions | — | — |

---

## ADR registry

| ADR | Type | Decision | Status | Sprint |
|---|---|---|---|---|
| ADR-001 | model-selection | [Decision title] | proposed | S-01 |
| (add rows as ADRs are created) | | | | |

---

## Key architectural principles

*(Add as ADRs are accepted — brief summaries, full details in the ADR files)*

1. **[Principle name]:** [One-sentence summary of the decision and its implication]

---

## Dependency boundaries (active constraints)

```
ALLOWED:
  [module] → [module], [module]
  
FORBIDDEN:
  [module] ✗ [module]
```

*(Copy the dependency boundary sections from accepted ADRs here for quick reference)*

---

## Active feature flags

| Flag | Feature | Status | Since |
|---|---|---|---|
| [flag-name] | [Feature description] | OFF / [X]% | S-NN |

---

## Prompt registry summary

*(Full registry in project/prompts/PROMPT-REGISTRY.md)*

| Prompt ID | Version | Capability | Deployed |
|---|---|---|---|
| PV-001 | v1.0.0 | [Capability] | No |

---

## Known constraints

*(Non-negotiable limits — add here so every session knows them)*

- [e.g., No PII in logs or LLM inputs without redaction]
- [e.g., All external API calls require timeout of ≤8,000ms]
- [e.g., Feature flags required for all AI-native features before deploy]

---

## Sprint history

| Sprint | Theme | Completed | Key decisions made |
|---|---|---|---|
| S-01 | [Theme] | [In progress] | [Key ADRs accepted] |

---

*BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
