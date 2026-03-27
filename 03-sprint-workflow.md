# Guide 03: Sprint Workflow

**How to execute an AI-first sprint from kickoff to retrospective**

---

## Sprint anatomy

A sprint in this methodology is a **2-week cycle** that produces a complete artifact chain for each feature included. Unlike traditional sprints where the sprint boundary is the primary ceremony, here the **phase transitions within each feature** are the primary review checkpoints.

Every sprint has four phases that run in parallel across features at different stages:

```
Week 1, Days 1-2:  Specification (PRD + SPEC + ADR creation)
Week 1, Days 3-5:  Planning (Task breakdown, agent session design)
Week 2, Days 1-3:  Implementation (Claude Code sessions, PRs)
Week 2, Days 4-5:  Integration, evaluation, deploy, retro
```

For a solo practitioner, "in parallel" means different features are at different phases simultaneously. While Claude Code implements Feature A (already specified), you are writing the SPEC for Feature B (just approved at PRD level).

---

## Phase 1: Specification (Days 1–2)

### 1a. Write the PRD slice

Each sprint selects 2–4 features from the product backlog. For each selected feature, create a PRD slice using `templates/prd/PRD-TEMPLATE.md`. A PRD slice is a **scoped subset** of a feature — one or two user stories, not the entire feature set.

**PRD quality gate** (review yourself before proceeding):
- [ ] Problem statement is one sentence, no solution hints
- [ ] User stories use EARS format: `WHEN [trigger], the system SHALL [response]`
- [ ] Success metrics are quantified (not "improve performance" — "reduce P95 latency to <200ms")
- [ ] Out-of-scope items are explicitly listed
- [ ] No implementation details appear in the PRD

Set status to `in-review`. Review it yourself tomorrow with fresh eyes. Set to `approved` to proceed.

### 1b. Draft the technical specification

With Claude Code, generate the SPEC from the approved PRD:

```
Read PRD-NNN and create a technical specification using templates/spec/SPEC-TEMPLATE.md.
Reference the PRD in the spec frontmatter. Do not start implementation.
```

Claude Code drafts the SPEC including architecture notes, API contracts, and data model sketches. **Review it yourself.** Specifically verify:
- [ ] API contracts are precise (exact request/response schemas)
- [ ] Data models include field names, types, and constraints
- [ ] Component boundaries are clearly defined
- [ ] No ambiguity that would require agent clarification during implementation

### 1c. Create required ADRs

For any architectural decision introduced by this feature, create an ADR **before** the spec is approved. Common triggers:
- First time using a new library or service
- Choosing between two valid approaches
- Any LLM model, prompt strategy, or agent orchestration decision
- Infrastructure or deployment changes

```bash
./tools/scripts/new-adr.sh "Decision title" standard
./tools/scripts/new-adr.sh "Model for this feature" model-selection
```

ADRs block spec approval. Do not proceed to task breakdown with unresolved architectural decisions.

---

## Phase 2: Planning (Days 3–5)

### 2a. Task decomposition

With the SPEC approved, instruct Claude Code to generate the task breakdown:

```
Read SPEC-NNN and break it into implementable tasks using templates/task/TASK-TEMPLATE.md.
Each task must fit within a single Claude Code session (estimate < 64K tokens of context needed).
Mark tasks that can run in parallel with [P]. Mark sequential dependencies explicitly.
```

**Task sizing rules:**
- Simple function or utility: 1 task
- Module with tests: 1–2 tasks
- Cross-cutting feature: 3–5 tasks, clearly sequenced
- Database migration: always a standalone task, never combined

Each task file must include:
- Exact file paths to create or modify
- Function or class signatures to implement
- Test requirements (which test cases to write)
- Specific acceptance criteria from the SPEC
- Definition of done

### 2b. Session design

For each task, decide which agent configuration to use:

| Task type | Claude Code config | RuFlo topology |
|---|---|---|
| Standard implementation | Single session + code-reviewer subagent | N/A |
| Large refactor | Single session + fresh context | N/A |
| Multi-component feature | Sequential sessions with handoff | Pipeline |
| Independent parallel modules | Multiple worktrees | Hierarchical |
| Complex research + implement | Research → compact → implement | Sequential |

For multi-session tasks, write the session handoff prompt now — it will be pasted at the start of each subsequent session.

### 2c. Sprint plan finalization

Compile the sprint plan using `templates/sprint/SPRINT-PLAN-TEMPLATE.md`. Include:
- All features with their PRD/SPEC/ADR references
- All tasks with parallel/sequential markers
- Session schedule (morning review, afternoon PM work, async implementation)
- Definition of done for the sprint
- Risk register for non-deterministic AI features

---

## Phase 3: Implementation (Week 2, Days 1–3)

### 3a. Starting each Claude Code session

