#!/usr/bin/env bash
set -euo pipefail

RANGE="${1:-}"
if [[ -z "$RANGE" ]]; then
  echo "Usage: $0 <git-range>"
  exit 2
fi

# Conventional Commit subset used for automated semantic versioning.
semantic_re='^(feat|fix|perf|refactor|build|ci|docs|style|test|chore|revert)(\([a-z0-9._/-]+\))?(!)?: .+'

invalid=0

while IFS= read -r subject; do
  [[ -z "$subject" ]] && continue

  # Auto-generated merge commits are ignored.
  if [[ "$subject" =~ ^Merge\  ]]; then
    continue
  fi

  if [[ ! "$subject" =~ $semantic_re ]]; then
    echo "Invalid commit message: $subject"
    invalid=1
  fi
done < <(git log --format=%s "$RANGE")

if [[ "$invalid" -ne 0 ]]; then
  echo ""
  echo "Commit messages must follow Conventional Commits."
  echo "Example: feat(zigbee): add periodic attribute reporting"
  echo "Allowed types: feat, fix, perf, refactor, build, ci, docs, style, test, chore, revert"
  exit 1
fi

echo "All commit messages in $RANGE are semantic/conventional."
