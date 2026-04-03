#!/bin/bash
set -euo pipefail

VERSION_CODE="$1"
TARGET="$2" # android, ios, or github

CHANGELOG_FILE="changelog.json"

# Validate version code exists in changelog.json
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
  ios)
    for locale in "en-US" "zh-TW"; do
      jq -r ".\"${VERSION_CODE}\".\"${locale}\" | map(\"* \" + .) | join(\"\n\")" "$CHANGELOG_FILE" \
        > "${locale}.txt"
    done
    echo "Generated iOS changelog for version code ${VERSION_CODE}"
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
    echo "ERROR: Unknown target '${TARGET}'. Use: android, ios, or github"
    exit 1
    ;;
esac
