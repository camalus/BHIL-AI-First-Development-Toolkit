# Guide 00: Getting Started

**Time to first sprint: 5 minutes**

---

## What you are setting up

The BHIL AI-First Development Toolkit turns a solo practitioner into a coordinated development team. You write specifications and make architectural decisions. Claude Code — optionally orchestrated by RuFlo — implements, tests, and documents based on those specifications. RuVector maintains persistent memory across sessions so context never starts cold.

The result: 20–30× human leverage on development hours.

---

## Prerequisites

- Claude Code installed (`npm install -g @anthropic-ai/claude-code`)
- Node.js 18+ (for RuFlo and RuVector)
- Git configured with your identity
- A GitHub account (for template usage and CI/CD)
- Optional: RuFlo (`npm install -g ruflo`) for multi-agent orchestration

---

## Step 1: Use this as a GitHub template

On GitHub, click **"Use this template"** → **"Create a new repository"**. Name your project repository, make it private or public, and create it.

Then clone locally:
```bash
git clone https://github.com/YOUR-USERNAME/YOUR-PROJECT.git
cd YOUR-PROJECT
```

---

## Step 2: Initialize for your project

```bash
chmod +x tools/scripts/*.sh
./tools/scripts/init.sh \
  "Your Project Name" \
  "TypeScript" \
  "One-sentence description of what you are building"
```

This script:
- Updates CLAUDE.md and AGENTS.md with your project details
- Creates `project/.sdlc/context/architecture.md` with project-level ADR registry
- Initializes the first sprint folder at `project/sprints/S-01/`
- Creates `.gitignore` entries for sensitive files
- Installs pre-commit hooks via `./tools/scripts/install-hooks.sh`

---

## Step 3: Open Claude Code

```bash
claude
```

Claude Code automatically reads:
- `CLAUDE.md` (project configuration and rules)
- All skill descriptions in `.claude/skills/` (loaded as available slash-commands)
- Path-scoped rules in `.claude/rules/` (loaded when relevant files are opened)

You should see a confirmation that the BHIL toolkit is loaded.

---

## Step 4: Write your first PRD slice

In Claude Code, type:
```
Use the new-feature skill to create a PRD for [your first feature]
```

The skill guides you through the full artifact creation: PRD slice → Technical Spec → task breakdown. Each artifact is saved to the correct location with proper frontmatter and traceability IDs.

Alternatively, copy `templates/prd/PRD-TEMPLATE.md` to `project/.sdlc/specs/PRD-001-your-feature.md` and fill it in manually.

---

## Step 5: Start your first sprint

```
Use the new-sprint skill to initialize Sprint 1
```

Or run:
```bash
./tools/scripts/new-sprint.sh "Sprint 1" "2026-03-26" "2026-04-09" "Foundation"
```

---

## Step 6 (optional): Initialize RuFlo and RuVector

For multi-agent orchestration and persistent vector memory:

```bash
npx ruflo@latest init
npx ruvector hooks init --pretrain --build-agents quality
```

See `guides/07-ruflo-ruvector-setup.md` for complete integration instructions.

---

## Daily workflow after setup

**Morning (~30 min) — Developer mode**
- Review Claude Code session outputs from the previous day
- Merge approved PRs
- Update artifact statuses (in-review → approved → complete)

**Afternoon (~2 hrs) — PM mode**
- Write or refine PRD slices for the next implementation round
- Review and approve SPECs and ADRs Claude Code generates
- Identify orthogonal tasks for parallel agent sessions

**Implementation (~async)**
- Start Claude Code sessions for each approved TASK
- One task per session — fresh context window each time
- Claude Code reads SPEC + ADR + TASK → implements → creates PR

---

## What each file type does

| File | When to create | Who creates |
|---|---|---|
| PRD-NNN | Before any work on a feature | You |
| SPEC-NNN | After PRD is approved | You + Claude Code |
| ADR-NNN | When making architectural decisions | You (Claude Code drafts) |
| TASK-NNN | After SPEC is approved | Claude Code |
| SPRINT-NN | At start of each sprint | You + Claude Code |
| progress.md | End of every Claude Code session | Claude Code |

---

## Traceability quick reference

Every artifact links to its parents and children via YAML frontmatter. The format is rigid:

```yaml
---
id: SPEC-001
status: draft
parent: PRD-001
adrs: [ADR-001, ADR-002]
sprint: S-01
---
```

Valid statuses: `draft` → `in-review` → `approved` → `complete`

Never promote an artifact past `draft` without reviewing it yourself.

---

*Next: Read `guides/01-methodology-overview.md` to understand the philosophy behind this system.*

*BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
