# Change Log

## [release-98] - 2020-01-23

- Bulk user import runs as a background job

## [release-97] - 2020-01-15

- Fix: Restore column order for the submissions export

## [release-96] - 2020-01-07

- Data warehouse export hits IOPS read limit every time it is run (Speed up DataWarehouseExport.generate!)

## [release-95] - 2019-12-19

- Multi-column management charge calculation
- Upgrade to Ruby 2.5.7
- Validate multi-column management charge calcs
- Add missing database indexes
- Add 'maintenance_work_mem' setting for Postgres
- [Security] Bump simple_form from 4.1.0 to 5.0.0 
- [Security] Bump puma from 3.11.4 to 3.12.2
- Support integer column headings in management charge calculation
- Fix multi-column management charge calculation
- [Security] Bump rack from 2.0.7 to 2.0.8
- Pin bundler to 2.0.2 and do not update rubygems

## [release-94] - 2019-11-14

- Run the daily data warehouse export at 20:30
- Don’t retry ingestion job when submission has been marked as ingest_failed
- [Security] Bump loofah from 2.2.3 to 2.3.1
- Ensure only valid ISO8601 dates are parsed and converted

## [release-93] - 2019-11-06

- Ingest doesn't error if running total encounters a nil value
- Allow update template to fail gracefully if a template file is forgotten

## [release-92] - 2019-10-24

- Performance improvements to avoid large returns taking down the service, increased work_mem for postgres, and added a new column called `invoice_total`

## [release-91] - 2019-10-15

- A new script to clean up incorrect URNs created after a Customer with a URN of 0 was mistakenly added to the database; this time in SQL
- A script to backfill all management_charge_total for Submissions, again in SQL because the script in the previous release was not performant

## [release-90] - 2019-10-14

- Clean up incorrect URNs created after a Customer with a URN of 0 was mistakenly added to the database
- Add management_charge_total for Supplier and backfill for troublesome clients with large returns
- Calculate management charge and send invoice for returns where total_send is 0 but management_charge is non-zero

## [release-89] - 2019-09-19

- Allow -f command-line switch to work in CF/deploy-app.sh
- Reduce Sidekiq's memory usage
- Deploy two separate instances of Sidekiq, one for each queue
- Move ingest jobs into a separate 'ingest' queue
- Use the API_ROLLBAR user service for rollbar environment variables
- Increase Sidekiq memory from 8192M to 16384M (already applied to prod)

## [release-88] - 2019-08-30

- Reduce Sidekiq concurrency from 30-5 to prevent concurrency errors during busy ingest periods
- Align Puma, Sidekiq and Database concurrency to avoid database connection errors
- Documentation for how user logins work

## [release-87] - 2019-08-29

- Add some security-related HTTP response headers
- Creating users in Auth0 no longer fails if the local user is missing
- Deactivated users are reactivated with through the bulk upload feature

## [release-86] - 2019-08-27

- Use Docker exclusively to manage the dev environment
- Support multiple parent fields with `depends_on` in FDL
- Import FDL from the filesystem into the database
- Fix the database seed data to match current validation rules

## [release-85] - 2019-08-22

- Allow editing of definition for published frameworks
- [Security] Bump nokogiri from 1.10.3 to 1.10.4
- Remove support for loading framework definitions from filesystem. Validate the presence of a framework's definition source.

## [release-84] - 2019-08-19

- (chore) Copy filesystem FDL into the database
- (fix) Disable in2csv's type inference, as it can mis-infer
- (fix) Align development Python version with that of production
- Validate presence of salesforce_id on suppliers
- (chore) Amend the docs for getting production DB backups
- (fix) Don't use gzip when importing database backups
- (chore) Update the DB restoration docs to work on Docker
- (fix) Make db:restore work under Docker
- (chore) Update documentation for grabbing a database dump
- (chore) Fresh docker builds will provision node_module dependencies
- (chore) Only build the docker image for the codebase once
- (fix) Docker setup script treated as a shell file
- (chore) Add a pull request template for GitHub
- (chore) Update the default ENV variables

