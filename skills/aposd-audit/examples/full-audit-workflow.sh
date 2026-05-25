#!/usr/bin/env bash
# Full audit workflow template — run, persist, trend
# Copy this and adapt the TARGET to your codebase.
set -euo pipefail

TARGET="${1:-src/services/order-service.js}"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Step 1: Run the audit ==="
# Prints to stdout; see below for persistence
echo "Running audit on: $TARGET"
echo ""
echo "| # | Dimension | Score | Key Finding | Evidence |"
echo "|---|-----------|-------|-------------|----------|"
echo "| 1 | Pass-Through Proliferation | 2 | 4 pass-through methods found | src/services/order-service.js:42-48 |"
echo "| 2 | Information Duplication | 1 | 'expired_at' threshold in 3 places | src/services/order-service.js:87, src/lib/expiry.js:12, src/config/orders.js:5 |"
echo "| 3 | Interface Documentation | 3 | 70% of public methods documented | 7/10 have JSDoc blocks |"
echo "| 4 | Naming Quality | 3 | 2 vague names ('data', 'helper') | src/services/order-service.js:15, src/services/order-service.js:103 |"
echo "| 5 | Exception Discipline | 4 | 0 custom exceptions, no rethrows | — |"
echo "| **Total** | | **13/20** | **Acceptable** | |"
echo ""

echo "=== Step 2: Compute audit slug ==="
SLUG=$(APOSD_STORAGE_SUBDIR=audit node "$SKILL_DIR/scripts/critique-storage.mjs" slug "$TARGET")
echo "Slug: $SLUG"

echo ""
echo "=== Step 3: Persist snapshot ==="
BODY_FILE=$(mktemp)
cat > "$BODY_FILE" <<'REPORT'
# Design Health Score

| # | Dimension | Score | Key Finding |
|---|-----------|-------|-------------|
| 1 | Pass-Through Proliferation | 2 | 4 pass-through methods |
| 2 | Information Duplication | 1 | 3 instances of duplicated knowledge |
| 3 | Interface Documentation | 3 | 70% documented |
| 4 | Naming Quality | 3 | 2 vague names |
| 5 | Exception Discipline | 4 | 0 issues |
| **Total** | | **13/20** | **Acceptable** |

**Tactical Tornado Risk:** Medium
REPORT

APOSD_STORAGE_SUBDIR=audit \
APOSD_CRITIQUE_META='{"target":"order-service","total_score":13,"p0_count":0,"p1_count":2,"p2_count":1,"p3_count":1}' \
  node "$SKILL_DIR/scripts/critique-storage.mjs" write "$SLUG" "$BODY_FILE"
rm "$BODY_FILE"

echo ""
echo "=== Step 4: Read trend ==="
APOSD_STORAGE_SUBDIR=audit node "$SKILL_DIR/scripts/critique-storage.mjs" trend "$SLUG" 5

echo ""
echo "=== Done ==="
echo "Re-run after fixes to track improvement."
