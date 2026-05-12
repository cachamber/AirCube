#!/usr/bin/env bash
set -euo pipefail

RELEASE_VERSION="${1:?release version required}"
BRANCH_NAME="${2:?branch name required}"
BASE_VERSION="${3:?base version required}"
COMMIT_SHA="${4:?commit sha required}"

output_file="RELEASE_NOTES.md"
base_tag="v${BASE_VERSION}"

if git rev-parse "$base_tag" >/dev/null 2>&1; then
  range="${base_tag}..HEAD"
  range_label="$base_tag -> $COMMIT_SHA"
else
  range="HEAD"
  range_label="repository start -> $COMMIT_SHA"
fi

breaking_items=()
feat_items=()
fix_items=()
perf_items=()
refactor_items=()
build_items=()
ci_items=()
docs_items=()
style_items=()
test_items=()
chore_items=()
revert_items=()
other_items=()
conventional_re='^([a-z]+)(\([^)]+\))?(!)?:[[:space:]]+.+$'

while IFS=$'\t' read -r short_sha subject; do
  [[ -z "$subject" ]] && continue

  if [[ "$subject" =~ ^Merge\  ]]; then
    continue
  fi

  entry="- ${subject} (${short_sha})"

  if [[ "$subject" =~ $conventional_re ]]; then
    type="${BASH_REMATCH[1]}"
    bang="${BASH_REMATCH[3]:-}"

    if [[ "$bang" == "!" ]]; then
      breaking_items+=("$entry")
      continue
    fi

    case "$type" in
      feat) feat_items+=("$entry") ;;
      fix) fix_items+=("$entry") ;;
      perf) perf_items+=("$entry") ;;
      refactor) refactor_items+=("$entry") ;;
      build) build_items+=("$entry") ;;
      ci) ci_items+=("$entry") ;;
      docs) docs_items+=("$entry") ;;
      style) style_items+=("$entry") ;;
      test) test_items+=("$entry") ;;
      chore) chore_items+=("$entry") ;;
      revert) revert_items+=("$entry") ;;
      *) other_items+=("$entry") ;;
    esac
  else
    other_items+=("$entry")
  fi
done < <(git log --format='%h%x09%s' "$range")

{
  echo "# Firmware ${RELEASE_VERSION}"
  echo ""
  echo "Automated firmware build for branch ${BRANCH_NAME}."
  echo ""
  echo "Commit range: ${range_label}"
  echo ""

  if [[ ${#breaking_items[@]} -gt 0 ]]; then
    echo "## Breaking Changes"
    printf '%s\n' "${breaking_items[@]}"
    echo ""
  fi

  if [[ ${#feat_items[@]} -gt 0 ]]; then
    echo "## Features"
    printf '%s\n' "${feat_items[@]}"
    echo ""
  fi

  if [[ ${#fix_items[@]} -gt 0 ]]; then
    echo "## Fixes"
    printf '%s\n' "${fix_items[@]}"
    echo ""
  fi

  if [[ ${#perf_items[@]} -gt 0 ]]; then
    echo "## Performance"
    printf '%s\n' "${perf_items[@]}"
    echo ""
  fi

  if [[ ${#refactor_items[@]} -gt 0 ]]; then
    echo "## Refactors"
    printf '%s\n' "${refactor_items[@]}"
    echo ""
  fi

  if [[ ${#build_items[@]} -gt 0 ]]; then
    echo "## Build"
    printf '%s\n' "${build_items[@]}"
    echo ""
  fi

  if [[ ${#ci_items[@]} -gt 0 ]]; then
    echo "## CI"
    printf '%s\n' "${ci_items[@]}"
    echo ""
  fi

  if [[ ${#test_items[@]} -gt 0 ]]; then
    echo "## Tests"
    printf '%s\n' "${test_items[@]}"
    echo ""
  fi

  if [[ ${#docs_items[@]} -gt 0 ]]; then
    echo "## Documentation"
    printf '%s\n' "${docs_items[@]}"
    echo ""
  fi

  if [[ ${#style_items[@]} -gt 0 ]]; then
    echo "## Style"
    printf '%s\n' "${style_items[@]}"
    echo ""
  fi

  if [[ ${#chore_items[@]} -gt 0 ]]; then
    echo "## Chores"
    printf '%s\n' "${chore_items[@]}"
    echo ""
  fi

  if [[ ${#revert_items[@]} -gt 0 ]]; then
    echo "## Reverts"
    printf '%s\n' "${revert_items[@]}"
    echo ""
  fi

  if [[ ${#other_items[@]} -gt 0 ]]; then
    echo "## Other"
    printf '%s\n' "${other_items[@]}"
    echo ""
  fi

  if [[ ${#breaking_items[@]} -eq 0 && ${#feat_items[@]} -eq 0 && ${#fix_items[@]} -eq 0 && ${#perf_items[@]} -eq 0 && ${#refactor_items[@]} -eq 0 && ${#build_items[@]} -eq 0 && ${#ci_items[@]} -eq 0 && ${#test_items[@]} -eq 0 && ${#docs_items[@]} -eq 0 && ${#style_items[@]} -eq 0 && ${#chore_items[@]} -eq 0 && ${#revert_items[@]} -eq 0 && ${#other_items[@]} -eq 0 ]]; then
    echo "## Changes"
    echo "- No commits found in range."
    echo ""
  fi

  echo "Built from commit ${COMMIT_SHA}."
} > "$output_file"

echo "Generated ${output_file}"
