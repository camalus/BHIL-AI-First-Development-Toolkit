---
id: TASK-NNN
title: "[Verb + noun: e.g., 'Implement NotificationService with unit tests']"
status: draft              # draft | ready | in-progress | complete | blocked
spec: SPEC-NNN
adrs: [ADR-NNN]            # ADRs governing this task
sprint: S-NN
parallel: false            # true if this task can run concurrently with others
depends_on: []             # TASK IDs that must complete before this one
estimated_tokens: NNK      # Rough context estimate: 8K | 16K | 32K | 64K
session_handoff: null      # Path to progress.md if continuing from prior session
---

# TASK-NNN: [Task Title]

## Task context

<!--
Orient the agent before it reads anything else.
State exactly what this task is, why it exists, and what "done" looks like.
-->

**Feature:** [Feature name from SPEC-NNN]
**Purpose:** [One sentence — what this task implements and why]
**Session type:** [Fresh start | Continuation from TASK-NNN]

---

## Session start instructions

<!--
Copy-paste this block at the start of every Claude Code session for this task.
-->

```
Session context for TASK-[NNN]:

Read these files in order before doing anything else:
1. project/.sdlc/context/architecture.md   → project architectural constraints
2. docs/adr/[ADR-NNN].md                   → governing decision(s) for this task
3. [SPEC-NNN file path]                     → feature specification
[4. project/.sdlc/knowledge/progress-TASK-NNN-[date].md → if continuing]

Confirm understanding by stating:
- What you will implement
- Which files you will create or modify (list them)
- What the definition of done is

Wait for my confirmation before proceeding.
```

---

## Scope

### Files to CREATE

| File path | Purpose |
|---|---|
| `src/[path/to/file].ts` | [What this file contains] |
| `tests/unit/[path/to/test].test.ts` | [What this test covers] |
| `tests/integration/[path/to/test].test.ts` | [What this test covers] |

### Files to MODIFY

| File path | Change description |
|---|---|
| `src/[existing/file].ts` | [Specific change — e.g., "Add NotificationService to DI container"] |
| `src/[config/file].ts` | [Specific change] |

### Files to NOT TOUCH

The following are explicitly out of scope for this task:
- `src/[path]/` — belongs to TASK-NNN (different sprint/feature)
- `docs/adr/` — ADRs are never modified by implementation tasks
- `[config file]` — requires separate ADR before modification

---

## Implementation specification

<!--
Enough detail that the agent implements correctly on the first pass.
Function signatures, business logic, and error handling all specified here.
-->

### Interfaces and signatures

```typescript
// Exact signatures to implement — do not deviate without updating this TASK

export interface [InterfaceName] {
  [methodName](param: ParamType): Promise<ReturnType>;
}

export class [ClassName] implements [InterfaceName] {
  constructor(
    private readonly [dep1]: [Dep1Type],
    private readonly [dep2]: [Dep2Type]
  ) {}

  async [methodName](param: ParamType): Promise<ReturnType> {
    // Implementation here
  }
}
```

### Business logic (step by step)

```
1. [First step — precise, no ambiguity]
2. [Second step]
   IF [condition]: [specific action]
   ELSE: [fallback action]
3. [Third step]
4. Emit event: [EventName] with payload { [field]: value }
5. Return: [exact return shape]
```

### Error handling

| Error condition | Detection | Response |
|---|---|---|
| [Error type] | [How detected] | Throw `[ErrorClass]` with message `"[message template]"` |
| [Error type] | [How detected] | Log warning, return [fallback value] |
| [Timeout] | [X]ms timeout | Retry once, then throw `TimeoutError` |

---

## Test requirements

### Write tests FIRST

This task uses the test-first pattern:
1. Write all tests below — they must FAIL initially
2. Commit: `git commit -m "test: TASK-NNN failing tests"`
3. Then implement until tests pass
4. Do NOT modify test files during implementation

### Unit tests

**File:** `tests/unit/[component]-[method].test.ts`

```typescript
describe('[ClassName]', () => {
  describe('[methodName]', () => {
    it('should [expected behavior] when [condition]', async () => {
      // Arrange
      const input = [test input];
      const expected = [expected output];
      
      // Act
      const result = await [component].[method](input);
      
      // Assert
      expect(result).toEqual(expected);
    });

    it('should throw [ErrorType] when [error condition]', async () => {
      // Arrange + Act + Assert
      await expect([component].[method]([invalid input]))
        .rejects.toThrow('[ErrorType]');
    });

    // Edge cases to cover:
    // - [Edge case 1]
    // - [Edge case 2]
  });
});
```

### Integration tests

**File:** `tests/integration/[feature]-[scenario].test.ts`

Test the complete flow including:
- [ ] Happy path: [describe the scenario]
- [ ] Error path: [describe the error scenario]
- [ ] Boundary: [describe the boundary condition]

---

## Acceptance criteria

<!--
Every criterion is independently verifiable.
For AI-native components: include the eval command to run.
-->

- [ ] **AC-001:** `npm test tests/unit/[component]` passes with 0 failures
- [ ] **AC-002:** `npm test tests/integration/[feature]` passes with 0 failures
- [ ] **AC-003:** [Specific behavior verified by test AC-001]
- [ ] **AC-004:** [Performance: e.g., "Method completes in < [X]ms on benchmark input"] 
- [ ] **AC-005:** No imports from forbidden modules (verified by `npm run test:arch`)

**For AI-native components:**
- [ ] **AC-AI-001:** `npx promptfoo eval --config evals/[feature].yaml` passes at ≥[X.XX] [metric]
- [ ] **AC-AI-002:** Output validates against JSON schema on 100% of eval cases

---

## Definition of done

This task is COMPLETE when:

- [ ] All acceptance criteria above pass
- [ ] `npm run test:arch` passes (no dependency boundary violations)
- [ ] `npm run lint` passes with 0 errors
- [ ] TypeScript compiles with 0 errors (`npm run build`)
- [ ] PR opened (not merged) with title: `feat(TASK-NNN): [Task title]`
- [ ] `project/.sdlc/knowledge/progress-TASK-NNN-[date].md` written
- [ ] No files modified outside the scope section above

---

## Session close instructions

Before ending this session, write `project/.sdlc/knowledge/progress-TASK-NNN-[date].md`:

```markdown
# Progress: TASK-NNN — [date]

## Completed
- [bullet: what was done]
- [bullet: what was done]

## Test status
- Unit tests: [X]/[total] passing
- Integration tests: [X]/[total] passing
- Known failures: [describe if any]

## Files created/modified
- `[path]` — [what changed]

## Decisions made
- [Any decision that should become an ADR draft]

## Next steps
- [Exact first action for next session]
- [Any remaining acceptance criteria not yet met]

## Questions for spec update
- [Any ambiguity discovered that should update SPEC-NNN]
```

---

*Template version 1.0 — BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
