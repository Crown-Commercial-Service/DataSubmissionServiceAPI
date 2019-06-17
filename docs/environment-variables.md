# Environment variables used by the application

There are several environment variables the application expects to be present
to function. These are listed in `.env.development.example` and described
below.

- DATABASE_URL – The URL where the application database exists
- TEST_DATABASE_URL – The URL for the test database. This can be specified to
prevent the development database from being clobbered during local development
- AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY/AWS_S3_REGION/AWS_S3_BUCKET – The
AWS credentials for accessing various AWS services, including S3, CloudWatch
and Lambda
- AWS_S3_EXPORT_BUCKET – The AWS S3 bucket where the data warehouse exports
should be uploaded to. See DataWarehouseExport and Export::S3Upload for more
details.
- GOOGLE_CLIENT_ID/GOOGLE_CLIENT_SECRET – Google credentials used for
authenticating Admin users. Not required in local development as a separate
auth strategy is used if these variables are not set.
- ADMIN_EMAILS – A whitelist of the users that should be granted access to the
admin interface
- AUTH0_DOMAIN/AUTH0_CLIENT_ID/AUTH0_CLIENT_SECRET – Auth0 credentials. Used
to create/update users in Auth0. These can be found in the "Applications"
section of the Auth0 dashboard. The application ID for local development is
"Report MI Admin (Staging)"; do not use the production Auth0 credentials
locally!
- AUTH0_JWT_PUBLIC_KEY - used to validate the signed JWT token, to ensure it
hasn't been tampered with.
- SIDEKIQ_USERNAME/SIDEKIQ_PASSWORD – Credentials to protect access to the
Sidekiq administrative interface
- SIDEKIQ_CONCURRENCY - Used to set the number of jobs that Sidekiq will attempt
to work on at once. If not set, falls back to DATABASE_POOL_SIZE.
- SUBMIT_INVOICES – Used as a feature-switch to enable/disable Workday
integration, which will make API calls to generate invoices for completed
submissions
- WORKDAY_API_USERNAME/WORKDAY_API_PASSWORD – Workday credentials used to make
calls to the API to create invoices and credit notes
