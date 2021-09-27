#!/bin/sh


for locale in "en-US" "zh-TW"
do
  mkdir -p metadata/android/"${locale}"/changelogs/
  jq -r ".\"$1\".\"${locale}\"" ../../changelog.json >> metadata/android/"${locale}"/changelogs/default.txt
done

echo "Generate android changelog success"