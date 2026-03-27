## Summary

<!-- One paragraph: what this PR implements and why -->

**Task:** [TASK-NNN]
**Spec:** [SPEC-NNN]
**Sprint:** [S-NN]
**ADRs governing this work:** [ADR-NNN, ADR-NNN]

---

## Specification alignment

<!-- Verify implementation matches the SPEC — not just functionality, but structure -->

| Acceptance criterion | Status | Notes |
|---|---|---|
| AC-001: [criterion] | ✅ / ❌ / ⚠️ | |
| AC-002: [criterion] | ✅ / ❌ / ⚠️ | |
| AC-003: [criterion] | ✅ / ❌ / ⚠️ | |

---

## Architecture compliance

- [ ] No dependency boundary violations (`npm run test:arch` passes)
- [ ] No new external dependencies introduced without an ADR
- [ ] Prompt versions match registered versions in `project/prompts/PROMPT-REGISTRY.md`
- [ ] No files modified outside TASK-NNN scope

**ADR rules followed:**
- [ADR-NNN]: [How this PR complies with the decision]

---

## Test quality

- [ ] Tests were written BEFORE implementation (verify via git log order)
- [ ] All unit tests pass: `npm test tests/unit/`
- [ ] All integration tests pass: `npm test tests/integration/`
- [ ] No test mocks the behavior being tested

**For AI-native features:**
- [ ] Eval suite passes at threshold: `npx promptfoo eval --config evals/[feature].yaml`
- [ ] Eval score: [X.XX] [metric] on [N] cases (threshold: ≥[X.XX])
- [ ] Golden dataset updated with any production failures discovered

---

## Security

- [ ] No secrets, API keys, or credentials in any file
- [ ] Input validation present on all external-facing methods
- [ ] PII handling follows guardrails spec
- [ ] LLM outputs validated before returning to users

---

## Scope

Files created:
- `[path]` — [purpose]

Files modified:
- `[path]` — [what changed]

Files NOT touched (confirm):
- No files outside TASK-NNN scope were modified

---

## Session documentation

- [ ] `project/.sdlc/knowledge/progress-TASK-NNN-[date].md` written
- [ ] Any new architectural decisions captured as ADR drafts (or existing ADRs updated)
- [ ] Spec gaps discovered (if any): [describe or "None"]

---

## Review focus areas

<!-- Tell the reviewer where to focus their attention -->

Please pay particular attention to:
1. [Area 1 — e.g., "The error handling in src/services/[x].ts"]
2. [Area 2 — e.g., "Whether the prompt version in src/llm/[x].ts matches ADR-NNN"]

---

## Merge checklist

All of the following must be true before merging:

- [ ] All acceptance criteria in the table above are ✅
- [ ] All test suites pass (including eval suite if applicable)
- [ ] PR reviewed by practitioner
- [ ] progress.md written
- [ ] Feature deployed behind feature flag (flag: OFF)
