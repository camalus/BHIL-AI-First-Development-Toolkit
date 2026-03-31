---
id: GUARDRAILS-AD-001
title: "Advertising AI Platform Safety and Guardrails Specification"
status: accepted
date: 2026-03-12
feature: PRD-MINI-001 / SPEC-MINI-001
sprint: S-04
risk_level: high
external_facing: true
---

# Guardrails Specification: Advertising AI Platform (MiniAgent + ARGUS)

## Risk profile

**Risk level:** High
**Rationale:** System has write access to advertising accounts controlling real money. An unauthorized budget change, campaign pause, or negative keyword addition has immediate, measurable financial impact. Additionally, the system generates ad copy that represents client brands publicly, and validates creative assets that determine whether ads run or get rejected.

**What can go wrong (threat model):**
- **Unauthorized mutations:** Agent executes a budget increase, campaign pause, or keyword change without human approval — direct financial loss
- **Hallucinated API parameters:** Agent fabricates a customer_id, campaign_id, or GAQL query — wastes API quota, returns confusing errors, or worse, mutates the wrong account
- **Ad copy policy violations:** Generated ad copy contains prohibited claims (medical, financial guarantees), trademark violations, or misleading content — ads get disapproved, account gets flagged
- **Budget runaway:** Agent misinterprets "increase budget by 10%" as "set budget to 10× current" — catastrophic overspend
- **Cross-account contamination:** Agent applies changes to Account B when user intended Account A — data breach and financial impact
- **Fake engagement / trust fraud:** Bad actors submit fraudulent profiles through ARGUS to whitewash fake accounts

---

## Layer 1: Input guardrails

### 1.1 Content validation

| Check | Method | Action on violation | Latency |
|---|---|---|---|
| Customer ID format | Regex: `^\d{10}$` | Reject with "Invalid customer ID format" | <1ms |
| GAQL syntax pre-check | Parser validation before API call | Reject with syntax error details | <5ms |
| Budget value sanity | Compare proposed budget vs. current budget | Flag if change >200% — require double confirmation | <1ms |
| Account scope verification | Verify customer_id matches active session | Reject if mismatched | <1ms |
| PII in ad copy input | Regex for SSN, phone, email patterns | Redact before processing | <10ms |
| Prompt injection | Pattern matching + structural analysis | Reject input, log attempt | <50ms |

### 1.2 Write operation pre-flight checks

Every mutation request must pass ALL pre-flight checks before entering the CEP flow:

```
Pre-flight checklist (automated, <50ms total):
├── ✓ customer_id is valid and matches session scope
├── ✓ campaign_id / ad_group_id exists in account (HEAD check)
├── ✓ proposed change is within safety bounds:
│     ├── Budget change: ≤200% of current daily budget
│     ├── Bid change: ≤300% of current bid
│     └── Status change: only ENABLED ↔ PAUSED (never REMOVED)
├── ✓ User has explicitly stated intent for this specific change
└── ✓ No identical mutation executed in last 60 seconds (duplicate guard)
```

### 1.3 Rate limiting

| Scope | Limit | Window | Action |
|---|---|---|---|
| Write operations per account | 10 | Per hour | Hard block — "Mutation limit reached" |
| Read operations per account | 100 | Per hour | Soft throttle — queue requests |
| Total API calls per session | 200 | Per session | Terminate session with summary |
| Budget-changing operations | 3 | Per day per account | Hard block — require manual override |

---

## Layer 2: Output guardrails

### 2.1 Quality checks

| Check | Method | Threshold | Action on violation |
|---|---|---|---|
| Ad copy character limits | Platform spec validation | RSA headline ≤30 chars, description ≤90 chars | Block output, show violation |
| Ad copy prohibited content | Keyword list + LLM classifier | Zero tolerance | Block and explain which policy was violated |
| Trademark detection | Brand name database lookup | Flag known trademarks | Warning: "Contains trademark — verify authorization" |
| Financial claim detection | Regex + LLM classifier | Zero tolerance for guarantees | Block: "Cannot guarantee financial outcomes in ad copy" |
| Medical claim detection | Regex + LLM classifier | Zero tolerance without disclaimers | Block or append required disclaimers |
| Mutation confirmation accuracy | Compare described change vs. API params | 100% match required | Re-generate confirmation if mismatch |

### 2.2 CEP Protocol enforcement (Confirm-Execute-Postcheck)

This is the primary safety mechanism for all write operations:

```
CONFIRM phase:
  Agent outputs plain-language description of EXACT change:
  "I will change the daily budget for Campaign 'Brand - Phoenix'
   (ID: 12345678) from $150.00 to $175.00 in account 9876543210."

  Requirements:
  - Must name the specific resource being changed
  - Must show current value AND proposed value
  - Must include account ID
  - Must NOT execute any API call during this phase

APPROVE phase:
  Human must respond with explicit approval.
  Acceptable: "yes", "approve", "do it", "confirmed"
  Anything else = abort.

EXECUTE phase:
  - Execute single API mutation
  - Label the change: "miniagent-YYYYMMDD-HHMMSS" for rollback tracking
  - Log full request and response

POSTCHECK phase:
  - Re-read the resource via API
  - Confirm the change took effect
  - Output: "Confirmed: Daily budget for Campaign 12345678
    is now $175.00 (was $150.00)"
```

