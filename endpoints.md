# API Endpoints

## Agreements

NB: Agreements link a supplier to a framework

 * `POST /v1/agreements?framework_id=...&supplier_id=...` - Create an agreement

## Events (audit log)

 * `POST /v1/events/user_signed_in?user_id=...` - Create an `UserSignedIn`
     event in the audit log for the given user
 * `POST /v1/events/user_signed_out?user_id=...` - Create an `UserSignedOut`
     event in the audit log for the given user

## Frameworks

 * `GET /v1/frameworks` - Get all frameworks
 * `GET /v1/frameworks/:framework_id` - Get details of a single framework

## Suppliers

 * `GET /v1/suppliers` - Get all suppliers
 * `GET /v1/suppliers/:supplier_id` - Get details of a single supplier

## Submissions

 * `POST /v1/submissions` - Create a new submission and returns its
     `submission_id` to use below

### Files

 * `POST /v1/submissions/:submission_id/files` - Create a new file, associated
     with a submission (returns the id of the created file)

### Entries

NB: An `entry` is an individual row of data for a return

 * `POST /v1/submissions/:submission_id/entries` - Create a new entry, associated
     with a submission
 * `POST /v1/files/:file_id/entries` - Create a new entry, associated with a
     file (which in turn is associated to a submission)

## Tasks

 * `GET /v1/tasks` - Get all tasks
 * `POST /v1/tasks` - Create a new task
 * `POST /v1/tasks/:task_id/complete` - Mark the given task as complete
