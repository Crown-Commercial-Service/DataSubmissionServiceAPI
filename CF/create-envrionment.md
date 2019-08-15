# Create a postgres instance

https://docs.cloud.service.gov.uk/deploying_services/postgresql/#set-up-a-postgresql-service

```
cf create-service postgres small-ha-10 ccs-rmi-api -c '{"enable_extensions": ["pgcrypto"]}'
```

Manifest.yml must be bound to all services

Create a CDN file in the frontend's CF directory for the new routing

Allow your environment name as a trusted environment to the if conditions in the frontend's CF/create-cf-space.sh script.

```
./create-cf-space.sh -u <YOUR_PAAS_EMAIL> -p '<YOUR_PAAS_PASSWORD>' -o ccs-report-management-info -s sandbox
```

This outputs some CDN stuff that we need to share with dxw's DNS by adding to this file https://git.govpress.com/ops/BytemarkDNS/blob/master/data/dxw.net#L755:

```
status:    create in progress
message:   Provisioning in progress
           [api.sandbox.rmi-paas.dxw.net,www.sandbox.rmi-paas.dxw.net =>
           london.cloudapps.digital]; CNAME or ALIAS domain
           api.sandbox.rmi-paas.dxw.net,www.sandbox.rmi-paas.dxw.net to
           d1ltkl96cllw58.cloudfront.net and create TXT record(s):
name:
           _acme-challenge.api.sandbox.rmi-paas.dxw.net., value:
           ixWuvWClkQ_tz9J_F6wsOb_9oDA-tnX9jalIXFWg31s, ttl: 120
name:
           _acme-challenge.www.sandbox.rmi-paas.dxw.net., value:
           2nXmjloNUjpqZODXqOEqheVjJQKV5oSqwyjubKSfkb8, ttl: 120
started:   2019-08-15T10:01:15Z
updated:   2019-08-15T10:01:17Z
```

Until you do this, and the change is deployed the new CDN service will not complete it's provisioning: https://git.govpress.com/ops/BytemarkDNS/merge_requests/102/diffs

When the database is created for the first time, there are permission errors.
removing `rake db:create` from the docker-entrypoint.sh and allowing schema load to run a single time will fix this problem, you can then replace the db:create. Otherwise look at doing a database restore from staging

You need to add some additional routing in order to all users access of the admin section for the API, which is otherwise thought of as a "private" application within paas.

https://github.com/dxw/DataSubmissionService/pull/238/files

You need to check this out, allow the new space name in the if conditions and deploy the app from your local machine: https://github.com/dxw/DataSubmissionServiceRouter