### 2.3 Fallback responses

| Violation | User-facing message | Internal action |
|---|---|---|
| Budget change >200% | "That budget change is unusually large (>2× current). Please confirm the exact amount you want." | Log, require re-confirmation with specific number |
| Hallucinated campaign ID | "I couldn't find that campaign in your account. Let me list your active campaigns." | Auto-trigger list_campaigns read |
| CEP bypassed (should never happen) | N/A — system halts | Emergency alert + full session log |
| Ad copy policy violation | "This ad copy contains [specific issue]. Here's a compliant alternative: ..." | Generate alternative, log violation type |
| ARGUS fraud detection | "This profile shows indicators of inauthentic activity. Review the detailed report." | Generate full ARGUS report with evidence |

---

## Layer 3: Tool and action guardrails

### 3.1 Tool classification

| Tool category | Examples | Requires CEP | Max calls/session |
|---|---|---|---|
| **Read** (safe) | list_accounts, get_campaign_performance, execute_gaql (SELECT only) | No | 100 |
| **Analyze** (safe) | audit_account, audit_quality_score, audit_wasted_spend | No | 20 |
| **Write** (dangerous) | pause_campaign, update_budget, add_negative_keywords | **Yes — full CEP** | 10 |
| **Create** (dangerous) | create_campaign, create_ad_group, create_ad | **Yes — full CEP** | 5 |
| **Delete** (prohibited) | remove_campaign, remove_ad_group | **Blocked entirely** | 0 |

### 3.2 Delete prohibition

The system **never** executes REMOVE operations. Resources can only be PAUSED (reversible). This is a hard guardrail — the delete tools are not exposed to the agent.

### 3.3 Audit logging

Every tool invocation is logged:
```json
{
  "timestamp": "2026-03-12T14:32:01Z",
  "session_id": "sess_abc123",
  "user_id": "user_456",
  "tool_name": "update_budget",
  "tool_category": "write",
  "customer_id": "9876543210",
  "resource_id": "campaign/12345678",
  "params": {"budget_micros": 175000000},
  "previous_value": {"budget_micros": 150000000},
  "cep_confirmed": true,
  "cep_confirmed_at": "2026-03-12T14:31:55Z",
  "result": "success",
  "postcheck_verified": true,
  "label": "miniagent-20260312-143201"
}
```

---

## ARGUS trust and safety layer

For platforms and profiles validated through the ARGUS system:

| Check | Method | Action |
|---|---|---|
| Fake account detection | Behavioral pattern analysis + network graph | Flag with confidence score |
| Deepfake identification | Visual artifact detection + metadata analysis | Flag with evidence |
| Engagement authenticity | Statistical anomaly detection on engagement patterns | Score 0–100 |
| Bot network detection | Temporal clustering + IP analysis | Flag coordinated networks |
| Review manipulation | Sentiment/timing pattern analysis | Flag with evidence |

ARGUS reports are generated with full evidence chains — never a black-box score. Every flag includes the specific signals that triggered it so the human reviewer can make an informed decision.

---

## Latency budget

Total guardrail overhead target: <100ms added to P95 response time

| Guardrail | Method | Target latency |
|---|---|---|
| Input format validation | Synchronous regex | <5ms |
| Pre-flight checks (writes) | Synchronous + 1 API HEAD call | <50ms |
| Ad copy policy check | LLM classifier | <200ms (async, parallel with generation) |
| CEP confirmation match | String matching | <1ms |
| Postcheck API call | API read | <500ms (separate from response time) |
| **Total overhead** | — | **<55ms** (excluding async checks) |

---

## Acceptance criteria

- [x] CEP compliance: 100% of write operations require human approval (0% bypass in 75-case eval)
- [x] Budget safety: 100% of >200% budget changes trigger double confirmation
- [x] Delete prohibition: 0 delete operations possible (tools not exposed)
- [x] Customer ID validation: 100% of invalid IDs rejected before API call
- [x] Ad copy policy: ≥95% of policy violations detected (tested against 50 known-bad samples)
- [x] Audit logging: 100% of tool invocations logged with full context
- [x] Duplicate guard: 100% of identical mutations within 60s blocked

---

## Monitoring in production

| Metric | Alert threshold | Channel |
|---|---|---|
| CEP bypass attempts | Any occurrence | Immediate alert + session freeze |
| Write operations per account/day | >10 | Alert to account owner |
| Budget change >$1,000 in single operation | Any occurrence | Alert + require manager approval |
| API error rate (per platform) | >10% over 5 minutes | Platform health alert |
| ARGUS false positive rate | >15% on weekly review | Tune detection thresholds |

---

*Production example — contributed by John Williams ([itallstartedwithaidea](https://github.com/itallstartedwithaidea)) — BHIL AI-First Development Toolkit*
