#!/bin/bash
set -e -o pipefail

SITE_ID="$1"

sudo mysql -u root << EOF
    CREATE USER $SITE_ID@localhost IDENTIFIED BY "$SITE_ID";
    CREATE DATABASE $SITE_ID;
    GRANT ALL ON $SITE_ID.* TO $SITE_ID@localhost;
    FLUSH PRIVILEGES;
    EXIT
EOF
