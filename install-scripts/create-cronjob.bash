#!/bin/bash
set -e -o pipefail
source ~/.profile

SITE_ID="$1"
BIN=~/bin

# Run cron job every 5 minutes
printf '%s /usr/bin/env PATH=%s COLUMNS=%d %s/drush --root=%s --quiet cron\n' \
    '*/5 * * * *' \
    "$PATH" \
    72 \
    "$BIN" \
    "/var/www/$SITE_ID" \
    > /tmp/mycron

crontab /tmp/mycron

rm /tmp/mycron
