#!/bin/bash

# Stop whenever something fails
set -e -o pipefail

SITE_ID="$1"

# Holds the script server PID in order to be able to stop it.
SCRIPT_SERVER_PID=''

function script_server_start() {
    pushd "$1" > /dev/null
    python3 -m http.server &
    SCRIPT_SERVER_PID=$!
    popd
}

function script_server_stop() {
    kill "$SCRIPT_SERVER_PID"
}

# Create the VM using MultiPass
multipass launch --name "$SITE_ID"

# Retrieve the hypervisor IP (lazy way)
HYPERVISOR_IP=$(multipass exec "$SITE_ID" -- \
    eval echo '$SSH_CLIENT' \
        | awk '{ print $1 }' \
) 

# Run APT update to populate the database with interesting packages
multipass exec "$SITE_ID" -- \
    sudo apt update

# Create the Ubuntu user bin directory
multipass exec "$SITE_ID" -- \
    mkdir bin

# Install packages needed by Drupal 9
multipass exec "$SITE_ID" -- \
    sudo apt install --yes --force-yes \
        unzip \
        apache2 \
        mariadb-server \
        mariadb-client \
        php \
        libapache2-mod-php \
        php-cli \
        php-fpm \
        php-json \
        php-common \
        php-mysql \
        php-zip \
        php-gd \
        php-intl \
        php-mbstring \
        php-curl \
        php-xml \
        php-pear \
        php-tidy \
        php-soap \
        php-bcmath \
        php-xmlrpc \
        php-uploadprogress \
        php-apcu

# Add group Create the Ubuntu user bin directory
multipass exec "$SITE_ID" -- \
    sudo usermod -a -G www-data ubuntu

# Run a simple HTTP server to transfer scripts in the VM
script_server_start "install-scripts"

multipass exec "$SITE_ID" -- \
    wget "http://$HYPERVISOR_IP:8000/config-drupal9.bash"

multipass exec "$SITE_ID" -- \
    wget "http://$HYPERVISOR_IP:8000/create-database.bash"

multipass exec "$SITE_ID" -- \
    wget "http://$HYPERVISOR_IP:8000/create-virtualhost.bash"

multipass exec "$SITE_ID" -- \
    wget "http://$HYPERVISOR_IP:8000/install-composer.bash"

multipass exec "$SITE_ID" -- \
    wget "http://$HYPERVISOR_IP:8000/install-drupal9.bash"

multipass exec "$SITE_ID" -- \
    wget "http://$HYPERVISOR_IP:8000/install-drush.bash"

multipass exec "$SITE_ID" -- \
    wget "http://$HYPERVISOR_IP:8000/create-cronjob.bash"

# The HTTP server is not needed anymore, stop it!
script_server_stop

multipass exec "$SITE_ID" -- \
    bash install-composer.bash

multipass exec "$SITE_ID" -- \
    bash install-drush.bash

multipass exec "$SITE_ID" -- \
    bash create-database.bash "$SITE_ID"

multipass exec "$SITE_ID" -- \
    bash install-drupal9.bash "$SITE_ID"

multipass exec "$SITE_ID" -- \
    bash create-virtualhost.bash "$SITE_ID"

multipass exec "$SITE_ID" -- \
    bash config-drupal9.bash "$SITE_ID"

multipass exec "$SITE_ID" -- \
    bash create-cronjob.bash "$SITE_ID"
