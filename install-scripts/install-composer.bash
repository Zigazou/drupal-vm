#!/bin/bash
set -e -o pipefail
source ~/.profile

BIN=~/bin

mkdir --parents "$BIN"

wget \
    --output-document=composer-setup.php \
    https://getcomposer.org/installer

php composer-setup.php --install-dir="$BIN" --filename=composer --quiet

rm composer-setup.php