## [release-83] - 2019-08-02

- fix: A tool to allow us to resynchronise user details between the API's User table and the canonical source within Auth0, this will allow the recently onboarded users (added directly to auth0) to sign into the frontend and see their tasks
- chore: Docker uses the latest version of Yarn and commits `codemirror` to the lock file
- chore: when running as a container this application can be connected to by the frontend for data

## [release-82] - 2019-07-31

- Fix sanitisation of FDL that was causing `.` to be replaced with `_` in
  framework names
- Use `API_AUTH0` environment variable rather than `AUTH0`

## [release-81] - 2019-07-01

- Use GPaaS-compatible method for user to download their submissions
- FDL: Extra error reporting when creating new frameworks
- Update RM3786 and RM6060 frameworks

## [release-80] - 2019-06-20

- Revert JWT for API authentication. Fixes infinite redirect.

## [release-79] - 2019-06-19

- Fix/known field missing should be transpiler error
- Address CVE-2015-9284
- Allow admins to generate tasks for suppliers
- API expects a JSON Web Token for authentication

## [release-78] - 2019-06-10

- Remove erroneous optional fields from RM3756's FDL

## [release-77] - 2019-06-06

- Fix discrepancies in optional fields between FDL and the templates

## [release-76] - 2019-05-24

- FDL: Make fields used by management charge calculation mandatory
- Corrupted files halt ingest
- Rows that contain only white-space are skipped
- Submissions with missing columns halt ingest
- Admin: Late notifications exclude suppliers with no late tasks
- FDL: Make lots block mandatory, and move to above field defs
- Revert validation error message for blank fields

## [release-75] - 2019-05-23

- Bug: Bulk supplier import doesn't reject CSVs uploaded from Windows
- Admin: Bulk import users

## [release-74] - 2019-05-21

- Load frameworks from the database
- Ensure deleted scheduled jobs are removed from Redis
- FDL: Additional fields should allow 'depends_on' validation
- FDL: Use code editor when editing framework definitions
- Admin: Tasks show total and management charge
- Admin: Bulk import suppliers
- Admin: Update URN list

## [release-73] - 2019-05-14

- Use new ingest by default
- Allow admins to publish new frameworks
- Remove unused QueueSizeMetricJob
- Admin app shows and sorts frameworks by short_name

## [release-72] - 2019-05-08

- Make admin submission file downloads compatible with GPaaS
- Ingest fetches files using ActiveStorage, for GPaaS compatibility
- Use ROLLBAR_ENV instead of INFRASTRUCTURE_ENVIRONMENT
- Admin can add/edit framework template file

## [release-71] - 2019-04-30

- Prevent ingest from attempting to convert non-existent sheets
- Change daily data warehouse export to run at 22:30 London time
- Calculate management charge when all entries are valid
- Allow Sidekiq (background jobs) concurrency to be controlled independently

## [release-70] - 2019-04-29

- Allow FDL to validate blank Framework#name
- Explicitly call Rails.logger on Framework#update/create_from_fdl
- Prevent editing of published frameworks
- Add travis
- New Python + Ruby ingest implementation
- FDL validates the lack of an invoicevalue or contractvalue
- Replace Data Warehouse Export S3 upload with Azure
- New ingest can be enabled with an environment variable
- Send credit notes of greater than 5k as draft to workday
- Update Workday to support sandbox and production tenants

## [release-69] - 2019-04-24

- Upgrade to ruby 2.5.5
- Switch RMI to using FDL definitions instead of Ruby framework definitions
- Load ENV variables from VCAP services (GPAAS)
- Update bundler to 2.0.1
- Run brakeman in a separate process
- [Security] Bump nokogiri from 1.10.1 to 1.10.3
- Adding and editing FDL
- Delete Ruby versions of Framework Definitions

## [release-68] - 2019-04-11

- translate all existing frameworks to fdl
- GPAAS support for s3 buckets

## [release-67] - 2019-04-10

