# Guide 04: Context Management

**Preventing context fragmentation across AI agent sessions**

---

## Why context management is critical

Microsoft Research found a **39% average performance drop** from single-turn to multi-turn LLM interactions. The quality cliff typically appears after 60–90 minutes of continuous work. Warning signs appear as early as 20% context utilization: Claude asks for information already provided, generates code conflicting with earlier decisions, or loses track of file structure.

For a solo practitioner running multiple parallel agent sessions across a 2-week sprint, context fragmentation is the primary risk to development quality — not agent capability.

---

## The context budget model

Claude Code's 200K token context window fills as follows:

| Component | Tokens | Control |
|---|---|---|
| Claude Code system prompt | ~3K | Fixed |
| CLAUDE.md (project config) | ~2K | You control — keep under 2K |
| Active skills loaded | ~1K–4K | You control — skills load on demand |
| Conversation history | Grows continuously | Manage with compaction |
| File contents read | Grows per file read | Scope your sessions tightly |
| Code generation | Grows per implementation | Size tasks appropriately |

**Practical budget:** Keep total context under **60% (120K tokens)** for consistent quality. At 60%, compact proactively. Never reach 83.5% (the auto-compaction threshold) — quality degrades before auto-compaction fires.

---

## The five context management patterns

### Pattern 1: One task per session (most important)

The single highest-leverage practice. Instead of "build the notification feature," scope sessions to:
- "Create the notifications database schema and migration"
- "Implement the NotificationService class with unit tests"
- "Create the notification API endpoints"

Each session starts with a fresh context window reading only what it needs. Sessions are isolated, parallelizable, and independently reviewable. Context rot is eliminated by design.

**Task sizing guide:**
- Simple function: ~8K–16K tokens needed → fits easily in one session
- Module with tests: ~32K–64K tokens → fits in one session with room
- Cross-cutting feature: ~128K tokens → split into 2–3 sessions
- Full system analysis: 200K+ → always split

### Pattern 2: The progress.md handoff

At the end of every implementation session, Claude Code writes a `progress.md` before the session closes. This file is the **only** context carried between sessions — not conversational history.

Instruct Claude Code at session end:
```
Write project/.sdlc/knowledge/progress-[TASK-ID]-[date].md containing:
1. Summary of what was completed (3–5 bullet points)
2. All architectural decisions made (format as ADR drafts if significant)
3. Test results: which pass, which fail, and why
4. Exact file paths created or modified
5. Next steps: the precise first action for the next session
6. Open questions that arose (these should update the SPEC)
```

The next session opens with:
```
Read project/.sdlc/knowledge/progress-[TASK-ID]-[date].md to orient yourself.
Then read [relevant SPEC and ADR files].
Your task is: [next step from progress.md]
```

### Pattern 3: Proactive manual compaction

At 60% context utilization, trigger targeted compaction before quality degrades:

```
/compact "Preserve only: 
- Current task scope and requirements from [TASK-NNN]
- File paths and function signatures being implemented  
- Test requirements and current pass/fail status
- Architectural decisions made in this session
Discard: earlier exploration, rejected approaches, tool output details"
```

Generic compaction loses important context. Targeted compaction with explicit preservation instructions retains what matters.

**Compaction frequency guidelines:**
- Simple tasks: compact once at ~60% if needed
- Complex tasks: compact at end of each "phase" within the task (explore → plan → implement → test)
- Research sessions: compact after research, before implementation begins

### Pattern 4: Hierarchical context architecture

Maintain five levels of persistent project context in the filesystem:

**Level 1 — Project constitution** (`CLAUDE.md` + `AGENTS.md`)
Always loaded. Contains: project identity, tech stack, ALWAYS/NEVER rules, command references. Maximum 200 lines total across both files.

**Level 2 — Architectural memory** (`project/.sdlc/context/architecture.md`)
Loaded explicitly at session start. Contains: all project-level ADR summaries, major design decisions, current system state. Updated after each sprint's retrospective. Maximum 500 lines.

**Level 3 — Feature context** (SPEC + relevant ADRs)
Loaded explicitly per task. Contains: the feature specification, data models, API contracts, and the ADRs governing this feature. Typically 2–5 files.

**Level 4 — Task context** (TASK-NNN + progress.md)
Loaded per implementation session. Contains: the specific task scope, previous session progress, and definition of done.

**Level 5 — Working context** (generated during session)
Files read and generated during the session. Managed by Claude Code automatically.

### Pattern 5: Git worktrees for parallel sessions

When running multiple agent sessions in parallel (different tasks from the same sprint), use git worktrees to provide complete isolation:

```bash
# Create isolated worktree for each parallel task
git worktree add ../project-task-007 -b feature/task-007
git worktree add ../project-task-008 -b feature/task-008

# Open separate Claude Code session in each
cd ../project-task-007 && claude
cd ../project-task-008 && claude
```

Each worktree has its own filesystem state, allowing agents to modify files without conflicting. Each session loads only the context for its specific task.

---

## Context quality signals

**Green signals** — healthy context, continue working:
- Claude accurately references earlier decisions without being reminded
- Generated code matches established patterns without explicit instruction
- Claude completes tasks on first attempt with no clarification questions

**Yellow signals** — context degrading, compact soon:
- Claude asks a question whose answer was already provided
- Generated code uses slightly different naming conventions than earlier files
- Claude references the wrong file path or function name

**Red signals** — context saturated, compact immediately or start fresh:
- Claude contradicts an earlier decision
- Generated code imports non-existent modules or functions
- Claude loses track of the task scope and implements beyond it
- Repeated clarification loops on the same topic

---

## RuFlo and RuVector for persistent memory

RuFlo's `.claude-flow/memory/` and RuVector's persistent vector database extend Claude Code's ephemeral context window with **cross-session memory**. This is particularly valuable for:

- **Agent learning**: RuVector's GNN learns which file pairs co-change frequently, enabling better context loading
- **Decision memory**: architectural decisions from any session are queryable in future sessions
- **Pattern memory**: code patterns that worked well are indexed and surfaced when similar work begins

See `guides/07-ruflo-ruvector-setup.md` for configuration. Even without RuFlo/RuVector, the filesystem-based patterns above provide adequate cross-session continuity.

---

## The session start ritual

Every implementation session opens with the same 4-step sequence. Build this into your workflow:

```
Step 1: Orient
Read project/.sdlc/context/architecture.md to understand current system state.
Read project/.sdlc/knowledge/[latest progress.md] if continuing a task.

Step 2: Scope
Read SPEC-NNN for this task's feature specification.
Read ADR-NNN (and any related ADRs) for governing decisions.
Read TASK-NNN for exact implementation scope.

Step 3: Confirm
State back to me: what you will implement, which files you will create or modify,
and what the definition of done is. Wait for my confirmation before proceeding.

Step 4: Implement
Write tests first. Confirm they fail. Then implement until tests pass.
Do not modify test files. Do not scope-creep beyond TASK-NNN.
```

Step 3 — the confirmation step — costs 30 seconds and prevents hours of rework from misaligned context.

---

*Next: Read `guides/05-ai-native-patterns.md` for LLM-specific documentation and specification patterns.*

*BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
