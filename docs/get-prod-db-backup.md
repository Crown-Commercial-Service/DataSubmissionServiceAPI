# Getting a local copy of the prod DB

This is a fairly manual process with a tiny bit of rake help at the end. 
Hopefully we'll automate daily backups. In the meantime, there's this. 

## Create a backup (currently manual)

SSH into bastion with 

`ssh ccs.production`

SSH into dss-infrastructure-production with something like

`ssh ec2-user@<PublicDNS>`
e.g.
`ssh ec2-user@ec2-3-8-197-87.eu-west-2.compute.amazonaws.com`

The Public DNS of the container instance can be found in
```
  Clusters >  dss-infrastructure-production > choose container (dss-infrastructure-production) >
      ECS instances tab > lists 2 identical containers (pick either) > copy <Public DNS>
```       

We now need 2 things:
- RDS ENDPOINT: Find by going to RDS > Databases > dssinfrastructureproductionapi > Endpoint. 
  Looks something like dssinfrastructureproductionapi.cwixmd5p744n.eu-west-2.rds.amazonaws.com
- The postgres password, which we get from `echo $DATABASE_URL` on one of the docker instances
  - `docker exec -it <container ID, e.g. 06f047454282 from docker ps, pick API production> /bin/bash`
  - `echo $DATABASE_URL`
  - Copy the password from the URL
  - `exit` the docker container

Then:
  - Choose a name for the backup that corresponds to the naming convention in the `rake db:restore` task,
    e.g. `production-backup-20190130.tar`
  - `docker run -i postgres /usr/bin/pg_dump -F tar -h <RDS ENDPOINT> -U root dss_api > production-backup-20190130.tar`
  - paste the password
  - gzip the tar file `gzip production-backup-20190130.tar`
  - Copy the `.gz` file to bastion:
    - `exit` from AWS
    - `scp ec2-user@<PUBLIC_DNS_NAME>:production-backup-20190130.tar.gz .`
    - `exit` from Bastion to your local machine
    - assuming you're in your local API working dir, `mkdir backups`
    - `scp ccs.production:production-backup-20190130.tar.gz backups`
    - Don't forget to remove the backup from Bastion when you are done with it
  
## Restore the backup

- Since AWS has a `root` Postgres role, you'll need to create one locally.
  The first time you do this, create one with 
  `bash# psql postgres -c "CREATE ROLE root WITH SUPERUSER LOGIN;"`
- `DISABLE_DATABASE_ENVIRONMENT_CHECK=1 be rake db:reset_to_production` will drop your db, 
  create a new one and restore from the gzipped backup
- To restore from a specific backup, use `rake db:restore[path_to_gzipped_backup]`
