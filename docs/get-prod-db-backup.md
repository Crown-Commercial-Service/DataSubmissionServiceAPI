# Getting a local copy of the prod DB

This is a fairly manual process with a tiny bit of rake help at the end.
Hopefully we'll automate daily backups. In the meantime, there's this.


## Prerequisites

### Cloudfoundry

GPaaS is based on Cloudfoundry, so we use their command-tools in order to access
the infrastructure.

Install the command-tool by following their setup guide
https://docs.cloud.service.gov.uk/get_started.html

Accessing the PostgreSQL database also requires the 'conduit' plugin for
Cloudfoundry. You can install this using:

    cf install-plugin conduit

## Create a backup (currently manual)

Make sure you're in the production space (called 'prod')

    cf target -s prod

Use conduit to make a dump of the production database

    cf conduit ccs-rmi-api-prod -- pg_dump -F tar --file production-backup-YYYYMMDD.tar

The `db:restore` rake tasks expects the file to be compressed, so let's do that

    gzip production-backup-YYYYMMDD.tar

Finally move the file into the `backups` directory ready to be restored

## Restore the backup

Launch a temporary instance of the `web` service, and get a shell on it.

    docker-compose run --rm web bash

On this container, install the Postgres client command-line tools, and then run
a task to load the database backup into the development database.

    apt-get install postgresql-client
    ./bin/rails db:reset_to_production

This task checks your current environment to make sure it matches the one the
database was last used in. To disable this, set this variable before running the
`db` task.

    export DISABLE_DATABASE_ENVIRONMENT_CHECK=1

If you want to restore from a specific backup file, run the `db:restore` task:

    ./bin/rails db:restore[path_to_gzipped_backup]
