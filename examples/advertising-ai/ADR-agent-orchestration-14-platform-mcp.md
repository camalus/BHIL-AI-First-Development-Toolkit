---
id: ADR-ORCH-001
title: "Use Orchestrator-Worker pattern for 14-platform advertising MCP server fleet"
status: accepted
type: agent-orchestration
date: 2026-03-12
decision_makers: [John Williams]
related_prds: [PRD-MINI-001]
related_specs: [SPEC-MINI-001]
related_adrs: [ADR-MODEL-001]
sprint: S-04
tags: [agent, orchestration, multi-agent, mcp, advertising, production]
---

# ADR-ORCH-001: Use Orchestrator-Worker Pattern for 14-Platform Advertising MCP Fleet

## Context and problem statement

MiniAgent is a trainable advertising AI that must coordinate campaign management across 14 ad platforms simultaneously: Google Ads, Meta Ads, Microsoft Ads, Amazon Ads, LinkedIn Ads, Pinterest Ads, TikTok Ads, Twitter/X Ads, Snapchat Ads, Reddit Ads, Quora Ads, Criteo, AdRoll, and The Trade Desk. Each platform has a distinct API contract, authentication model, rate limit scheme, and data schema. A single agent cannot hold 14 platform APIs in context without degradation, and cross-platform operations (budget reallocation, unified reporting) require synthesizing data from multiple sources in a single turn.

**Decision question:** What agent orchestration pattern best handles cross-platform ad operations across 14 distinct APIs given requirements for sub-10-second response times, $0.10/query cost ceiling, and zero tolerance for unauthorized mutations?

---

## Decision drivers

- **Workflow complexity:** Cross-platform audit requires data from 3–14 APIs in a single user request; each API has unique authentication, pagination, and error handling
- **Latency budget:** P95 total response < 10,000ms for read operations; write operations may take up to 30s with human approval loop
- **Cost ceiling:** Max $0.10 per user query at 500 queries/day = $50/day operating cost
- **Error tolerance:** Read failures on one platform must not block results from others; write failures must halt and surface to user immediately
- **Safety:** All write operations (pause campaign, change budget, add negative keywords) require explicit human approval before execution — Confirm-Execute-Postcheck (CEP) protocol
- **Scalability:** Must support adding new platforms without modifying orchestration logic

---

## Orchestration patterns evaluated

### Pattern 1: Orchestrator-Worker (Hierarchical)
A central orchestrator agent decomposes cross-platform requests and delegates to platform-specific MCP servers. Each server is a standalone FastMCP process with its own tools, auth, and context.

**Strengths:** Platform isolation means adding a 15th platform requires zero changes to existing servers. Each worker holds only its platform's API context. CEP protocol is enforceable at the orchestrator layer.
**Weaknesses:** Orchestrator is a bottleneck; must understand all 14 platform capabilities to route correctly.
**Token overhead:** 1 orchestrator call + N worker calls (N = platforms queried).

### Pattern 2: Pipeline (Sequential)
Query flows through each platform server sequentially: Google → Meta → Microsoft → ...

**Strengths:** Simple implementation.
**Weaknesses:** 14 sequential API calls with ~700ms each = ~10s minimum latency for full-platform queries. Context grows unboundedly as each stage appends results. Catastrophic for user experience.
**Token overhead:** 14 sequential LLM calls with compounding context.

### Pattern 3: Swarm (Parallel + Aggregate)
All 14 servers query simultaneously; results aggregated by a synthesizer.

**Strengths:** Parallel execution minimizes latency. Platform independence.
**Weaknesses:** 14× cost for every query even when user only needs 1–2 platforms. No intelligent routing. Aggregation logic is complex when platforms return incompatible schemas.
**Token overhead:** 14 parallel LLM calls + 1 aggregation call = 15 calls minimum.

### Pattern 4: Mesh (Peer-to-peer)
Servers communicate directly to fulfill cross-platform operations.

**Strengths:** No central bottleneck.
**Weaknesses:** 14 servers with peer-to-peer communication = 182 possible edges. Impossible to enforce CEP protocol consistently. Debug nightmare. Cost unpredictable.
**Token overhead:** Unbounded.

