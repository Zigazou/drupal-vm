#!/bin/bash
set -e -o pipefail

SITE_ID="$1"

# Enable the rewrite module for Drupal clean URLs
sudo a2enmod rewrite
sudo a2dissite 000-default.conf

# PHP FPM is needed for UploadProgress
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php7.4-fpm

sudo tee /etc/apache2/sites-available/$SITE_ID.conf << EOF
<VirtualHost *:80>
    ServerAdmin admin@$SITE_ID.com
    DocumentRoot /var/www/$SITE_ID/web
    ServerName  $SITE_ID.com
    ServerAlias www.$SITE_ID.com

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/$SITE_ID/web/>
        Options FollowSymlinks
        AllowOverride All
        Require all granted

        RewriteEngine on
        RewriteBase /
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)\$ index.php?q=\$1 [L,QSA]
    </Directory>
</VirtualHost>
EOF

sudo a2ensite $SITE_ID.conf

sudo systemctl restart apache2