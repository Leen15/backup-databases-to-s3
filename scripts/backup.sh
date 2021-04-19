#!/bin/bash
set -e
echo "`date` ~~~~~~~~~~~ STARTING BACKUP ~~~~~~~~~~~~"
# echo "Config:"
# echo "  - AWS_REGION=${AWS_REGION}"
# echo "  - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
# echo "  - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
# echo "  - AWS_BUCKET_NAME=${AWS_BUCKET_NAME}"
# echo "  - AWS_BUCKET_PATH=${AWS_BUCKET_PATH}"
# echo "  - DB_TYPE=${DB_TYPE}"
# echo "  - DB_HOST=${DB_HOST}"
# echo "  - DB_NAME=${DB_NAME}"
# echo "  - DB_PORT=${DB_PORT}"
# echo "  - DB_USER=${DB_USER}"
# echo "  - DB_PASSWORD=${DB_PASSWORD}"

rm -f /tmp/backup.dump.bz2

if [ -f /tmp/backup.dump ]; then
  echo "Dump in progress, aborting..."
  exit 0
fi


if [ -z "$DB_NAME" ]; then
  FILENAME=all_databases.$(date +"%Y-%m-%d-%H-%M-%S").sql.dump
else
  FILENAME=$DB_NAME.$(date +"%Y-%m-%d-%H-%M-%S").sql.dump
fi


if [[ "$DB_TYPE" == "postgres" ]]; then
  /backup/databases/postgres.sh
elif [[ "$DB_TYPE" == "mysql" ]]; then
  /backup/databases/mysql.sh
elif [[ "$DB_TYPE" == "clickhouse" ]]; then
  /backup/databases/clickhouse.sh
else
  echo "DB_TYPE not recognized. Supported types: postgres | mysql | clickhouse."
  exit 0
fi 

echo "`date` Compressing dump"
mv /tmp/backup.dump /tmp/$FILENAME
lbzip2 /tmp/$FILENAME

echo "`date` Uploading to S3"
/backup/s3upload.rb /tmp/$FILENAME.bz2

echo "`date` ~~~~~~~~~~~ BACKUP COMPLETED ~~~~~~~~~~~~"
