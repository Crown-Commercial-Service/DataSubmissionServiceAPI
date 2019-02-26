# Change Log

## [release-49] - 2019-02-26

- Admin user can deactivate and activate suppliers on frameworks
- Added code to automate generation of users with late tasks list
- Updated API endpoints for replacing a return with a no-business return
- Simplified scheduling of monthly tasks
- Removed redundant depedent field validations
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
