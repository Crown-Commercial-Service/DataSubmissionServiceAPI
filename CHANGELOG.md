# Change Log

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


[release-18]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-17...release-18
[release-17]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-16...release-17
[release-16]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-15...release-16
[release-15]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-14...release-15
[release-14]: https://github.com/dxw/DataSubmissionServiceAPI/compare/release-13...release-14
