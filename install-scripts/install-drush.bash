#!/bin/bash
set -e -o pipefail
source ~/.profile

composer global require drush/drush

# Make drush available anywhere
for vendorbin in ~/.config/composer/vendor/bin/*
do
    ln --symbolic "$vendorbin" ~/bin/$(basename "$vendorbin")
done