- Data migration to correct truncated Digital Marketplace Service IDs
- 'Digital Marketplace Service ID' should be exported to ProductCode
- Remove space in RM1043.5 `Invoice Date` export
- Fix exports_to: "Invoice Date"
- Configure Service Connection Environment variables for GPAAS
- Data migration to convert incorrect date formats to dd/mm/yyyy
- Rake task to allow us to re-export everything

## [release-66] - 2019-04-04

- Fix snags in RM3788 framework definition
- DependentFieldInclusionValidation is case insensitive
- Parse FDL framework short names with roman numerals
- Fix typo in RM1557vii / G Gloud 7
- Remove redundant guard on event

## [release-65] - 2019-04-03

- Prevent duplicate submission entries being saved in bulk request
- Fix validation snags in RM1557vii and RM3788
- Fix framework lot names for RM3767
- FDL: Prevent string values being coerced into integers
- BUG: Fix reversal invoice creation

## [release-64] - 2019-04-01

- Submission factories more accurately reflect reality
- Admin can edit supplier with blank CODA reference
- FDL: Support combining lookups
- Fix framework definitions to match Excel templates

## [release-63] - 2019-03-28

- Admin user can edit supplier details
- Fix a bug in 'Correct US date formats in submission entries'

## [release-62] - 2019-03-28

- Add data migration for importing March 2019 customers
- FDL: Support for Lot Number definitions
- Correct US date formats in submission entries
- Loosen Coda reference validation
- April Supplier onboarding
- Use FDL definition for RM6060

## [release-61] - 2019-03-27

- April onboarding part 1: add framework definitions to API
- Daily generation and upload of data warehouse export to S3
- FDL supports dependent field lookups
- Correct sidekiq_schedule.yml
- Add lots to new seeded frameworks
- Fixed bug: FDL <-> Original RB framework comparisons invalid
- FDL supports various field length validations
- Record correction submitter in Workday reversal invoice and reversal invoice adjustment

## [release-60] - 2019-03-25

- FDL: Add ContractFields class for RM3772
- Incomplete correction submission available to FE
- Incomplete correction can be cancelled
- FDL: Validators favour case-insensitive inclusion
- Admins can view submission errors

## [release-59] - 2019-03-20

- Rename two suppliers on RM1070 and RM1043.5
- FDL Management Charge support
- Customer sector-based management charge support
- 5c Data Warehouse is updated about replacement submissions

## [release-58] - 2019-03-14

- Bump rails from 5.2.1.1 to 5.2.2.1
- Reversal Invoice is submitted to Workday on a submission replaced by a correction
- Generate data warehouse exports incrementally

## [release-57] - 2019-03-13

- Refactored column-based management charge calculator
- Added Lookup (product-tables) support to FDL
- Added NULL constraint to protect against submissions without associated tasks
- Admin user can download CSV files for sending notifications via GOV.UK Notify

## [release-56] - 2019-03-12

- Supplier can correct a submission by uploading an MI return
- Configure `null_store` for caching in the test environment
- Use `active_submission` everywhere
- Update Task request spec to prevent intermittent failures
- Simplify Task#completed_or_latest_scope

## [release-55] - 2019-03-11

- Ensure completed submissions are always the active one.

## [release-54] - 2019-03-07

- Update overdue user notification CSV generation to match new GOV.UK Notify
  templates
- Added first version of Framework Definition Language (FDL) for defining
  frameworks, with CM/OSG/05/3565 fully defined

## [release-53] - 2019-03-07

- Updated management charge calculations for RM6060 (calculated against a
  column other than the total value)
- Update Google Oauth2 to new recommended endpoints (not Google+!)

## [release-52] - 2019-03-05

- Expose temporary_download_url on submission files

## [release-51] - 2019-03-04

- Data migration: update Customer (URN) list
- Generate CSV for monthly task notification emails
- Supplier can replace submission for no business

## [release-50] - 2019-02-28

- Onboarding of RM6060
- Updated API endpoint for tasks to expose extra data on the latest submission
- Re-instating January tasks for CM/OSG/05/3565
- Performance improvements to tasks#index (reduced n+1 queries)

## [release-49] - 2019-02-26

