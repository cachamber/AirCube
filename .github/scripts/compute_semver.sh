#!/usr/bin/env bash
set -euo pipefail

BRANCH_NAME="${1:?branch name required}"
RUN_NUMBER="${2:?run number required}"

current_version="$(tr -d '[:space:]' < firmware/version.txt)"
if [[ ! "$current_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Current firmware/version.txt is not semver (X.Y.Z): $current_version" >&2
  exit 1
fi

latest_tag="$(git tag --list 'v[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | head -n 1 || true)"
if [[ -n "$latest_tag" ]]; then
  base_version="${latest_tag#v}"
  range="${latest_tag}..HEAD"
else
  base_version="$current_version"
  range="HEAD"
fi

major=0
minor=0
patch=0

breaking_re='^[a-z]+\([^)]+\)!:|^[a-z]+!:'
feat_re='^feat(\([^)]+\))?:'
patch_re='^(fix|perf|refactor|build|ci|docs|style|test|chore|revert)(\([^)]+\))?:'

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  if [[ "$line" =~ BREAKING[[:space:]]CHANGE ]] || [[ "$line" =~ $breaking_re ]]; then
    major=1
    minor=0
    patch=0
    break
  fi

  if [[ "$line" =~ $feat_re ]]; then
    if [[ "$major" -eq 0 ]]; then
      minor=1
      patch=0
    fi
    continue
  fi

  if [[ "$line" =~ $patch_re ]]; then
    if [[ "$major" -eq 0 && "$minor" -eq 0 ]]; then
      patch=1
    fi
  fi
done < <(git log --format='%s%n%b' "$range")

IFS='.' read -r major_v minor_v patch_v <<< "$base_version"

if [[ "$major" -eq 1 ]]; then
  major_v=$((major_v + 1))
  minor_v=0
  patch_v=0
elif [[ "$minor" -eq 1 ]]; then
  minor_v=$((minor_v + 1))
  patch_v=0
elif [[ "$patch" -eq 1 ]]; then
  patch_v=$((patch_v + 1))
fi

next_version="${major_v}.${minor_v}.${patch_v}"

safe_branch="$(echo "$BRANCH_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's#[^a-z0-9._-]#-#g')"
if [[ "$BRANCH_NAME" == "master" ]]; then
  release_version="$next_version"
  release_tag="v${release_version}"
  prerelease="false"
  make_latest="true"
else
  release_version="${next_version}-dev.${RUN_NUMBER}"
  release_tag="dev-${safe_branch}"
  prerelease="true"
  make_latest="false"
fi

{
  echo "base_version=$base_version"
  echo "next_version=$next_version"
  echo "release_version=$release_version"
  echo "release_tag=$release_tag"
  echo "prerelease=$prerelease"
  echo "make_latest=$make_latest"
} >> "$GITHUB_OUTPUT"

printf 'Resolved versions:\n'
printf '  base_version: %s\n' "$base_version"
printf '  next_version: %s\n' "$next_version"
printf '  release_version: %s\n' "$release_version"
printf '  release_tag: %s\n' "$release_tag"
printf '  prerelease: %s\n' "$prerelease"
printf '  make_latest: %s\n' "$make_latest"
