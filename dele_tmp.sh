find /var/www/html/webcp/tmp/ -type f -mtime +7 | xargs rm -fr
find /var/www/html/webcp/includes/cron/tmp/ -type f -mtime +7 | xargs rm -fr
find /var/www/html/webcp/backups/tmp/ -type d -mtime +7 | xargs rm -fr
find /var/www/html/webcp/restore/tmp/ -type d -mtime +7 | xargs rm -fr