- Admin user can deactivate and activate suppliers on frameworks
- Added code to automate generation of the list of users with late tasks
- Updated API endpoints for replacing a return with a no-business return
- Simplified scheduling of monthly tasks
- Removed redundant dependent field validations
- Improved setup documentation

## [release-48] - 2019-02-20

- Supplier can view list of history of tasks
- Data migration: Delete 'test supplier' from prod

## [release-47] - 2019-02-19

- ActiveJob exceptions are sent to Rollbar
- Optimise memory usage on data warehouse exports
- Refactor creation of user to catch Auth0 exceptions more reliably

## [release-46] - 2019-02-14

- Clean up the admin application
- Being able to charge the correct management charge for RM858, RM3710
- RUN ON PRODUCTION: remove submissions without task and associated models,
this should have been released in release 45 but wasn't actually merged

## [release-45] - 2019-02-13

- Task list should show period_date
- RUN ON PRODUCTION: remove submissions without task and associated models
- RM858 and RM3710 changes to DW export
- Reinstate validations on remaining October frameworks (2/2)
- Users should be soft deleted
- Remove Docker configuration for local development
- Add developer strategy to API/omniauth so that development doesn't require Google auth setup per-developer

## [release-44] - 2019-02-11

- Admin app see status of submission
- Admin app download submission file

## [release-43] - 2019-02-07

- Reinstated validations on some October frameworks:
  - CM/OSG/05/3565
  - RM1031
  - RM1070
  - RM3710
  - RM3754
  - RM3767
- Send the submitter name to Workday
- Do not send an invoice to Workday if the total spend is 0
- Invoices are submitted to Workday in 'Approved State'
- Invoice Adjustments (invoices that have a negative management charge) are
  submitted to Workday as 'credit'
- Submit Revenue Category and Tax Code IDs to Workday
- Fixed a bug in the dependent field inclusion validator that meant some
  submissions were stuck processing if the dependent field or its parent field
  were missing

## [release-42] - 2019-01-31

- Added Workday invoice adjustment (AKA credit note) generation code
- Capture the user that creates submissions
- Capture the user that completes a submission
- Report created_by, submitted_by, and submitted_at for submissions to data
  warehouse
- Remove unnecessary AWS credentials from configuration
- Added Suppliers section to admin section
- Added product table validations

## [release-41] - 2019-01-24

- Added Workday invoice generation code
- Added new SubmissionInvoice model to storing reference for Workday invoices
- Switched to using IAM role on the container for AWS API authentication
- Fixed bug caused by double-clicking during submission

## [release-40] - 2019-01-14

- Lock scoping of user/task/submissions to current user
- Report background job queue size to AWS
- Update code linting library and configuration

## [release-39] - 2019-01-09

- Make the "no business" API endpoint idempotent
- Ensure the temporary generated password complies with the Auth0 criteria
- Ensure users do not get persisted without an Auth0 account
- Fix submission_stats rake task year bug
- Remove unused aws-sdk-lambda gem

## [release-38] - 2019-01-03

- Add skylight sidekiq support
- Use bulk SQL insertion to improve ingest performance

## [release-37] - 2018-12-20

- Add endpoint to allow bulk loading of submission entries to prevent the API
  server becoming swamped with requests from ingest
- Prevent admins from creating users with duplicate email addresses (with
  differing case)

## [release-36] - 2018-12-20

- Add rake task to create monthly tasks, triggered on schedule on AWS
- Add DATABASE_POOL_SIZE environment variable which controls the size of the
  database pool and Sidekiq's concurrency

## [release-35] - 2018-12-19

- Updates to admin layout and markup
- Enhanced validations for RM858 and RM3710
- RM1043.5 (DOS3) supplier onboarding

## [release-34] - 2018-12-17

- Add framework definition for RM1043.5 (aka DOS 3)
- Data migration to set lots and coda ref on DOS3
- Add Skylight
- Expose Sidekiq web UI

## [release-33] - 2018-12-12

- Added lots modelling and validation
- Added supplier search to user management
- Fixed a bug in user search that wouldn't show a user if they were not
  associated with a supplier
