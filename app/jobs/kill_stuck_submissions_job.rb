##
# Checks for stuck submissions in 'processing' longer than 24hrs.
# These submissions are collated into array 'submissions_stuck'. If non-empty, this array is then looped
# through to update them as 'failed' (in a database query), to then be resubmitted by a supplier (or not).
#
class KillStuckSubmissionsJob < ApplicationJob
  def perform
    # rubocop:disable Metrics/LineLength
    submissions_stuck = Submission.joins(:task).where("aasm_state = 'processing' and submissions.updated_at < ? and tasks.status != 'completed'", Time.zone.now - 1.day)
    # rubocop:enable Metrics/LineLength
    submissions_stuck.each { |s| s.update!(aasm_state: :ingest_failed) } if submissions_stuck.length.positive?
  end
end
