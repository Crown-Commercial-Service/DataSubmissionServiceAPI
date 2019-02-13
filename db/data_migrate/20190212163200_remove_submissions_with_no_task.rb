# - Remove submission `c06c10ed-ae0c-40ee-b8ee-e8287e4882ab` (supplier was the last person
#   submitting on CM/OSG/05/3565, which has been retired).
# - Remove submission `628ac96c-2c8d-4beb-b4ff-b3fc185b739e` (supplier has been removed from
#   DOS3, and therefore the associated task was deleted).
#
# Execute with:
#
#   rails runner db/data_migrate/20190212163200_remove_submissions_with_no_task.rb
#

RETIRED_FRAMEWORK_SUBMISSION = 'c06c10ed-ae0c-40ee-b8ee-e8287e4882ab'.freeze
ERRONEOUS_DOS3_SUBMISSION    = '628ac96c-2c8d-4beb-b4ff-b3fc185b739e'.freeze

Submission.delete(RETIRED_FRAMEWORK_SUBMISSION)

# Be explicit about deleting relations first
SubmissionEntry.where(submission_id: ERRONEOUS_DOS3_SUBMISSION).each(&:delete)
SubmissionFile.where(submission_id:  ERRONEOUS_DOS3_SUBMISSION).each(&:delete)

Submission.delete(ERRONEOUS_DOS3_SUBMISSION)
