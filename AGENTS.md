# AGENTS.md — AI Agent Context Layer

> Vendor-neutral agent instructions for Claude Code, Cursor, Devin, GitHub Copilot, and AGENTS.md-compatible tools.
> This file is the single source of truth. CLAUDE.md symlinks here.
> Last updated: 2026-03-26 | Toolkit version: 1.0

---

## Project overview

The BHIL AI-First Development Toolkit is a **methodology repository** for building AI-native, LLM-powered applications using iterative sprints. It provides templates, guides, examples, and Claude Code configuration for solo practitioners building greenfield AI-native apps.

**This is a meta-project.** It contains methodology artifacts, not application code. When used as a GitHub template, the team should update this file to describe their specific product.

---

## CRITICAL: The artifact chain governs all development

Every feature follows this chain. Do not skip steps:

```
PRD (what) → SPEC (how) → ADR (why) → TASK (steps) → CODE → REVIEW → DEPLOY
```

Before writing any code, verify:
- [ ] PRD slice exists and is `status: approved`
- [ ] SPEC exists and is `status: approved`
- [ ] All architectural decisions have corresponding ADRs
- [ ] Tasks reference both the SPEC and relevant ADRs

---

## ALWAYS / ASK / NEVER

### ✅ ALWAYS
- Include YAML frontmatter with traceability IDs in every artifact
- Write acceptance criteria as measurable, testable conditions
- For AI-native features: express acceptance criteria as probabilistic bands (≥X% pass rate on N runs)
- Create ADRs for: model selection, prompt strategy, agent orchestration, major library choices
- Run `./tools/scripts/validate-artifacts.sh` after creating or modifying any artifact
- Compact context at 60% utilization before quality degrades

### ⚠️ ASK BEFORE
- Adding a dependency not previously discussed
- Changing the traceability ID format
- Modifying templates (templates are stable; examples are for customization)
- Creating a new artifact category not covered by existing templates

### 🚫 NEVER
- Write application code in this repository
- Skip creating the PRD→SPEC chain before task breakdown
- Use vague acceptance criteria ("works," "is fast," "is good")
- Commit artifacts with `status: draft` without explicit human approval
- Modify `.claude/settings.json` hooks without review

---

## Commands reference

```bash
# Setup
./tools/scripts/init.sh "Project" "Stack" "Description"

# Feature workflow
./tools/scripts/new-feature.sh "Feature name" "PRD-NNN"

# ADR creation
./tools/scripts/new-adr.sh "Decision title" standard
./tools/scripts/new-adr.sh "Model choice" model-selection
./tools/scripts/new-adr.sh "Prompt approach" prompt-strategy
./tools/scripts/new-adr.sh "Agent pattern" agent-orchestration

# Validation
./tools/scripts/validate-artifacts.sh
./tools/scripts/check-traceability.sh

# Evaluation (AI-native projects)
npx promptfoo eval --config evals/suite.yaml
```

---

## Testing standards

- Every SPEC must include at least 3 acceptance criteria
- AI-native acceptance criteria: include pass rate threshold, N runs, and evaluation metric
- Unit tests: cover deterministic logic only (parsing, routing, schema validation)
- Eval suite: minimum 20 test cases, run on every PR
- Golden dataset: minimum 50 curated input/output pairs per agent capability

---

## Directory map

```
guides/        Educational content — read to understand why
templates/     Operational — copy and fill for new artifacts
examples/      Demonstrative — reference for completed artifacts
.claude/       Claude Code configuration — skills, rules, agents, hooks
tools/         Automation scripts
.github/       CI/CD and PR templates
project/       Active workspace (when used as template)
```

---

## Context management across sessions

**Session handoff pattern:** At the end of every session, write a `progress.md` to `project/.sdlc/knowledge/` before closing. Include: what was completed, decisions made, open questions, and exact next steps.

**Fresh context per task:** Spawn a new Claude Code session per implementable task. Pass context through `progress.md` and the artifact chain — not conversational history.

**Context budget:** AGENTS.md + CLAUDE.md + active skill = ~4K tokens baseline. Leave ~196K for working context. Compact proactively at 60% usage.

---

*BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
*Author: Barry Hurd | CC BY 4.0*
