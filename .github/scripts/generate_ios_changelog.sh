#!/usr/bin/env bash

declare -a locales=("en-US" "zh-TW")

for locale in "${locales[@]}"
do
  jq -r ".\"$1\".\"${locale}\"" assets/changelog.json >> ios/fastlane/changelog.txt
done

echo "Generate iOS changelog success"