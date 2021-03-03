#!/bin/sh

# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$KEYS_SECRET_PASSPHRASE" \
--output ios/Runner/ios_keys.zip ios/Runner/ios_keys.zip.gpg && cd ios/Runner && jar xvf ios_keys.zip && cd -
