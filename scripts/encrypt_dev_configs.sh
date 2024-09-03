#!/bin/sh

sh scripts/zip_dev_configs.sh
gpg --symmetric --cipher-algo AES256 dev_configs.zip