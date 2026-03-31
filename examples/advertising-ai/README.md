# Advertising AI — Production Examples

**Contributed by:** [John Williams](https://github.com/itallstartedwithaidea) — Lead, Paid Media at [Seer Interactive](https://www.seerinteractive.com)

These are completed BHIL templates filled with real data from a production advertising AI platform that manages campaigns across 14 ad platforms using MCP servers, Claude-powered agents, and the Confirm-Execute-Postcheck (CEP) safety protocol.

## Source repositories

| Repo | What it is |
|---|---|
| [MiniAgent](https://github.com/itallstartedwithaidea/MiniAgent) | Trainable advertising AI + 14 platform MCP servers |
| [google-ads-api-agent](https://github.com/itallstartedwithaidea/google-ads-api-agent) | Enterprise Google Ads management agent on Claude |
| [creative-asset-validator](https://github.com/itallstartedwithaidea/creative-asset-validator) | Creative validation across 50+ platform specs |
| [ARGUS](https://github.com/itallstartedwithaidea/argus) | Trust & safety: fake accounts, deepfakes, disinformation |
| [ContextOS](https://github.com/itallstartedwithaidea/ContextOS) | MCP context intelligence platform |
| [googleadsagent-site](https://github.com/itallstartedwithaidea/googleadsagent-site) | 2.3M+ page programmatic SEO site on Cloudflare Pages |

## Artifacts in this directory

```
examples/advertising-ai/
├── README.md                              ← You are here
│
├── ADR-agent-orchestration-14-platform-mcp.md
│   Completed ADR-AGENT-ORCHESTRATION template showing how 14 ad platform
│   MCP servers are coordinated under an orchestrator-worker pattern.
│   Includes tool counts, CEP safety protocol, and rejected patterns.
│
├── ADR-model-selection-google-ads-agent.md
│   Completed ADR-MODEL-SELECTION template with real eval results
│   comparing Claude, GPT, and Gemini for advertising operations.
│   Includes CEP compliance testing (the critical differentiator).
│
├── EVAL-SUITE-creative-validation.yaml
│   Completed EVAL-SUITE-TEMPLATE with test cases for validating
│   ad creative against Google Ads, Meta, and TikTok specifications.
│   Includes adversarial/safety tests for prompt injection and PII.
│
├── GUARDRAILS-advertising-ai.md
│   Completed GUARDRAILS-SPEC-TEMPLATE for an AI system with write
│   access to real advertising accounts. Covers CEP enforcement,
│   budget safety bounds, delete prohibition, and ARGUS trust scoring.
│
└── sprint-content-quality-overhaul/
    └── SPRINT-PLAN.md
        Completed SPRINT-PLAN-TEMPLATE documenting a real sprint
        responding to Google's March 2026 core update. Shows the
        full artifact chain from audit → fix → deploy → document.
```

## Key pattern: Confirm-Execute-Postcheck (CEP)

The most important guardrail in this system. When an AI agent has write access to accounts controlling real money, every mutation must follow:

1. **Confirm** — Agent describes the exact change in plain language
2. **Approve** — Human explicitly approves
3. **Execute** — API mutation runs with a labeled change for rollback
4. **Postcheck** — Agent re-reads the resource to verify

This pattern appears in the orchestration ADR, model selection ADR (CEP compliance is the primary eval criterion), and guardrails spec.
