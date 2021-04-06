#!/bin/bash
echo "`date` Creating CLICKHOUSE dump"

if [ -z "$DB_TABLE" ]; then
  echo "Missing mandatory env DB_TABLE."
  exit 0
fi


$BACKUP_PRIORITY clickhouse-client --host $DB_HOST --query="SELECT * FROM $DB_TABLE FORMAT Native" > /tmp/backup.dump