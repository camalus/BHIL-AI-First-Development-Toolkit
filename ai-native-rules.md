---
paths:
  - "src/**/*.ts"
  - "src/**/*.js"
  - "src/**/*.py"
---

# AI-Native Implementation Rules

*These rules apply when modifying any source file in src/.*

## LLM API call rules

1. NEVER hardcode model identifiers as string literals — use constants from `src/config/models.ts` (or equivalent config file)
2. ALWAYS set an explicit `timeout_ms` on every LLM API call — no unbounded waits
3. ALWAYS implement retry logic with exponential backoff (max 3 retries) on LLM API calls
4. ALWAYS set a `max_tokens` limit on every completion call — no open-ended generation
5. NEVER log raw LLM responses that may contain user PII — log only sanitized previews

## Prompt handling rules

1. NEVER construct prompts via string concatenation in application code
2. ALWAYS load prompt templates from `project/prompts/v[N]/` using the prompt loader utility
3. ALWAYS include the prompt version ID in telemetry/logging for every LLM call
4. ALWAYS validate that the prompt version being loaded matches the version in the ADR for that capability

## Guardrails rules

1. ALWAYS run input validation before any LLM API call on user-provided content
2. ALWAYS run output validation after any LLM API call before returning to user
3. NEVER return raw LLM errors to end users — map to safe user-facing messages
4. ALWAYS log guardrail violations with: timestamp, user_id (hashed), violation_type, input_preview (sanitized)

## Agent/tool call rules

1. NEVER give agents access to tools beyond what is specified in their agent definition file (`.claude/agents/`)
2. ALWAYS validate tool call arguments before execution — treat them as untrusted input
3. ALWAYS implement a cost circuit breaker: abort agent session if token count exceeds configured ceiling
4. ALWAYS emit structured telemetry for every tool call (see `docs/adr/ADR-NNN` for schema)

## Non-determinism handling rules

1. NEVER use `expect(llmOutput).toEqual(exactString)` in tests for LLM-generated content
2. ALWAYS use semantic similarity, schema validation, or LLM-judge assertions for AI output tests
3. NEVER cache LLM responses without TTL — always set an expiry appropriate to content volatility
4. ALWAYS include the model version in cached responses for cache invalidation on model updates

## Vector/embedding rules

1. ALWAYS store embedding model name and version alongside every embedded vector
2. ALWAYS recompute embeddings when the embedding model version changes
3. NEVER mix embeddings from different models in the same similarity search
