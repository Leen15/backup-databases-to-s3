# Backup databases to Amazon S3 via cron

This image dumps your databases every hour (OR custom cron defined in `BACKUP_CRON_SCHEDULE`),
compresses the dump using bz2 and uploads it to an amazon S3 bucket.  
With a valid `AWS_KEEP_FOR_DAYS` backups older than that days are deleted automatically (on the same path).   
It also have a `BACKUP_PRIORITY` params for set the backup priority with ionice and nice values.   
    
At the moment, it supports:
- PostgreSQL (pg_dump, versions <= 14)
- MySQL (mysqldump, versions 5.7+ )
- ClickHouse (versions 19+)

Configure the backup source and s3 target with these environment
variables:

- `AWS_REGION` (for example `eu-central-1`)
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_BUCKET_NAME`
- `AWS_BUCKET_PATH`
- `AWS_KEEP_FOR_DAYS`
- `AWS_SHOW_UPLOAD_PROGRESS` (ex. `true`)
- `BACKUP_CRON_SCHEDULE`
- `BACKUP_PRIORITY` (default `ionice -c 3 nice -n 10`)
- `COMPRESSION_PRIORITY` (ex. `ionice -c 3 nice -n 10`, null as default)
- `DB_TYPE` (allowed types: `postgres` | `mysql` | `clickhouse`)
- `DB_HOST`
- `DB_NAME`
- `DB_TABLE` (used and mandatory only with ClickHouse )
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`
- `DB_OPT_PARAMS` (for example with mysql `--lock-tables=false --single-transaction --quick` )


## Usage

You can you this image in two different ways:  
- Using the internal cronjob
- Using oneshot
- Using with a k8s cronjob

### Internal CronJob Example:
`docker run -it --env-file .env leen15/db-backup-to-s3` 
By default it will run every hour.   
    
### Oneshot Example:
`docker run -it --env-file .env --entrypoint '/backup/backup.sh' leen15/db-backup-to-s3` 
   
### K8s cronjob Example:
```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: Database Backup
spec:
  schedule: "0 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: db-backup
            image: leen15/db-backup-to-s3
            imagePullPolicy: IfNotPresent
            command:
            - /backup/backup.sh
            env:
            - name: AWS_ACCESS_KEY_ID
              value: keyID
            - name: AWS_SECRET_ACCESS_KEY
              value: secretKey
            - name: AWS_DEFAULT_REGION
              value: eu-west-1
            - name: AWS_BUCKET_NAME
              value: backups
            - name: AWS_BUCKET_PATH
              value: db-dumps/my-database
            - name: DB_TYPE
              value: mysql
            - name: DB_HOST
              value: db
            - name: DB_NAME
              value: my-database
            - name: DB_PORT
              value: 3306
            - name: DB_USER
              value: user
            - name: DB_PASSWORD
              value: password
            - name: DB_OPT_PARAMS
              value: --lock-tables=false --single-transaction --quick
          restartPolicy: OnFailure
```
   
## Thanks

Adapted from [here](https://blog.danivovich.com/2015/07/23/postgres-backups-to-s3-with-docker-and-systemd/), [here](http://blog.oestrich.org/2015/01/pg-to-s3-backup-script/) and [here](https://www.ekito.fr/people/run-a-cron-job-with-docker/).
