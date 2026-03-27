#!/usr/bin/env bash
# new-adr.sh — Create a sequentially numbered ADR using the correct template
# Usage: ./tools/scripts/new-adr.sh "Decision title" [type]
# Types: standard | model-selection | prompt-strategy | agent-orchestration
# BHIL AI-First Development Toolkit — barryhurd.com

set -euo pipefail

TITLE="${1:-New Architecture Decision}"
TYPE="${2:-standard}"
DATE=$(date +%Y-%m-%d)

# ─── Validate type ────────────────────────────────────────────────────────────
case "$TYPE" in
  standard|model-selection|prompt-strategy|agent-orchestration) ;;
  *)
    echo "❌ Invalid ADR type: ${TYPE}"
    echo "   Valid types: standard | model-selection | prompt-strategy | agent-orchestration"
    exit 1
    ;;
esac

# ─── Determine next ADR number ────────────────────────────────────────────────
mkdir -p docs/adr

LAST_NUM=$(ls docs/adr/ADR-*.md 2>/dev/null | \
  grep -oE 'ADR-[0-9]+' | \
  sort -t- -k2 -n | \
  tail -1 | \
  grep -oE '[0-9]+' || echo "0")

NEXT_NUM=$(printf '%03d' $((10#$LAST_NUM + 1)))
ADR_ID="ADR-${NEXT_NUM}"

# ─── Create slug from title ───────────────────────────────────────────────────
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | \
  sed 's/[^a-z0-9 ]//g' | \
  tr ' ' '-' | \
  sed 's/--*/-/g' | \
  cut -c1-50)

FILENAME="docs/adr/${ADR_ID}-${SLUG}.md"

# ─── Select template ──────────────────────────────────────────────────────────
case "$TYPE" in
  standard)
    TEMPLATE="templates/adr/ADR-TEMPLATE.md"
    ;;
  model-selection)
    TEMPLATE="templates/adr/ADR-MODEL-SELECTION.md"
    ;;
  prompt-strategy)
    TEMPLATE="templates/adr/ADR-PROMPT-STRATEGY.md"
    ;;
  agent-orchestration)
    TEMPLATE="templates/adr/ADR-AGENT-ORCHESTRATION.md"
    ;;
esac

if [ ! -f "$TEMPLATE" ]; then
  echo "❌ Template not found: $TEMPLATE"
  echo "   Run from the repository root directory."
  exit 1
fi

# ─── Copy template and replace placeholders ───────────────────────────────────
cp "$TEMPLATE" "$FILENAME"

# Update frontmatter
sed -i.bak \
  -e "s|^id: ADR-NNN|id: ${ADR_ID}|" \
  -e "s|^date: YYYY-MM-DD|date: ${DATE}|" \
  -e "s|^status: proposed|status: proposed|" \
  -e "s|\[Decision title.*\]|${TITLE}|g" \
  "$FILENAME"
rm -f "${FILENAME}.bak"

# ─── Register in architecture context ─────────────────────────────────────────
if [ -f "project/.sdlc/context/architecture.md" ]; then
  # Find the ADR registry table and append the new entry
  sed -i.bak "s/| (none yet) | — | — | — | — |/| ${ADR_ID} | ${TYPE} | ${TITLE} | proposed | ${DATE} |\\n| (none yet) | — | — | — | — |/" \
    project/.sdlc/context/architecture.md 2>/dev/null || true
  # Clean up the placeholder if we successfully added a real entry
  if grep -q "${ADR_ID}" project/.sdlc/context/architecture.md; then
    sed -i.bak '/| (none yet) | — | — | — | — |/d' project/.sdlc/context/architecture.md
  fi
  rm -f project/.sdlc/context/architecture.md.bak
fi

# ─── Output ───────────────────────────────────────────────────────────────────
echo ""
echo "✅ ADR created: ${FILENAME}"
echo ""
echo "📋 ADR details:"
echo "   ID:    ${ADR_ID}"
echo "   Type:  ${TYPE}"
echo "   Title: ${TITLE}"
echo "   Date:  ${DATE}"
echo ""
echo "📝 Complete these sections before the ADR can be accepted:"

case "$TYPE" in
  standard)
    echo "   • Context and problem statement"
    echo "   • Decision drivers (quantified)"
    echo "   • Considered options (minimum 2 alternatives)"
    echo "   • Decision outcome with rationale"
    echo "   • Consequences (positive and negative)"
    echo "   • Acceptance criteria"
    ;;
  model-selection)
    echo "   • Decision drivers (quantified: latency, cost, quality targets)"
    echo "   • Evaluation results (run actual benchmarks on your eval dataset)"
    echo "   • Configuration (exact model ID, temperature, max_tokens)"
    echo "   • Cost projection (MVP, 10x, 100x volume)"
    echo "   • Review trigger date"
    ;;
  prompt-strategy)
    echo "   • Strategies evaluated (with actual scores)"
    echo "   • Prompt specification (system prompt + user template)"
    echo "   • Evaluation dataset (minimum 50 cases for production)"
    echo "   • Prompt version registered in project/prompts/PROMPT-REGISTRY.md"
    ;;
  agent-orchestration)
    echo "   • Architecture specification (agent diagram)"
    echo "   • Error handling specification (all failure scenarios)"
    echo "   • Cost and latency model (per-request estimates)"
    echo "   • Observability requirements (telemetry schema)"
    ;;
esac

echo ""
echo "📌 To accept this ADR after completing all sections:"
echo "   Update 'status: proposed' → 'status: accepted' in ${FILENAME}"
echo ""
echo "🔗 Add traceability link to the related SPEC:"
echo "   Add '${ADR_ID}' to the 'adrs: []' list in the relevant SPEC frontmatter"
