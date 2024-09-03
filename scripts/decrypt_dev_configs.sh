#!/bin/sh

# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$DEV_CONFIGS_PASSPHRASE" \
--output dev_configs.zip dev_configs.zip.gpg && sh scripts/unzip_dev_configs.sh
