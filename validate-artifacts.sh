#!/usr/bin/env bash
# validate-artifacts.sh — Validate YAML frontmatter and traceability across all artifacts
# Usage: ./tools/scripts/validate-artifacts.sh [--strict]
# BHIL AI-First Development Toolkit — barryhurd.com

set -euo pipefail

STRICT="${1:-}"
ERRORS=0
WARNINGS=0

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

error() { echo -e "${RED}❌ ERROR:${NC} $1"; ((ERRORS++)) || true; }
warn()  { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; ((WARNINGS++)) || true; }
info()  { echo -e "${BLUE}ℹ️  INFO:${NC} $1"; }
ok()    { echo -e "${GREEN}✅${NC} $1"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "BHIL AI-First Toolkit — Artifact Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Helper: extract frontmatter field ────────────────────────────────────────
get_field() {
  local file="$1"
  local field="$2"
  grep "^${field}:" "$file" 2>/dev/null | head -1 | sed "s/^${field}: *//"
}

# ─── 1. Validate PRD files ────────────────────────────────────────────────────
echo ""
echo "📄 Validating PRD files..."
PRD_COUNT=0
for file in project/.sdlc/specs/PRD-*.md 2>/dev/null; do
  [ -f "$file" ] || continue
  ((PRD_COUNT++)) || true
  
  id=$(get_field "$file" "id")
  status=$(get_field "$file" "status")
  date=$(get_field "$file" "date")
  
  [ -z "$id" ]     && error "Missing 'id:' in $file"
  [ -z "$status" ] && error "Missing 'status:' in $file"
  [ -z "$date" ]   && error "Missing 'date:' in $file"
  
  # Check for unfilled placeholders in non-draft files
  if [ "$status" != "draft" ]; then
    if grep -qE '\[.*\]' "$file" 2>/dev/null; then
      if [ "$status" = "approved" ] || [ "$status" = "complete" ]; then
        error "Unfilled placeholders in approved/complete file: $file"
      else
        warn "Unfilled placeholders in: $file (status: $status)"
      fi
    fi
  fi
  
  # Check EARS format in user stories section
  if grep -q "## User stories" "$file" 2>/dev/null; then
    if ! grep -qE "(WHEN|WHILE|IF).*SHALL" "$file" 2>/dev/null; then
      warn "No EARS-format stories found in: $file"
    fi
  fi
done
[ "$PRD_COUNT" -eq 0 ] && info "No PRD files found in project/.sdlc/specs/"

# ─── 2. Validate SPEC files ───────────────────────────────────────────────────
echo ""
echo "📄 Validating SPEC files..."
SPEC_COUNT=0
for file in project/.sdlc/specs/SPEC-*.md 2>/dev/null; do
  [ -f "$file" ] || continue
  ((SPEC_COUNT++)) || true
  
  id=$(get_field "$file" "id")
  status=$(get_field "$file" "status")
  parent=$(get_field "$file" "parent")
  
  [ -z "$id" ]     && error "Missing 'id:' in $file"
  [ -z "$status" ] && error "Missing 'status:' in $file"
  [ -z "$parent" ] && error "Missing 'parent:' (PRD reference) in $file"
  
  # Verify parent PRD exists
  if [ -n "$parent" ]; then
    parent_file=$(ls project/.sdlc/specs/${parent}*.md 2>/dev/null | head -1)
    if [ -z "$parent_file" ]; then
      error "Parent PRD not found: ${parent} (referenced in $file)"
    fi
  fi
  
  # Check acceptance criteria section exists
  if ! grep -q "## Acceptance criteria" "$file" 2>/dev/null; then
    error "Missing '## Acceptance criteria' section in: $file"
  fi
  
  # Warn if no probabilistic criteria for AI features
  if grep -qi "llm\|model\|prompt\|agent\|embedding" "$file" 2>/dev/null; then
    if ! grep -qE "≥[0-9]\.[0-9]+.*[0-9]+ runs|[0-9]+ runs.*≥[0-9]\.[0-9]+" "$file" 2>/dev/null; then
      warn "AI-native SPEC with no probabilistic acceptance criteria: $file"
    fi
  fi
done
[ "$SPEC_COUNT" -eq 0 ] && info "No SPEC files found in project/.sdlc/specs/"

# ─── 3. Validate ADR files ────────────────────────────────────────────────────
echo ""
echo "📄 Validating ADR files..."
ADR_COUNT=0
for file in docs/adr/ADR-*.md 2>/dev/null; do
  [ -f "$file" ] || continue
  ((ADR_COUNT++)) || true
  
  id=$(get_field "$file" "id")
  status=$(get_field "$file" "status")
  date=$(get_field "$file" "date")
  type=$(get_field "$file" "type")
  
  [ -z "$id" ]     && error "Missing 'id:' in $file"
  [ -z "$status" ] && error "Missing 'status:' in $file"
  [ -z "$date" ]   && error "Missing 'date:' in $file"
  
  # Validate status values
  case "$status" in
    proposed|accepted|deprecated|superseded) ;;
    *) error "Invalid status '$status' in: $file (must be: proposed|accepted|deprecated|superseded)" ;;
  esac
  
  # Check for "Rejected candidates" section in accepted ADRs
  if [ "$status" = "accepted" ]; then
    if ! grep -q "## Rejected\|## Alternatives" "$file" 2>/dev/null; then
      warn "Accepted ADR missing alternatives/rejected section: $file"
    fi
  fi
  
  # Check model-selection ADRs have review_trigger
  if [ "$type" = "model-selection" ]; then
    review=$(get_field "$file" "review_trigger")
    [ -z "$review" ] && error "Model selection ADR missing 'review_trigger:' in: $file"
  fi
