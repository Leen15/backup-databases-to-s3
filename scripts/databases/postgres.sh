#!/bin/bash
echo "`date` Creating POSTGRES dump"

export PGHOST="$DB_HOST"
export PGDATABASE="$DB_NAME"
export PGPORT="$DB_PORT"
export PGUSER="$DB_USER"
export PGPASSWORD="$DB_PASSWORD"

if [ -z "$PGDATABASE" ]; then
  CMD=pg_dumpall
else
  CMD="pg_dump ${PGDATABASE}"
fi

$BACKUP_PRIORITY $CMD > /tmp/backup.dump