---

## Decision outcome

**Chosen pattern: Orchestrator-Worker (Hierarchical)**

**Rationale:** The orchestrator-worker pattern provides the only viable combination of intelligent routing (query 2 platforms when 2 are needed, not 14), platform isolation (each MCP server is a standalone process with its own auth), and centralized safety enforcement (CEP write-approval lives in the orchestrator, not scattered across 14 servers). The orchestrator bottleneck is acceptable because the orchestrator itself is stateless and lightweight — it routes requests, it doesn't execute API calls.

---

## Architecture specification

```
[MiniAgent Orchestrator]
    ├── [google_ads MCP]    — 29 tools: campaigns, keywords, budgets, GAQL
    │       Transport: stdio | HTTP
    │       Auth: OAuth 2.0 refresh token
    │
    ├── [meta_ads MCP]      — 22 tools: campaigns, ad sets, audiences, insights
    │       Transport: stdio | HTTP
    │       Auth: Long-lived access token
    │
    ├── [microsoft_ads MCP] — 18 tools: campaigns, keywords, UET tags
    │       Transport: stdio | HTTP
    │       Auth: OAuth 2.0 + developer token
    │
    ├── [amazon_ads MCP]    — 15 tools: sponsored products, brands, display
    │       Transport: stdio | HTTP
    │       Auth: LWA OAuth
    │
    ├── [linkedin_ads MCP]  — 12 tools: campaigns, audiences, conversions
    ├── [pinterest_ads MCP] — 10 tools: campaigns, pins, audiences
    ├── [tiktok_ads MCP]    — 12 tools: campaigns, creatives, pixels
    ├── [twitter_ads MCP]   — 10 tools: campaigns, promoted tweets
    ├── [snapchat_ads MCP]  — 8 tools: campaigns, creative, audiences
    ├── [reddit_ads MCP]    — 8 tools: campaigns, subreddit targeting
    ├── [quora_ads MCP]     — 6 tools: campaigns, question targeting
    ├── [criteo MCP]        — 10 tools: campaigns, product feeds
    ├── [adroll MCP]        — 8 tools: campaigns, retargeting
    └── [tradedesk MCP]     — 12 tools: campaigns, DSP inventory
```

### Tool count summary

| Platform | Read tools | Write tools | Total |
|---|---|---|---|
| Google Ads | 18 | 11 | 29 |
| Meta Ads | 14 | 8 | 22 |
| Microsoft Ads | 11 | 7 | 18 |
| Amazon Ads | 10 | 5 | 15 |
| LinkedIn Ads | 8 | 4 | 12 |
| TikTok Ads | 8 | 4 | 12 |
| Pinterest Ads | 7 | 3 | 10 |
| Twitter/X Ads | 7 | 3 | 10 |
| Criteo | 7 | 3 | 10 |
| The Trade Desk | 8 | 4 | 12 |
| Snapchat Ads | 5 | 3 | 8 |
| Reddit Ads | 5 | 3 | 8 |
| AdRoll | 5 | 3 | 8 |
| Quora Ads | 4 | 2 | 6 |
| **Total** | **117** | **63** | **180** |

### Context isolation policy

- [x] Each MCP server runs as an independent process — no shared memory
- [x] Workers receive only the user's query and platform-specific credentials
- [x] Worker outputs are structured (JSON tool results or plain text summaries)
- [x] Orchestrator assembles cross-platform responses from worker outputs
- [x] Authentication credentials are scoped per-server via environment variables

---

## Safety: Confirm-Execute-Postcheck (CEP) protocol

All write operations across all 14 platforms follow CEP:

```
1. CONFIRM  — Agent describes proposed change in plain language
               "I will pause Campaign 'Brand - US' (ID: 12345) in Google Ads"
2. APPROVE  — Human explicitly approves or rejects
3. EXECUTE  — API mutation runs only after approval
4. POSTCHECK — Agent re-reads the resource to verify the change took effect
               "Confirmed: Campaign 12345 status is now PAUSED"
```