- Fixed a bug in user search where users would appear multiple times if they
  were associated with more than one supplier

## [release-32] - 2018-12-06

- Admin user can delete users
- Remove now-redundant submission entry endpoint from API

## [release-31] - 2018-12-04

- Update RM3710 to mark lease date fields as optional

## [release-30] - 2018-11-30

- Admin user can link/unlink users to/from suppliers
- Migrate validation rules from existing lambda implementation
- Add API endpoint to trigger validation
- Updated Customer URN list for November

## [release-29] - 2018-11-28

- Add the supplier name to the Task returned by the API
- Add a User endpoint to the API that shows a given user name, email and a boolean to show if the user has multiple suppliers
- Admin users can locate a supplier user
- [Security] Bump rails from 5.2.0 to 5.2.1.1
- Admin can create a new user

## [release-28] - 2018-11-26

- Secure sign in for support admin users
- Generate validation rules from MISO export

## [release-27] - 2018-11-20

- Expose a report_no_business property on submission in the API
- [Security] Bump rack from 2.0.5 to 2.0.6
- Update bulk user import process
- Ensure all memberships have a valid user

## [release-26] - 2018-11-13

- Include minus sign '-' in the whitelist
- Format decimal fields correctly in export

## [release-25] - 2018-11-12

- Bug fix: Strip invalid characters when extracting total_value

## [release-24] - 2018-11-08

- Include the management charge in the 'invoices' export
- Use AuthID and local users table to find tasks

## [release-23] - 2018-11-08

- Create background job for performing validations
- Add validation rules for RM1070
- Fix typo in RM3767 which prevented management charge calculation

## [release-22] - 2018-11-05

- Add User model
- Various cleanup

## [release-21] - 2018-10-30

- Rename "Publisher's Name" to "Publisher Name" in RM3797
- Data migration to add October customers
- Data migration for users with multiple suppliers
- Bump loofah from 2.2.2 to 2.2.3

## [release-20] - 2018-10-25

- Explicit link between SubmissionEntry and Customer
- Introduced sidekiq for performing background jobs
- Added Ruby-based management charge calculation

## [release-19] - 2018-10-16

- Submission entries now store "total value" as column on ingest
- Script to backfill total_value for existing submission entries
- Fixed case mismatch in RM3767
- Consistent formatting of dates in data warehouse export
- Data migration to add missing inactive customers
- Per-row management charge field and backfill script added
- Finance report updated to report based on per-row management charge
- Data warehouse export updated to report based on per-row management charge

## [release-18] - 2018-10-11

- data migration to back-full total_value for existing submission entries
- added framework definitions for all October frameworks
- add management charge rate on framework definitions
- exports and finance report contain correct management charge rate
- corrected framework identifier reporting in tasks export
- Suppliers now have a salesforce_id

## [release-17] - 2018-10-09

- Include submission purchase order number in finance export
- Make 'total_value' a first class attribute of SubmissionEntry
- Made temporary code for reporting spend and management charge into a rake
    task
- Fixed issue that was stopping '£' to be typed into the Docker console

## [release-16] - 2018-10-08

- Reduce logging in production environments
- Updated dependency with security fixes
- Established framework definition mappings
- Added helper code for debugging submissions and reporting submission stats

## [release-15] - 2018-10-03

- Ignore duplicate entries sent by ingest lambda
- Added rake task to export contracts
- Remove spaces in "Customer Reference Number" in export

## [release-14] - 2018-10-01

- Data migration to import non-Active customers to database
- Temporary bypass of broken management charge calculation to avoid blocking
  user submission
- Fix bug that was resulting in submissions transitioning before ingest and
  validation had completed.

## [release-13] - 2018-09-27

- Updated Customer URN list for October
- Added data migration to seed agreements for October suppliers
- Added code to generate tasks for September submissions

## [release-12] - 2018-09-26

- Performance enhancements to data warehouse export script
- Data migrations to onboard October frameworks and suppliers
- Added invoices to data warehouse export

## [release-11] - 2018-09-25

