# Backup databases to Amazon S3 via cron

This image dumps your databases every hour (OR custom cron defined in `BACKUP_CRON_SCHEDULE`),
compresses the dump using bz2 and uploads it to an
amazon S3 bucket. Backups older than 30 days (OR days defined in `AWS_KEEP_FOR_DAYS`) are
deleted automatically.
It also have a `BACKUP_PRIORITY` params for set the backup priority with ionice and nice values.
At the moment, it supports:
- PostgreSQL (pg_dump, versions 9.6 -> 12)
- MySQL (mysqldump, versions 5.7+ )
- ClickHouse (versions 19+)

Configure the backup source and s3 target with these environment
variables:

- `AWS_REGION` (for example `eu-central-1`)
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_BUCKET_NAME`
- `AWS_KEEP_FOR_DAYS`
- `BACKUP_PATH`
- `BACKUP_CRON_SCHEDULE`
- `BACKUP_PRIORITY`
- `DB_TYPE` (allowed types: `postgres` | `mysql` | `clickhouse`)
- `DB_HOST`
- `DB_NAME`
- `DB_TABLE` (used and mandatory only with ClickHouse )
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`
- `DB_OPT_PARAMS` (for example with mysql `--lock-tables=false --single-transaction --quick` )



## Usage

If you wish to do backups to s3 with [docker compose](https://docs.docker.com/compose/), put this in your
`Stackfile`/`docker-compose.yml`:

```yaml
db-backup:
  image: 'leen15/backup-databases-to-s3'
  environment:
    - AWS_ACCESS_KEY_ID=<access key>
    - AWS_BUCKET_NAME=<your s3 bucket name>
    - AWS_REGION=<the region your bucket is in>
    - AWS_SECRET_ACCESS_KEY=< secret access key>
    - AWS_KEEP_FOR_DAYS=< how many days do you want to keep backups>
    - BACKUP_PATH=<this will be the directory containing your backups on s3>
    - BACKUP_CRON_SCHEDULE=<this will be the cron schedule if defined. Standard value is 1 hour>
    - BACKUP_PRIORITY=<this is the priority, standard value is "ionice -c 3 nice -n 10">
    - DB_TYPE=<allowed types: postgres | mysql | clickhouse>
    - DB_HOST=<see the link section below>
    - DB_NAME=<dump only this database, default value export all>
    - DB_USER=<username>
    - DB_PASSWORD=<password>
    - DB_PORT=<this is usually 5432>
  links:
    - 'your-db-container:master'
```

The `links` section is optional, of course, just make sure you update the
`DB_HOST` environment variable accordingly.


## Thanks

Adapted from [here](https://blog.danivovich.com/2015/07/23/postgres-backups-to-s3-with-docker-and-systemd/), [here](http://blog.oestrich.org/2015/01/pg-to-s3-backup-script/) and [here](https://www.ekito.fr/people/run-a-cron-job-with-docker/).
