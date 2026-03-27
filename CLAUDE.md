# BHIL AI-First Development Toolkit — Claude Code Configuration

## Project identity
This is the BHIL AI-First Development Toolkit — a methodology repository for building AI-native applications. When used as a GitHub template, this file should be updated with the specific project's context.

**Current mode:** Methodology toolkit (meta-project)
**Stack:** Markdown, shell scripts, YAML, GitHub Actions
**Agent toolchain:** Claude Code primary, RuFlo orchestration, RuVector memory

---

## CRITICAL: Read this before writing anything

This is a **methodology repository**. Every file is a template, guide, or example. Do not write application code here. Do not modify template placeholders — fill them or leave them.

Before implementing any feature in a project derived from this toolkit:
1. Read the relevant guide in `guides/`
2. Check whether an ADR exists in `docs/adr/` for the decision area
3. Create the PRD slice → SPEC → ADR chain before writing code

---

## Commands

```bash
# Validate all artifact frontmatter
./tools/scripts/validate-artifacts.sh

# Create a new feature artifact scaffold
./tools/scripts/new-feature.sh "Feature name" "PRD-NNN"

# Create a sequentially numbered ADR
./tools/scripts/new-adr.sh "Decision title" "adr-type"
# adr-type: standard | model-selection | prompt-strategy | agent-orchestration

# Run the traceability check
./tools/scripts/check-traceability.sh
```

---

## Artifact format rules

### ALWAYS
- Include YAML frontmatter in every artifact file with `id`, `status`, `date`
- Use traceability IDs in the format specified in README.md
- Write acceptance criteria as probabilistic bands for AI-native features
- Reference parent artifacts in child frontmatter
- Create an ADR before making any model, prompt, or orchestration decision

### ASK before
- Adding a new template type not covered by existing categories
- Modifying the traceability ID format
- Changing the directory structure

### NEVER
- Remove frontmatter from any template or example file
- Write application code in this repository
- Create artifacts without traceability IDs
- Use vague acceptance criteria like "works correctly" — always quantify

---

## Skills available

Use these via natural language — Claude Code loads them on demand:

- **new-sprint** — Initialize a sprint: creates sprint plan, sets up artifact folders, prepares context files
- **new-feature** — Create a feature artifact scaffold: PRD slice + SPEC + task breakdown
- **new-adr** — Create a properly formatted ADR with correct numbering and traceability

---

## File structure conventions

```
Template files:     UPPERCASE-WITH-HYPHENS.md
Example files:      TYPE-NNN-short-description.md  (e.g., PRD-001-rag-chat.md)
Guide files:        NN-kebab-case.md
Script files:       kebab-case.sh
```

---

## Context management for this project

When working on this toolkit, keep sessions focused on one module at a time:
- Guides: one guide per session
- Templates: one template family per session (e.g., all ADR templates together)
- Examples: full-chain example as a single coherent session

If context reaches 60%, compact with: `/compact "Preserve only the template structure and traceability conventions"`

*BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
