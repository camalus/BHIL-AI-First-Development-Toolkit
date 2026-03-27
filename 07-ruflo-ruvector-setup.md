# Guide 07: RuFlo and RuVector Setup

**Integrating Agentics Foundation tooling with the BHIL AI-First Toolkit**

---

## Overview

**RuFlo** is a multi-agent orchestration framework that extends Claude Code into a coordinated swarm of specialized agents. **RuVector** is a self-learning vector database with graph neural network intelligence that provides persistent cross-session memory for your agents.

Both are built by Reuven Cohen (rUv) and published under the Agentics Foundation. They are separate tools that work powerfully together and integrate natively with Claude Code.

**Important disambiguation:** The Agentics Foundation (agentics.org, rUv's organization) is separate from the Agentic AI Foundation (AAIF, Linux Foundation project). Both exist; they are unaffiliated. The AAIF governs MCP and AGENTS.md. RuFlo and RuVector come from the former.

---

## When to use RuFlo and RuVector

**Use this toolkit without RuFlo/RuVector** when:
- Building a single-service AI-native app with sequential features
- Solo development with one agent session at a time
- Context management needs are handled by the filesystem patterns in Guide 04

**Add RuFlo** when:
- A feature requires multiple specialized agents working in parallel (orchestrator-worker or pipeline patterns)
- You want to run 3–5 Claude Code instances simultaneously across different tasks
- You need the three-tier model router (WASM → Sonnet → Opus) to optimize costs automatically

**Add RuVector** when:
- Agent sessions need persistent memory across more than 5–10 sessions (the filesystem `progress.md` pattern starts to break down)
- You want semantic search over your project's decision history ("what did we decide about authentication?")
- You're building a RAG pipeline and need a local self-learning vector store rather than a cloud service

---

## Installing RuFlo

```bash
# Install globally
npm install -g ruflo

# Initialize in your project (creates CLAUDE.md, .claude/, .claude-flow/)
npx ruflo@latest init

# If you also use AGENTS.md (cross-tool compatibility):
npx ruflo@latest init --dual
# Creates both CLAUDE.md and AGENTS.md with a shared runtime

# Verify installation
ruflo --version
```

After initialization, RuFlo creates:
```
project/
├── CLAUDE.md                    (updated with RuFlo configuration)
├── .claude-flow/
│   ├── config/
│   │   └── swarm.json           (topology configuration)
│   ├── memory/                  (persistent agent memory — backed by RuVector if configured)
│   └── hooks/                   (RuFlo lifecycle hooks)
```

---

## Configuring the swarm topology

Edit `.claude-flow/config/swarm.json` to match your orchestration ADR:

```json
{
  "topology": "hierarchical",
  "queen": {
    "type": "Tactical",
    "model": "claude-opus-4-20250514",
    "description": "Orchestrates task decomposition and delegates to workers"
  },
  "workers": [
    {
      "name": "spec-writer",
      "specialization": "specification-drafting",
      "model_tier": 2,
      "max_tokens": 4096,
      "tools": ["Read", "Write", "Glob"]
    },
    {
      "name": "code-implementer",
      "specialization": "typescript-implementation",
      "model_tier": 2,
      "max_tokens": 8192,
      "tools": ["Read", "Write", "Bash", "Glob", "Grep"]
    },
    {
      "name": "code-reviewer",
      "specialization": "code-review-and-validation",
      "model_tier": 2,
      "max_tokens": 4096,
      "tools": ["Read", "Bash", "Glob", "Grep"]
    }
  ],
  "model_routing": {
    "tier1_wasm": ["formatting", "linting", "simple-transforms"],
    "tier2_fast": ["implementation", "testing", "documentation"],
    "tier3_complex": ["architecture", "complex-reasoning", "orchestration"]
  },
  "cost_ceiling_per_session": 5.00,
  "max_concurrent_workers": 3
}
```

---

## MCP integration with Claude Code

Add RuFlo as an MCP server to Claude Code:

```bash
claude mcp add ruflo-mcp npx ruflo@alpha mcp start
```

This exposes RuFlo's 215+ tools to Claude Code sessions, including:
- `spawn_worker` — Start a specialized worker agent for a task
- `coordinate_swarm` — Orchestrate multiple workers on a complex task
- `query_memory` — Retrieve relevant past decisions from RuVector memory
- `store_decision` — Persist an architectural decision to long-term memory

---

## Installing RuVector

```bash
# Via npm (JavaScript/TypeScript projects)
npm install ruvector

# Via npm CLI (standalone)
npm install -g ruvector

# Initialize with Claude Code hooks and pre-training
npx ruvector hooks init --pretrain --build-agents quality
```

The `--pretrain` flag runs a 9-phase pipeline on your project:
1. AST analysis (code structure)
2. Git diff analysis (co-change patterns)
3. Test coverage analysis
4. Neural analysis (semantic relationships)
5. Graph analysis (dependency relationships)
6. Quality analysis
7. Pattern recognition
8. Agent optimization
9. Index building

This generates `.claude/agents/` configurations optimized for your specific codebase.

---

## Using RuVector for project memory

### Storing decisions during a session

```typescript
import RuVector from 'ruvector';

const db = new RuVector({ path: '.claude-flow/memory/project.rvf' });
await db.init();

// Store a decision with metadata
await db.insert({
  content: "Chose Claude Sonnet 4 for RAG response generation based on 0.91 faithfulness score",
  metadata: {
    type: "architectural-decision",
    adr: "ADR-001",
    sprint: "S-01",
    date: "2026-03-26",
    tags: ["model-selection", "rag", "llm"]
  }
});
```

### Querying memory in a new session

In Claude Code, add to your session start prompt:
```
Before beginning: query RuVector memory for relevant past decisions:
- "authentication decisions"
- "model selection for [capability]"
- "prompt strategy for [feature type]"

Use this tool: mcp__ruflo-mcp__query_memory
query: "[your query]"
top_k: 5
```

### Semantic search over your project history

```typescript
// Find all decisions related to a topic
const results = await db.search({
  query: "how did we handle authentication",
  top_k: 5,
  filter: { type: "architectural-decision" }
});

results.forEach(r => {
  console.log(`[${r.metadata.adr}] ${r.content} (similarity: ${r.score})`);
});
```

---

## Integration with the BHIL sprint workflow

### Sprint initialization with RuFlo

Replace the manual session schedule with a RuFlo orchestrated sprint:

```bash
# Start the sprint with RuFlo orchestration
ruflo start-sprint \
  --plan project/sprints/S-01/SPRINT-PLAN.md \
  --topology hierarchical \
  --workers 3
```

RuFlo reads the sprint plan, extracts parallel tasks, and dispatches them to worker agents automatically.

### Context handoff through RuVector

Instead of the `progress.md` handoff pattern, RuVector maintains persistent session memory:

```bash
# At session end (hook in .claude-flow/hooks/session-end.sh)
npx ruvector store --content "$(cat /tmp/session-summary.md)" --tags "session,TASK-${TASK_ID}"

# At session start (hook in .claude-flow/hooks/session-start.sh)  
npx ruvector query --q "TASK-${TASK_ID} progress" --top_k 3
```

The `progress.md` pattern from Guide 04 remains valid as a fallback and is always generated — RuVector augments it rather than replacing it.

---

## Performance and cost expectations

| Configuration | Token cost vs. single agent | Quality | Use case |
|---|---|---|---|
| Single Claude Code | 1× | Baseline | Simple features, sequential tasks |
| RuFlo 2-worker | 2.5× | +15% on complex tasks | Parallel implementation |
| RuFlo 3-worker hierarchical | 4–5× | +20% on complex tasks | Multi-component features |
| RuFlo full swarm (10+ workers) | 8–12× | Variable | Large-scale analysis |

**Recommended for solo practitioners:** 2–3 workers maximum. More workers increase token costs faster than they improve quality for features in the 16K–64K token range.

---

## Troubleshooting

**RuFlo workers not receiving context:**
Check that worker agents have `tools: [Read]` configured in their agent definitions — they cannot read files without it.

**RuVector returning stale results:**
Run `npx ruvector reindex` to rebuild the GNN index after major changes to the codebase.

**High token costs from orchestration:**
Enable the tier-1 WASM router for formatting and linting tasks: `"tier1_tasks": ["prettier", "eslint"]` in `swarm.json`.

**Worker agent scope creep:**
Add explicit scope constraints to each worker's agent definition file in `.claude/agents/`. The `tools` field limits what the agent can access — use it aggressively.

---

*Next: Read `guides/08-automation.md` for configuring GitHub Actions, pre-commit hooks, and CI/CD pipelines.*

*BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
