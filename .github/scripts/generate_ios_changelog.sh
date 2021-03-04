#!/bin/sh

for locale in "en-US" "zh-TW"
do
  jq -r ".\"$1\".\"${locale}\"" ../../assets/changelog.json >> "${locale}".txt
done

echo "Generate iOS changelog success"