#!/bin/bash

export MYSQL_HOST="$DB_HOST"
export MYSQL_PORT="$DB_PORT"
export MYSQL_USER="$DB_USER"
export MYSQL_PWD="$DB_PASSWORD"


MYSQL_CONN="--user=$MYSQL_USER --host=$MYSQL_HOST --port=$MYSQL_PORT --password=${MYSQL_PWD}"

if [ -z "${DB_NAME}" ]; then
  databases=`mysql ${MYSQL_CONN} -N -e "SHOW DATABASES;" | grep -Ev "(information_schema|performance_schema${MYSQL_EXCLUDE_DBS})"`
  echo "`date` Selected DBs to backup: ${databases//[$'\t\r\n']/'|'}"
else
  databases=$DB_NAME
fi

echo "`date` Creating MYSQL dump"

$BACKUP_PRIORITY mysqldump --force --events --opt $DB_OPT_PARAMS ${MYSQL_CONN} --databases $databases > /tmp/backup.dump