#!/usr/bin/env bash
# init.sh — Initialize the BHIL AI-First Toolkit for a specific project
# Usage: ./tools/scripts/init.sh "Project Name" "TypeScript" "Description of what you're building"
# BHIL AI-First Development Toolkit — barryhurd.com

set -euo pipefail

PROJECT_NAME="${1:-My AI Project}"
TECH_STACK="${2:-TypeScript}"
PROJECT_DESCRIPTION="${3:-An AI-native application}"
DATE=$(date +%Y-%m-%d)

echo "🚀 Initializing BHIL AI-First Toolkit for: ${PROJECT_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── 1. Update CLAUDE.md with project specifics ─────────────────────────────
echo "📝 Updating CLAUDE.md..."
sed -i.bak \
  -e "s|This is the BHIL AI-First Development Toolkit.*|This is the project for: ${PROJECT_NAME}|" \
  -e "s|Current mode: Methodology toolkit (meta-project)|Current mode: Active project|" \
  -e "s|Stack: Markdown, shell scripts, YAML, GitHub Actions|Stack: ${TECH_STACK}|" \
  CLAUDE.md
rm -f CLAUDE.md.bak

# ─── 2. Update AGENTS.md with project description ───────────────────────────
echo "📝 Updating AGENTS.md..."
sed -i.bak \
  -e "s|BHIL AI-First Development Toolkit is a \*\*methodology repository\*\*.*|${PROJECT_NAME} is ${PROJECT_DESCRIPTION}.|" \
  -e "s|This is a meta-project.*||" \
  AGENTS.md
rm -f AGENTS.md.bak

# ─── 3. Create project directory structure ──────────────────────────────────
echo "📁 Creating project structure..."
mkdir -p project/.sdlc/{context,specs,knowledge}
mkdir -p project/sprints/S-01/progress
mkdir -p project/prompts/v1
mkdir -p docs/adr
mkdir -p evals/{golden,results}
mkdir -p src

# ─── 4. Initialize architecture context file ────────────────────────────────
echo "📄 Creating architecture context..."
cat > project/.sdlc/context/architecture.md << EOF
---
project: ${PROJECT_NAME}
stack: ${TECH_STACK}
last_updated: ${DATE}
---

# ${PROJECT_NAME} — Architecture Context

> Load this file at the start of every implementation session.
> Updated at the end of each sprint retrospective.

## Project description
${PROJECT_DESCRIPTION}

## Tech stack
- **Primary language:** ${TECH_STACK}
- **LLM provider:** [TBD — document in ADR-001]
- **Vector store:** [TBD — document in ADR]
- **Deployment:** [TBD]

## ADR registry

| ADR | Type | Decision | Status | Date |
|---|---|---|---|---|
| (none yet) | — | — | — | — |

## Key architectural principles
(Add as ADRs are accepted)

## Known constraints
- [Add non-negotiable constraints here]
EOF

# ─── 5. Initialize prompt registry ──────────────────────────────────────────
echo "📄 Creating prompt registry..."
cat > project/prompts/PROMPT-REGISTRY.md << EOF
---
last_updated: ${DATE}
---

# Prompt Registry — ${PROJECT_NAME}

| Prompt ID | Version | Capability | Deployed | Eval Score | ADR | Last Updated |
|---|---|---|---|---|---|---|
| (none yet) | — | — | — | — | — | — |

## Versioning policy
- **Major** (1.0 → 2.0): Output format change or fundamental approach change
- **Minor** (1.0 → 1.1): New capability or backward-compatible improvement
- **Patch** (1.0 → 1.0.1): Typo fix or minor wording change with no behavioral effect

## Active model: [TBD — document in ADR-001-model-selection]
EOF

# ─── 6. Create initial sprint S-01 structure ────────────────────────────────
echo "📅 Initializing Sprint S-01..."
cat > project/sprints/S-01/SPRINT-CONTEXT.md << EOF
---
sprint: S-01
started: ${DATE}
active: true
---

# Sprint S-01 Context

## Sprint goal
[Set when sprint planning is complete — use: new-sprint skill]

## Active features
[Populated during sprint planning]

## Governing ADRs
[Populated as ADRs are accepted]
EOF

cat > project/sprints/S-01/progress/sprint-log.md << EOF
---
sprint: S-01
started: ${DATE}
---

# S-01 Knowledge Log

## Decisions made
[Populated throughout the sprint]

## Agent clarification questions
[Every question an agent asks is a spec gap — log them here]

## Spec gaps discovered
[Populated as gaps are found during implementation]
EOF

# ─── 7. Install git hooks ────────────────────────────────────────────────────
echo "🪝 Installing git hooks..."
mkdir -p .git/hooks

cat > .git/hooks/pre-commit << 'HOOK'
#!/usr/bin/env bash
# Pre-commit: validate artifact frontmatter and traceability

echo "🔍 Validating artifact frontmatter..."

FAILED=0
for file in $(git diff --cached --name-only | grep -E '\.md$'); do
  if [[ "$file" =~ project/.sdlc/specs/ ]] || [[ "$file" =~ docs/adr/ ]]; then
    # Check for required frontmatter fields
    if ! grep -q "^id:" "$file" 2>/dev/null; then
      echo "❌ Missing 'id:' in frontmatter: $file"
      FAILED=1
    fi
    if ! grep -q "^status:" "$file" 2>/dev/null; then
      echo "❌ Missing 'status:' in frontmatter: $file"
      FAILED=1
    fi
    if ! grep -q "^date:" "$file" 2>/dev/null; then
      echo "❌ Missing 'date:' in frontmatter: $file"
      FAILED=1
    fi
    # Check for unfilled placeholders
    if grep -qE '\[Your name\]|\[YYYY-MM-DD\]|\[NNN\]' "$file" 2>/dev/null; then
      echo "⚠️  Unfilled placeholders in: $file (allowed if status: draft)"
    fi
  fi
done

if [ "$FAILED" -eq 1 ]; then
  echo ""
  echo "❌ Pre-commit failed: Fix frontmatter issues before committing"
  exit 1
fi

echo "✅ Artifact validation passed"
exit 0
HOOK

chmod +x .git/hooks/pre-commit

# ─── 8. Create .gitignore entries ────────────────────────────────────────────
echo "📄 Updating .gitignore..."
cat >> .gitignore << 'EOF'

# BHIL AI-First Toolkit
.claude/settings.local.json
project/.sdlc/knowledge/progress-*.md
evals/results/*.json
*.env
*.env.local
.env.*
EOF

# ─── 9. Summary ──────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ BHIL AI-First Toolkit initialized for: ${PROJECT_NAME}"
echo ""
echo "📁 Created:"
echo "   project/.sdlc/context/architecture.md"
echo "   project/prompts/PROMPT-REGISTRY.md"
echo "   project/sprints/S-01/"
echo "   docs/adr/  (empty — add ADRs with new-adr skill)"
echo "   evals/  (empty — add eval suites per feature)"
echo ""
echo "🔮 Next steps:"
echo "   1. Open Claude Code: claude"
echo "   2. Use the new-sprint skill to plan Sprint S-01"
echo "   3. Use the new-feature skill to create your first PRD"
echo "   4. Use the new-adr skill to document your first architectural decision"
echo ""
echo "📚 Read first: guides/00-getting-started.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