Every implementation session begins the same way:

```
Today's task: [TASK-NNN title]

Context files to read first:
- project/.sdlc/context/architecture.md (project ADR registry)
- project/.sdlc/specs/SPEC-NNN.md (feature specification)
- docs/adr/ADR-NNN.md (relevant architectural decisions)
- project/prompts/v1/ (if working with prompts)
- [progress.md path if continuing from previous session]

Implementation rules:
- Write tests first. Confirm they fail. Do not modify tests to make them pass.
- Do not modify files outside the task scope.
- Create a progress.md at session end with decisions made and next steps.
- Open a PR when the task is complete, do not merge.
```

### 3b. The test-first gate

This is non-negotiable for AI-generated code. Claude Code will sometimes modify tests to make them pass rather than fixing the implementation. The countermeasure:

1. Instruct Claude Code to write tests first
2. Confirm tests fail (commit this state as a checkpoint)
3. Then instruct implementation: "Implement until tests pass. Do not modify test files."

### 3c. During-session monitoring

Check in every 30–45 minutes on long sessions:
- Context utilization (visible in Claude Code session stats)
- Git diff: is scope creep occurring?
- Test status: are they running and failing for the right reasons?

At 60% context utilization, trigger manual compaction:
```
/compact "Preserve only: current task spec requirements, file paths being modified, test results, and decisions made so far"
```

### 3d. Session close ritual

Before ending any implementation session, instruct Claude Code:
```
Before closing: create project/.sdlc/knowledge/progress-[TASK-NNN]-[date].md with:
- What was completed
- Decisions made (especially any that should become ADRs)
- Test results and coverage
- Exact next steps for continuation
- Any questions that arose that should update the SPEC
```

---

## Phase 4: Integration & Review (Week 2, Days 4–5)

### 4a. PR review ritual (solo practitioner)

Review every PR yourself using this checklist:

**Specification alignment**
- [ ] Implementation matches the SPEC — not just functionally, but structurally
- [ ] API contracts match what was specified (exact field names, types, status codes)
- [ ] No features were added beyond scope

**Architecture compliance**
- [ ] No dependency boundary violations (check against ADRs)
- [ ] No new external dependencies introduced without an ADR
- [ ] Prompt versions match the registered versions in `project/prompts/`

**Test quality**
- [ ] Tests were written before implementation (check git history)
- [ ] Tests are not trivially passing (read the assertions)
- [ ] For AI components: eval suite runs and passes at defined threshold

**Security**
- [ ] No secrets in code
- [ ] Input validation present on all external-facing endpoints
- [ ] PII handling follows the guardrails spec

**Documentation**
- [ ] progress.md was created
- [ ] Any new architectural decisions are captured as ADR drafts

### 4b. Evaluation runs

For AI-native features, run the eval suite before merging:
```bash
npx promptfoo eval --config project/evals/suite.yaml --output evals/results-[date].json
```

Pass threshold: defined in the feature's SPEC acceptance criteria. If the threshold is not met, the task is **not done** — regardless of whether unit tests pass.

### 4c. Deploy with feature flags

All AI-native features deploy behind feature flags set to OFF. Use LaunchDarkly, Unleash, or a simple environment variable — the mechanism matters less than the discipline.

Enable flags progressively: 1% → 5% → 25% → 100%, monitoring error rates and eval metrics at each stage.

### 4d. Sprint retrospective

At sprint close, use `templates/sprint/SPRINT-RETRO-TEMPLATE.md` to capture:
- Specification quality (how many agent questions arose?)
- ADR completeness (were there decisions without ADRs?)
- Eval results (did AI features meet thresholds?)
- Process improvements for next sprint
- Updated context for `project/.sdlc/context/architecture.md`

---

## Definition of done for AI-first sprints

A feature is **done** when all of the following are true:

**Artifact chain**
- [ ] PRD: `status: complete`
- [ ] SPEC: `status: complete`
- [ ] All required ADRs: `status: accepted`
- [ ] All tasks: `status: complete`

**Code quality**
- [ ] PR reviewed and approved by practitioner
- [ ] All unit tests passing
- [ ] Architecture compliance check passing
- [ ] No secrets or dependency violations

**AI-specific quality** (for LLM-powered features)
- [ ] Eval suite passing at defined threshold (≥N% on M runs)
- [ ] Golden dataset coverage ≥ 50 test cases
- [ ] Prompt version registered and frozen in `project/prompts/`
- [ ] Guardrails spec implemented and tested

**Deployment**
- [ ] Feature deployed behind feature flag (flag: OFF)
- [ ] Monitoring configured (error rate, latency, eval score in production)
- [ ] Rollback procedure documented

---

*Next: Read `guides/04-context-management.md` to learn how to prevent context fragmentation across sessions.*

*BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
