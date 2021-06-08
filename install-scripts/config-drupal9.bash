#!/bin/bash
set -e -o pipefail
source ~/.profile

SITE_ID="$1"

cd /var/www/$SITE_ID

# Let Drush configure the database for us
drush --yes site-install \
    --site-name "$SITE_ID" \
    --account-name=admin \
    --account-pass=admin \
    --db-url="mysql://$SITE_ID:$SITE_ID@localhost/$SITE_ID"

# Change group permission for the files directory, otherwise Drupal won't be
# able to write into it (which means no visible theme)
sudo chgrp -R www-data /var/www/$SITE_ID/web/sites/default/files

sudo find /var/www/$SITE_ID/web/sites/default/files \
    -type d \
    -exec chmod g+s \{\} \;

# Configure the Claro administrative theme
drush --yes theme:enable claro
drush --yes config:set system.theme admin claro

# Configure trusted host patterns
HYPERVISOR_IP=$(echo "$SSH_CONNECTION" \
    | awk '{ print $3 }' \
    | sed 's/\./\\./g' \
)

chmod u+w /var/www/$SITE_ID/web/sites/default/settings.php

cat >> /var/www/$SITE_ID/web/sites/default/settings.php <<EOF

/**
 * Trusted host patterns
 */
\$settings['trusted_host_patterns'] = [
  '^localhost\$',
  '^127\\.0\\.0\\.1\$',
  '^$HYPERVISOR_IP\$',
];
EOF

chmod u-w /var/www/$SITE_ID/web/sites/default/settings.php
