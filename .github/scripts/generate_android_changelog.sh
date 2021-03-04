#!/usr/bin/env bash

declare -a locales=("en-US" "zh-TW")

for locale in "${locales[@]}"
do
  mkdir -p android/fastlane/metadata/android/"${locale}"/
  jq -r ".\"$1\".\"${locale}\"" assets/changelog.json >> android/fastlane/metadata/android/"${locale}"/default.txt
done

echo "Generate android changelog success"