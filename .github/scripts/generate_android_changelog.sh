#!/bin/sh


for locale in "en-US" "zh-TW"
do
  mkdir -p fastlane/metadata/android/"${locale}"/changelogs/
  jq -r ".\"$1\".\"${locale}\"" ../assets/changelog.json >> fastlane/metadata/android/"${locale}"/changelogs/default.txt
done

echo "Generate android changelog success"