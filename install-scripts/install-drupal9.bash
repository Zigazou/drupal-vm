#!/bin/bash
set -e -o pipefail
source ~/.profile

SITE_ID="$1"

cd /var/www

sudo mkdir -- "$SITE_ID"
sudo chown $USER:$USER "$SITE_ID"

composer \
    --no-interaction \
    create-project drupal/recommended-project \
    "$SITE_ID"

cd /var/www/$SITE_ID

composer \
    --no-interaction \
    require drush/drush
