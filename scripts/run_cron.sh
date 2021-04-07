#!/bin/bash

# change cron schedule
sed -i "s,CRON_SCHEDULE*,${BACKUP_CRON_SCHEDULE},g" /etc/cron.d/backup-cron

# Collect environment variables set by docker
touch /tmp/scheduler-env
printenv | sort | sed 's/^\(.*\)\=\(.*\)$/export \1\="\2"/g' > /tmp/scheduler-env
chmod 0644 /tmp/scheduler-env

# Copy scheduler crontab
cat /etc/cron.d/backup-cron >> /tmp/backup-cron
mv /tmp/backup-cron /etc/cron.d/backup-cron

# Disable logrotate for cron file so the tail will keep working
mv /etc/logrotate.d/rsyslog rsyslog.disabled

touch /var/log/cron.log && cron && tail -f /var/log/cron.log
