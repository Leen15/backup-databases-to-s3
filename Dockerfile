FROM ruby:2.3
MAINTAINER jannis@gmail.com

RUN apt-get update -y && \
    apt-get install -y wget htop lbzip2 gnupg2 build-essential libxml2-dev libxslt-dev liblzma-dev zlib1g-dev patch libpq5 cron && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update -y && \
    apt-get install -y postgresql-client-9.6

# Create workdir
RUN mkdir /backup
WORKDIR /backup

# Prepare ruby & gems
COPY Gemfile /backup/Gemfile
COPY Gemfile.lock /backup/Gemfile.lock
RUN gem install nokogiri -v 1.6.7.1 -- --use-system-libraries=true --with-xml2-include=/usr/include/libxml2 && \
    gem install bundler && \
    bundle config build.nokogiri --use-system-libraries=true --with-xml2-include=/usr/include/libxml2 && \
    NOKOGIRI_USE_SYSTEM_LIBRARIES=1 bundle install

# Copy scripts
COPY run_cron.sh /backup/run_cron.sh
RUN chmod 0700 /backup/run_cron.sh
COPY backup.sh /backup/backup.sh
RUN chmod 0700 /backup/backup.sh
COPY s3upload.rb /backup/s3upload.rb
RUN chmod 0700 /backup/s3upload.rb

# Define default CRON_SCHEDULE to 1 your
ENV BACKUP_CRON_SCHEDULE="0 * * * *"
ENV BACKUP_PRIORITY="ionice -c 3 nice -n 10"

# Prepare cron
ADD crontab /etc/cron.d/backup-cron
RUN chmod 0644 /etc/cron.d/backup-cron

# Run the command on container startup
ENTRYPOINT /backup/run_cron.sh
