---
last_updated: YYYY-MM-DD
---

# Prompt Registry

> Every prompt used in production must be registered here with its version and eval score.
> Never modify a deployed prompt in-place. Create a new version.

## Active prompts

| Prompt ID | Version | Capability | Deployed | Eval Score | ADR | Last Updated |
|---|---|---|---|---|---|---|
| (none yet — add entries as prompts are created) | | | | | | |

---

## Versioning policy

| Change type | Version bump | Requires |
|---|---|---|
| Output format change | **Major** (1.0 → 2.0) | Full eval suite re-run; update all downstream consumers |
| New examples, backward-compatible improvement | **Minor** (1.0 → 1.1) | Eval suite re-run; update this registry |
| Typo fix, no behavioral change | **Patch** (1.0 → 1.0.1) | 10-case spot check; update this registry |

**Version freeze policy:** Once a prompt version is deployed to production, it is immutable. All changes create a new version directory in `project/prompts/`.

---

## Adding a new prompt version

1. Create directory: `project/prompts/v[N]/`
2. Add files: `system-prompt.md`, `user-template.md`, `few-shot-examples.json` (if used)
3. Run eval suite: `npx promptfoo eval --config evals/[feature].yaml`
4. Record eval score here
5. Update the Prompt Strategy ADR with the new version
6. Set `deployed: Yes` only after the ADR is updated and accepted

---

## Version history

### PV-001 — [Capability name]
- **v1.0.0** — `project/prompts/v1/` — created YYYY-MM-DD — eval: [score] — [status]

---

*BHIL AI-First Development Toolkit — [barryhurd.com](https://barryhurd.com)*
