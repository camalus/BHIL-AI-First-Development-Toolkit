---
name: new-feature
description: Create a complete feature artifact scaffold — PRD slice, technical spec, and task breakdown. Use when starting work on any new feature, user story, or capability. Triggers on phrases like 'new feature', 'create a PRD for', 'start work on', 'scaffold a feature'.
---

# Skill: New Feature Scaffold

## Purpose
Guide the practitioner through creating a complete, linked artifact chain for a new feature: PRD slice → Technical Specification → ADR identification → Task breakdown.

## Execution steps

### Step 1: Gather requirements (ask these questions before creating any files)

Ask the practitioner:
1. What is the feature name? (5 words max for the title)
2. What problem does it solve? (one sentence, no solution hints)
3. Who is the user? (be specific — not "users," e.g., "authenticated enterprise customers")
4. What does success look like? (ask for at least one quantified metric)
5. What is explicitly OUT of scope?
6. Is this feature AI-native (LLM-powered)? If yes, which capability?

Do not proceed until all five questions are answered.

### Step 2: Determine the next available ID

Run:
```bash
ls project/.sdlc/specs/PRD-*.md 2>/dev/null | tail -1
```

The next PRD ID is one higher. If no PRDs exist, start at PRD-001. Use the same number for SPEC-NNN.

### Step 3: Create the PRD slice

Copy `templates/prd/PRD-TEMPLATE.md` to `project/.sdlc/specs/PRD-NNN-[kebab-feature-name].md`.

Fill in:
- frontmatter: id, title, date (today), sprint (current sprint from `project/sprints/` folder name)
- Problem statement: one sentence from practitioner's answer to Q2
- User stories: 2–3 EARS-format stories capturing the practitioner's feature description
- Success metrics: quantified from practitioner's answer to Q4
- Out of scope: from practitioner's answer to Q5

Present the draft PRD to the practitioner for review before proceeding.

### Step 4: Create the technical specification

After practitioner approves the PRD (set `status: in-review` and ask for confirmation):

Copy `templates/spec/SPEC-TEMPLATE.md` to `project/.sdlc/specs/SPEC-NNN-[kebab-feature-name].md`.

Fill in:
- frontmatter: id, parent (PRD-NNN), date, sprint
- Architecture overview: propose the component structure based on the feature description
- API contracts: draft based on the user stories
- Data models: draft minimal schema needed
- Acceptance criteria: map each EARS story to a measurable AC

For AI-native features, also complete:
- Add AI quality acceptance criteria (probabilistic thresholds)
- Note which model, prompt strategy, and orchestration decisions need ADRs

Present the draft SPEC for review.

### Step 5: Identify required ADRs

Analyze the SPEC and list every decision that needs an ADR:

**Always required for new features:**
- [ ] Is there a new external library? → Standard ADR
- [ ] Is there a new infrastructure component? → Standard ADR

**Required for AI-native features:**
- [ ] Which LLM model? → ADR-MODEL-SELECTION
- [ ] Which prompt strategy? → ADR-PROMPT-STRATEGY
- [ ] Single agent or orchestrated? → ADR-AGENT-ORCHESTRATION (if orchestrated)

List the required ADRs to the practitioner. Offer to create stubs:
```
I've identified [N] ADRs needed before implementation can begin:
1. [ADR type]: [Decision area]
2. [ADR type]: [Decision area]

Would you like me to create stub files for these now, or will you fill them in manually?
```

### Step 6: Create the task breakdown

After the SPEC is approved:

Analyze the SPEC's "Implementation order" section and create TASK files in `project/.sdlc/specs/` using `templates/task/TASK-TEMPLATE.md`.

For each task:
- Generate the next available TASK-NNN ID
- Fill in spec reference, session start instructions, file scope, and implementation specification from the SPEC
- Estimate token budget: small (<16K), medium (16K–64K), large (>64K)
- Mark parallel-executable tasks with `parallel: true`
- Set dependencies between sequential tasks

### Step 7: Summary report

Present a summary to the practitioner:

```
## Feature scaffold complete: [Feature Name]

### Artifacts created:
- PRD-NNN: [path] — status: in-review
- SPEC-NNN: [path] — status: draft
- TASK-NNN through TASK-NNN: [N tasks created]

### ADRs required before implementation:
- [ ] [ADR type] for [decision]: create with ./tools/scripts/new-adr.sh

### Next steps:
1. Review and approve PRD-NNN
2. Review and approve SPEC-NNN  
3. Create and accept all required ADRs
4. Start TASK-NNN (first sequential task) — estimated [X]K tokens context
```

---

*BHIL AI-First Development Toolkit — Skill version 1.0*
