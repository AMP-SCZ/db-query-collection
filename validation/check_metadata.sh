#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT_DIR/_meta/MANIFEST.yaml"

if [[ ! -f "$MANIFEST" ]]; then
  echo "ERROR: missing $MANIFEST"
  exit 1
fi

echo "Checking manifest IDs for uniqueness..."
IDS=$(grep -E '^  - id: ' "$MANIFEST" | awk '{print $3}')
if [[ -z "$IDS" ]]; then
  echo "ERROR: no IDs found in manifest"
  exit 1
fi

DUPES=$(echo "$IDS" | sort | uniq -d || true)
if [[ -n "$DUPES" ]]; then
  echo "ERROR: duplicate IDs found:"
  echo "$DUPES"
  exit 1
fi

echo "Checking manifest paths exist..."
MISSING=0
while IFS= read -r p; do
  REL=$(echo "$p" | sed -E 's/^    path: "(.*)"$/\1/')
  if [[ ! -e "$ROOT_DIR/$REL" ]]; then
    echo "ERROR: missing path referenced in manifest: $REL"
    MISSING=1
  fi
done < <(grep -E '^    path: "' "$MANIFEST")

if [[ "$MISSING" -ne 0 ]]; then
  exit 1
fi

echo "Metadata check passed."