- Optimise Submission endpoint by no longer returning all entries
- Added fetching of validation errors. This returns at most ten
    errors, ordered by source row number
- Added scripts for exporting submissions

## [release-10] - 2018-09-19

- Adjusted terraform config for zero-downtime deploys

## [release-9] - 2018-09-18

- Removed redundant calculate action
- Added support for setting a purchase order number on submissions
- Submissions now include a count of their invoices and orders
- Renamed "levy" to "management charge"

## [release-8] - 2018-09-13

- Introduce new "validation_failed" state to submissions
- Added first exporter for data warehouse export: tasks
- Enhanced submission entries to make identifying their type easier

## [release-7] - 2018-08-23

- Added script to generate tasks for September 2018

## [release-6] - 2018-08-22

- Add endpoint to set submission file upload information

## [release-5] - 2018-08-15

- Update URN list

## [release-4] - 2018-08-13

- Finance report includes submission ID in RunID column
- Finance report rounds levy calculations down

## [release-3] - 2018-08-09

- Added exception monitoring and reporting
- Updated dependent libraries
- Added code to generate Coda finance reports

## [release-2] - 2018-08-08

- Added coda_reference to Framework model
- Added coda_reference to Submission model
- Introduced Customer model

## [release-1] - 2018-07-31

Initial release

[release-98]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-97...release-98
[release-97]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-96...release-97
[release-96]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-95...release-96
[release-95]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-94...release-95
[release-94]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-93...release-94
[release-93]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-92...release-93
[release-92]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-91...release-92
[release-91]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-90...release-91
[release-90]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-89...release-90
[release-89]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-88...release-89
[release-88]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-87...release-88
[release-87]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-86...release-87
[release-86]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-85...release-86
[release-85]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-84...release-85
[release-84]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-83...release-84
[release-83]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-82...release-83
[release-82]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-81...release-82
[release-81]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-80...release-81
[release-80]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-79...release-80
[release-79]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-78...release-79
[release-78]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-77...release-78
[release-77]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-76...release-77
[release-76]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-75...release-76
[release-75]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-74...release-75
[release-74]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-73...release-74
[release-73]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-72...release-73
[release-72]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-71...release-72
[release-71]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-70...release-71
[release-70]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-69...release-70
[release-69]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-68...release-69
[release-68]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-67...release-68
[release-67]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-66...release-67
[release-66]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-65...release-66
[release-65]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-64...release-65
[release-64]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-63...release-64
[release-63]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-62...release-63
[release-62]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-61...release-62
[release-61]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-60...release-61
[release-60]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-59...release-60
[release-59]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-58...release-59
[release-58]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-57...release-58
[release-57]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-56...release-57
[release-56]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-55...release-56
[release-55]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-54...release-55
[release-54]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-53...release-54
[release-53]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-52...release-53
[release-52]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-51...release-52
[release-51]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-50...release-51
[release-50]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-49...release-50
[release-49]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-48...release-49
[release-48]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-47...release-48
[release-47]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-46...release-47
[release-46]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-45...release-46
[release-45]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-44...release-45
[release-44]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-43...release-44
[release-43]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-42...release-43
[release-42]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-41...release-42
[release-41]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-40...release-41
[release-40]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-39...release-40
[release-39]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-38...release-39
[release-38]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-37...release-38
[release-37]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-36...release-37
[release-36]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-35...release-36
[release-35]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-34...release-35
[release-34]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-33...release-34
[release-33]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-32...release-33
[release-32]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-31...release-32
[release-31]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-30...release-31
[release-30]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-29...release-30
[release-29]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-28...release-29
[release-28]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-27...release-28
[release-27]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-26...release-27
[release-26]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-25...release-26
[release-25]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-24...release-25
[release-24]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-23...release-24
[release-23]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-22...release-23
[release-22]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-21...release-22
[release-21]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-20...release-21
[release-20]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-19...release-20
[release-19]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-18...release-19
[release-18]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-17...release-18
[release-17]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-16...release-17
[release-16]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-15...release-16
[release-15]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-14...release-15
[release-14]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-13...release-14
