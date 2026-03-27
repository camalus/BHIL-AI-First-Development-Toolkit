---
# These rules load for ALL sessions in this toolkit repository.
# They enforce the core methodology constraints.
---

# Methodology Enforcement Rules

## Artifact creation rules

When creating any file in `project/.sdlc/specs/` or `docs/adr/`:

1. ALWAYS include YAML frontmatter with at minimum: `id`, `status`, `date`
2. ALWAYS use the correct ID format: PRD-NNN, SPEC-NNN, ADR-NNN, TASK-NNN (zero-padded to 3 digits)
3. ALWAYS set initial `status: draft` — never create artifacts as `approved` or `accepted`
4. ALWAYS include `parent:` reference for SPEC files (must reference an existing PRD-NNN)
5. ALWAYS include `spec:` reference for TASK files (must reference an existing SPEC-NNN)
6. NEVER create a TASK file before its parent SPEC is `status: approved`

## ADR immutability rules

For any file matching `docs/adr/ADR-*.md`:

1. NEVER modify the frontmatter `status` field from `accepted` to any other value
2. NEVER modify the `## Decision outcome` section of an accepted ADR
3. NEVER delete content from an accepted ADR — add superseding notes only
4. When an ADR must change: create a new ADR with `superseded_by: ADR-NEW` in the old one

## Acceptance criteria rules

For all `## Acceptance criteria` sections:

1. NEVER write criteria containing "works correctly," "is fast," "is good," "is appropriate"
2. ALWAYS quantify performance criteria: not "fast" but "< 200ms P95"
3. For AI/LLM components: ALWAYS include at least one probabilistic criterion (≥X.XX on N runs)
4. For AI/LLM components: ALWAYS include at least one safety criterion (toxicity, injection resistance)
5. Every criterion must begin with a checkbox: `- [ ]`

## Template usage rules

When copying from `templates/`:

1. ALWAYS remove all HTML comment blocks (`<!-- ... -->`) from the final artifact
2. ALWAYS replace ALL placeholder text (brackets `[...]`) before setting status past `draft`
3. NEVER submit a template with placeholder text as `status: approved`
4. For ADR templates: ALWAYS complete the "Rejected candidates" section with real alternatives

## Prompt management rules

For any session modifying files in `project/prompts/`:

1. NEVER modify an existing prompt version directory (e.g., `v1/`)
2. ALWAYS create a new version directory (`v2/`) for any prompt change
3. ALWAYS update `project/prompts/PROMPT-REGISTRY.md` after any prompt change
4. ALWAYS note the version bump type (major/minor/patch) in the registry entry
