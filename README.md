# Docker Postgres backup to Amazon S3 via cron

This image dumps your postgres databases every hour (OR custom cron defined in `BACKUP_CRON_SCHEDULE`),
compresses the dump using bz2 and uploads it to an
amazon S3 bucket. Backups older than 30 days (OR days defined in `AWS_KEEP_FOR_DAYS`) are
deleted automatically.
It also have a `BACKUP_PRIORITY` params for set the backup priority with ionice and nice values.

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
- `PGHOST`
- `PGDATABASE`
- `PGPORT`
- `PGUSER`
- `PGPASSWORD`


## Usage

If you wish to do postgres backups to s3 with [tutum](http://tutum.co)
or [docker compose](https://docs.docker.com/compose/), put this in your
`Stackfile`/`docker-compose.yml`:

```yaml
fitty-postgres-backup:
  image: 'leen15/postgres-s3-backup-via-cron'
  environment:
    - AWS_ACCESS_KEY_ID=<access key>
    - AWS_BUCKET_NAME=<your s3 bucket name>
    - AWS_REGION=<the region your bucket is in>
    - AWS_SECRET_ACCESS_KEY=< secret access key>
    - AWS_KEEP_FOR_DAYS=< how many days do you want to keep backups>
    - BACKUP_PATH=<this will be the directory containing your backups on s3>
    - BACKUP_CRON_SCHEDULE=<this will be the cron schedule if defined. Standard value is 1 hour>
    - BACKUP_PRIORITY=<this is the priority, standard value is "ionice -c 3 nice -n 10">
    - PGHOST=<see the link section below>
    - PGDATABASE=<dump only this database, default value export all>
    - PGUSER=<username>
    - PGPASSWORD=<password>
    - PGPORT=<this is usually 5432>
  links:
    - 'your-postgres-master-container:master'
```

The `links` section is optional, of course, just make sure you update the
`PGHOST` environment variable accordingly.


## Thanks

Adapted from [here](https://blog.danivovich.com/2015/07/23/postgres-backups-to-s3-with-docker-and-systemd/), [here](http://blog.oestrich.org/2015/01/pg-to-s3-backup-script/) and [here](https://www.ekito.fr/people/run-a-cron-job-with-docker/).
