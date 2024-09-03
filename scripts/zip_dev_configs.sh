#!/bin/sh

zip -r dev_configs.zip \
    lib/firebase_options.dart \
    android/app/google-services.json \
    ios/Runner/GoogleService-Info.plist \
    macos/Runner/GoogleService-Info.plist