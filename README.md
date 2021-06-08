Drupal VM creation using Multipass
==================================

The [create-multipass-drupal9.bash](create-multipass-drupal9.bash) script uses
[Multipass](https://multipass.run) to quickly make and run a VM with Drupal 9
installed and ready.

Requirements
------------

You need:

- Multipass https://multipass.run (I installed it with snap)
- Python3 with the http.server package
- an internet connection

The script must be run from its directory.

Running the script
------------------

The script needs one parameter, the site ID:

    bash create-multipass-drupal9.bash mydrupal9

If everything is ok, you should have a fully functional Drupal 9 running in
a Multipass VM called mydrupal9.

To show the Multipass VMs and get their IP, just type on the host:

    multipass list

To completely delete a VM, you need to do the following:

    multipass delete mydrupal9
    multipass purge

To open a shell in the VM:

    multipass shell mydrupal9

What you got once the script has run
------------------------------------

The installed Drupal 9 has the following characteristics if you have used
`mydrupal9` as the site ID:

- **VM user/password**: ubuntu/ubuntu
- **Database/user/password**: mydrupal9/mydrupal9/mydrupal9
- **Drupal user/password**: admin/admin
- **Web site configuration**: /etc/apache2/sites-available/mydrupal9.conf
- **Document root**: /var/www/mydrupal9/web
- **Apache2/PHP logs**: /var/log/apache2/access.log, /var/log/apache2/error.log
- Drupal 9 has been entirely installed using Composer and Drush
- Composer and Drush are available from the command line of the ubuntu user
- UploadProgress extension is installed
- APCu cache is installed
- Cron job is configured to run every 5 minutes (it uses drush cron)
- Trusted host patterns are configured on the VM IP address

Notes
-----

**The VMs created by this script are not meant for production!**

The scripts in the [install-scripts](install-scripts) directory are meant to be
executed in the VM.

The script has been tested with:

- Ubuntu 20.04
- Apache 2.4.41
- MariaDB 10.3.29
- PHP 7.4.3
- GD 2.2.5
- Drupal 9.1.10
