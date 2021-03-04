#!/usr/bin/env bash

declare -a locales=("en-US" "zh-TW")

for locale in "${locales[@]}"
do
  mkdir -p fastlane/metadata/android/"${locale}"/
  jq -r ".\"$1\".\"${locale}\"" ../assets/changelog.json >> fastlane/metadata/android/"${locale}"/"$1".txt
done

echo "Generate android changelog success"