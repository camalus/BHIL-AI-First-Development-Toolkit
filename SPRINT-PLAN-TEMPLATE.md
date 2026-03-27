---
id: S-NN
title: "Sprint [NN]: [Theme]"
status: planning           # planning | active | complete
start: YYYY-MM-DD
end: YYYY-MM-DD
velocity_target: [N]       # Tasks targeted for completion
velocity_actual: null      # Filled at sprint close
---

# Sprint [NN]: [Theme]

**Duration:** [Start date] → [End date]
**Sprint goal:** [One sentence describing what will be true at the end of this sprint that is not true now]

---

## Features in this sprint

| Feature | PRD | SPEC | Status | Priority |
|---|---|---|---|---|
| [Feature 1] | PRD-NNN | SPEC-NNN | approved | high |
| [Feature 2] | PRD-NNN | SPEC-NNN | in-review | medium |
| [Feature 3] | PRD-NNN | draft | draft | low |

---

## ADRs required before implementation begins

| Decision area | ADR | Status | Blocking feature |
|---|---|---|---|
| [Model selection for Feature 1] | ADR-NNN | accepted | Feature 1 |
| [Orchestration pattern] | ADR-NNN | proposed | Feature 2 |

**ADR gate:** No task may start implementation until all blocking ADRs are `accepted`.

---

## Task board

### Sequential tasks (must run in order)

| Order | Task | Spec | Est. tokens | Status | Session date |
|---|---|---|---|---|---|
| 1 | TASK-NNN: [Title] | SPEC-NNN | 32K | ready | [Date] |
| 2 | TASK-NNN: [Title] | SPEC-NNN | 16K | blocked (needs TASK-NNN) | — |
| 3 | TASK-NNN: [Title] | SPEC-NNN | 64K | blocked (needs TASK-NNN) | — |

### Parallel tasks (can run in any order / simultaneously)

| Task | Spec | Est. tokens | Status | Session date |
|---|---|---|---|---|
| TASK-NNN: [Title] [P] | SPEC-NNN | 8K | ready | [Date] |
| TASK-NNN: [Title] [P] | SPEC-NNN | 16K | ready | [Date] |
| TASK-NNN: [Title] [P] | SPEC-NNN | 32K | ready | [Date] |

---

## Session schedule

### Week 1

| Day | Human activity | Claude Code sessions |
|---|---|---|
| Mon | Review PRDs, finalize SPECs | None |
| Tue | Write ADRs, review SPECs | None |
| Wed | Approve specs, start TASK-NNN | TASK-NNN (sequential 1) |
| Thu | Review TASK-NNN PR | TASK-NNN (sequential 2) |
| Fri | Review TASK-NNN PR | TASK-NNN (parallel batch) |

### Week 2

| Day | Human activity | Claude Code sessions |
|---|---|---|
| Mon | Review parallel task PRs | TASK-NNN (sequential 3) |
| Tue | Integration review | None |
| Wed | Run eval suites, review results | TASK-NNN (fixes if needed) |
| Thu | Deploy behind flags, monitor | None |
| Fri | Sprint retrospective | None |

---

## AI-native quality gates

For features containing LLM-powered components:

| Feature | Eval suite | Threshold | Status |
|---|---|---|---|
| [Feature 1] | `evals/[feature-1].yaml` | Factuality ≥0.85, 50 cases | pending |
| [Feature 2] | `evals/[feature-2].yaml` | Relevance ≥0.80, 30 cases | pending |

**Eval gate:** No feature deploys until its eval suite passes threshold in CI.

---

## PR review checklist

Use this checklist for every PR review this sprint:

**Specification alignment**
- [ ] Implementation matches the SPEC — structurally, not just functionally
- [ ] API contracts match specified schemas (field names, types, status codes)
- [ ] No out-of-scope changes (check against TASK scope section)

**Architecture compliance**
- [ ] No dependency boundary violations (run `npm run test:arch`)
- [ ] No new external dependencies without an ADR
- [ ] Prompt versions match registered versions in `project/prompts/PROMPT-REGISTRY.md`

**Test quality**
- [ ] Tests were written before implementation (verify via git log)
- [ ] Tests are non-trivial (assertions match the expected behavior)
- [ ] For AI components: eval suite passes at defined threshold

**Security**
- [ ] No secrets or credentials in code
- [ ] Input validation on all external inputs
- [ ] PII handling follows guardrails spec

**Documentation**
- [ ] `progress.md` was written at session close
- [ ] New architectural decisions captured as ADR drafts
- [ ] SPEC updated if implementation revealed spec gaps

**Merge criteria:** All boxes checked OR explicit waiver documented in PR comment.

---

## Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Eval threshold not met for Feature 1 | Medium | High (blocks deploy) | Run eval suite mid-sprint; adjust prompts if score <0.80 at day 8 |
| Context degradation in long TASK-NNN session | High | Medium | Split into two sessions at context check |
| [Risk] | [L/M/H] | [L/M/H] | [Mitigation] |

---

## Definition of done (sprint level)

This sprint is COMPLETE when:

**Artifact chain**
- [ ] All PRDs: `status: complete`
- [ ] All SPECs: `status: complete`
- [ ] All ADRs: `status: accepted`
- [ ] All TASKs: `status: complete`

**Code quality**
- [ ] All PRs reviewed and merged
- [ ] `npm test` passes on main branch
- [ ] `npm run test:arch` passes
- [ ] No open security findings

**AI quality**
- [ ] All eval suites passing at defined thresholds
- [ ] All prompts versioned in `project/prompts/PROMPT-REGISTRY.md`
- [ ] Golden datasets updated with production failures discovered this sprint

**Deployment**
- [ ] All new features deployed behind feature flags (flags: OFF)
- [ ] Monitoring configured for each new AI component
- [ ] `project/.sdlc/context/architecture.md` updated with sprint learnings

---

*Template version 1.0 — BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
