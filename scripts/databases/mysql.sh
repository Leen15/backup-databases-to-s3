#!/bin/bash
echo "`date` Creating MYSQL dump"

export MYSQL_HOST="$DB_HOST"
export PGDATABASE="$DB_NAME"
export MYSQL_PORT="$DB_PORT"
export MYSQL_USER="$DB_USER"
export MYSQL_PWD="$DB_PASSWORD"


MYSQL_CONN="--user=$MYSQL_USER --host=$MYSQL_HOST --port=$MYSQL_PORT --password=${MYSQL_PWD}"

if [ -z "$DB_NAME" ]; then
  databases=$2
else
  databases=`mysql ${MYSQL_CONN} -N -e "SHOW DATABASES;" | grep -Ev "(information_schema|performance_schema${MYSQL_EXCLUDE_DBS})"`
fi


$BACKUP_PRIORITY mysqldump --force --events --opt $DB_OPT_PARAMS ${MYSQL_CONN} --databases $databases > /tmp/backup.dump