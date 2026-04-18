#!/bin/bash
set -euo pipefail

VERSION_CODE="$1"
TARGET="$2" # android, ios, macos, or github

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------------------------
# New path: use LLM-aggregated changelog if AGGREGATED_CHANGELOG is set
# ---------------------------------------------------------------------------
if [ -n "${AGGREGATED_CHANGELOG:-}" ] && [ -f "$AGGREGATED_CHANGELOG" ]; then
  ENTRY_COUNT=$(jq length "$AGGREGATED_CHANGELOG")

  if [ "$ENTRY_COUNT" -eq 0 ]; then
    echo "WARNING: No aggregated changelog entries found for ${TARGET}, using fallback."
    FALLBACK="Bug fixes and improvements."
    case "$TARGET" in
      android)
        for locale in "en-US" "zh-TW"; do
          mkdir -p "metadata/android/${locale}/changelogs/"
          echo "$FALLBACK" > "metadata/android/${locale}/changelogs/default.txt"
        done
        ;;
      ios|macos)
        echo "$FALLBACK" > "en-US.txt"
        echo "問題修正與效能改善。" > "zh-TW.txt"
        ;;
      github)
        echo "Bug fixes and improvements." > RELEASE_NOTES_GENERATED.md
        ;;
    esac
    exit 0
  fi

  case "$TARGET" in
    android)
      for locale in "en-US" "zh-TW"; do
        mkdir -p "metadata/android/${locale}/changelogs/"
        jq -r ".[] | \"* \" + .[\"${locale}\"]" "$AGGREGATED_CHANGELOG" \
          > "metadata/android/${locale}/changelogs/default.txt"
      done
      echo "Generated Android changelog ($ENTRY_COUNT entries)"
      ;;
    ios|macos)
      for locale in "en-US" "zh-TW"; do
        jq -r ".[] | \"* \" + .[\"${locale}\"]" "$AGGREGATED_CHANGELOG" \
          > "${locale}.txt"
      done
      echo "Generated ${TARGET} changelog ($ENTRY_COUNT entries)"
      ;;
    github)
      VERSION="${RELEASE_VERSION:-unknown}"
      {
        echo "## v${VERSION}"
        echo ""
        echo "**What's New**"
        jq -r ".[] | \"- \" + .[\"en-US\"]" "$AGGREGATED_CHANGELOG"
        echo ""
        echo "---"
        echo ""
        echo "**更新內容**"
        jq -r ".[] | \"- \" + .[\"zh-TW\"]" "$AGGREGATED_CHANGELOG"
      } > RELEASE_NOTES_GENERATED.md
      echo "Generated GitHub release notes ($ENTRY_COUNT entries)"
      ;;
    *)
      echo "ERROR: Unknown target '${TARGET}'. Use: android, ios, macos, or github"
      exit 1
      ;;
  esac
  exit 0
fi

# ---------------------------------------------------------------------------
# Legacy path: read from changelog.json keyed by version_code
# ---------------------------------------------------------------------------
CHANGELOG_FILE="$SCRIPT_DIR/../../changelog.json"

if ! jq -e ".\"${VERSION_CODE}\"" "$CHANGELOG_FILE" > /dev/null 2>&1; then
  echo "WARNING: Version code ${VERSION_CODE} not found in ${CHANGELOG_FILE}, skipping changelog generation."
  exit 0
fi

case "$TARGET" in
  android)
    for locale in "en-US" "zh-TW"; do
      mkdir -p "metadata/android/${locale}/changelogs/"
      jq -r ".\"${VERSION_CODE}\".\"${locale}\" | map(\"* \" + .) | join(\"\n\")" "$CHANGELOG_FILE" \
        > "metadata/android/${locale}/changelogs/default.txt"
    done
    echo "Generated Android changelog for version code ${VERSION_CODE}"
    ;;
  ios|macos)
    for locale in "en-US" "zh-TW"; do
      jq -r ".\"${VERSION_CODE}\".\"${locale}\" | map(\"* \" + .) | join(\"\n\")" "$CHANGELOG_FILE" \
        > "${locale}.txt"
    done
    echo "Generated ${TARGET} changelog for version code ${VERSION_CODE}"
    ;;
  github)
    VERSION=$(jq -r ".\"${VERSION_CODE}\".version" "$CHANGELOG_FILE")
    {
      echo "## v${VERSION}"
      echo ""
      jq -r ".\"${VERSION_CODE}\".\"en-US\" | map(\"- \" + .) | join(\"\n\")" "$CHANGELOG_FILE"
      echo ""
      echo "---"
      echo ""
      jq -r ".\"${VERSION_CODE}\".\"zh-TW\" | map(\"- \" + .) | join(\"\n\")" "$CHANGELOG_FILE"
    } > RELEASE_NOTES_GENERATED.md
    echo "Generated GitHub release notes for version code ${VERSION_CODE}"
    ;;
  *)
    echo "ERROR: Unknown target '${TARGET}'. Use: android, ios, macos, or github"
    exit 1
    ;;
esac