done
[ "$ADR_COUNT" -eq 0 ] && info "No ADR files found in docs/adr/"

# ─── 4. Validate TASK files ───────────────────────────────────────────────────
echo ""
echo "📄 Validating TASK files..."
TASK_COUNT=0
for file in project/.sdlc/specs/TASK-*.md 2>/dev/null; do
  [ -f "$file" ] || continue
  ((TASK_COUNT++)) || true
  
  id=$(get_field "$file" "id")
  spec=$(get_field "$file" "spec")
  status=$(get_field "$file" "status")
  
  [ -z "$id" ]     && error "Missing 'id:' in $file"
  [ -z "$spec" ]   && error "Missing 'spec:' (SPEC reference) in $file"
  [ -z "$status" ] && error "Missing 'status:' in $file"
  
  # Verify referenced SPEC exists
  if [ -n "$spec" ]; then
    spec_file=$(ls project/.sdlc/specs/${spec}*.md 2>/dev/null | head -1)
    [ -z "$spec_file" ] && error "Referenced SPEC not found: ${spec} (in $file)"
  fi
  
  # Check for definition of done section
  if ! grep -q "## Definition of done" "$file" 2>/dev/null; then
    warn "TASK missing '## Definition of done' section: $file"
  fi
done
[ "$TASK_COUNT" -eq 0 ] && info "No TASK files found in project/.sdlc/specs/"

# ─── 5. Summary ──────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Validation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Files checked: PRDs: ${PRD_COUNT}  SPECs: ${SPEC_COUNT}  ADRs: ${ADR_COUNT}  TASKs: ${TASK_COUNT}"
echo "  Errors:   ${ERRORS}"
echo "  Warnings: ${WARNINGS}"
echo ""

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}❌ FAILED — ${ERRORS} error(s) must be fixed${NC}"
  exit 1
elif [ "$WARNINGS" -gt 0 ] && [ "$STRICT" = "--strict" ]; then
  echo -e "${YELLOW}⚠️  FAILED (strict mode) — ${WARNINGS} warning(s) must be resolved${NC}"
  exit 1
else
  echo -e "${GREEN}✅ PASSED — All artifacts valid${NC}"
  exit 0
fi