**Enforcement:** CEP is enforced at the orchestrator level. MCP servers expose write tools, but the orchestrator gates them behind the approval flow. No write tool executes without a prior approval signal in the conversation context.

---

## Error handling specification

| Failure scenario | Detection | Recovery action |
|---|---|---|
| Platform API timeout | 8s timeout per server | Return partial results from other platforms; note which platform timed out |
| Auth token expired | 401 response | Attempt token refresh once; if fails, surface re-auth prompt to user |
| Rate limit hit | 429 response | Exponential backoff (1s, 2s, 4s); max 3 retries; then surface to user |
| Write operation fails | Non-2xx on mutation | Do NOT retry writes. Surface error immediately. Log full request/response. |
| Platform API deprecated | Unexpected schema | Log warning; return degraded response; create GitHub issue via webhook |
| Orchestrator failure | Exception handler | Return graceful error; log full trace; no partial writes |

---

## Cost and latency model

| Scenario | Platforms queried | LLM calls | Estimated cost | Estimated latency |
|---|---|---|---|---|
| Single-platform read | 1 | 2 (route + execute) | $0.015 | 1,800ms |
| Cross-platform audit (3 platforms) | 3 | 4 (route + 3 parallel) | $0.045 | 3,200ms |
| Full-portfolio report (all 14) | 14 | 15 (route + 14 parallel) | $0.092 | 8,500ms |
| Single-platform write (CEP) | 1 | 4 (route + confirm + execute + postcheck) | $0.035 | 4,500ms + human wait |

**Circuit breaker:** If cost per request exceeds $0.15, abort and return error.

---

## Adding a new platform

Adding platform 15 requires:

1. Create `mcp_servers/new_platform/__init__.py` with FastMCP tools
2. Create `mcp_servers/new_platform/__main__.py` with transport setup
3. Add platform credentials to `.env`
4. Register in `.mcp.json` configuration
5. No changes to orchestrator, other servers, or CEP protocol

**Time to add a new platform:** ~2 hours for read-only tools; ~4 hours including write tools with CEP.

---

## Rejected patterns

### Pipeline (Sequential)
**Rejected because:** 14 sequential platform queries at ~700ms each = ~10s minimum latency. This exceeds the 10s P95 budget with zero headroom. Context grows with each pipeline stage, degrading quality on later platforms. Not viable.

### Swarm (Parallel + Aggregate)
**Rejected because:** Querying all 14 platforms on every request wastes 12 API calls when the user asks about a single platform (which is ~70% of queries). At $0.092 per full-swarm query, this would blow through the $50/day budget at just 543 queries. The orchestrator-worker pattern allows routing to 1–3 platforms for most queries, keeping average cost at ~$0.025.

### Mesh (Peer-to-peer)
**Rejected because:** 14 servers with peer-to-peer communication creates 182 possible edges. CEP protocol cannot be enforced consistently when any server can call any other server. Debugging cross-platform failures requires tracing through an arbitrary graph. Cost is unpredictable. Not viable for production.

---

## Consequences

**Positive:**
- Platform isolation means any server can be upgraded, swapped, or disabled independently
- CEP protocol is enforced in exactly one place (orchestrator), not 14
- Adding platform 15 is a 2–4 hour task with zero changes to existing code
- Intelligent routing keeps average cost at $0.025/query vs. $0.092 for swarm

**Negative:**
- Orchestrator must understand all 14 platform capabilities to route correctly — this is the most complex prompt in the system
- Orchestrator is a single point of failure (mitigated by stateless design + restart policy)
- Full-portfolio queries approach the latency budget (8.5s of 10s)

---

## Related decisions

- **Model selection (orchestrator + workers):** ADR-MODEL-001
- **Prompt strategy (routing prompt):** Documented in `mcp_servers/google_ads/__init__.py` docstrings
- **CEP protocol spec:** Documented in project README

---

*Production example — contributed by John Williams ([itallstartedwithaidea](https://github.com/itallstartedwithaidea)) — BHIL AI-First Development Toolkit*
