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

`cf install-plugin conduit`

## Create a backup (currently manual)

Make sure you're in the production space (called 'prod')

`cf target -s prod`

Use conduit to make a dump of the production database

`cf conduit ccs-rmi-api-prod -- pg_dump -F tar --file production-backup-YYYYMMDD.tar`

The `db:restore` rake tasks expects the file to be compressed, so let's do that

`gzip production-backup-YYYYMMDD.tar`

Finally move the file into the `backups` directory ready to be restored

## Restore the backup

- Since AWS has a `root` Postgres role, you'll need to create one locally.
  The first time you do this, create one with
  `bash# psql postgres -c "CREATE ROLE root WITH SUPERUSER LOGIN;"`
- `DISABLE_DATABASE_ENVIRONMENT_CHECK=1 be rake db:reset_to_production` will drop your db,
  create a new one and restore from the gzipped backup
- To restore from a specific backup, use `rake db:restore[path_to_gzipped_backup]`
