class CleanupSubmissionEntriesJob < ApplicationJob
  retry_on ActiveRecord::Deadlocked, wait: :exponentially_longer, attempts: 8
  retry_on PG::TRDeadlockDetected, wait: :exponentially_longer, attempts: 8

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def perform(dry_run: false, max_run_time: 5.hours, task_batch_size: 100, entries_batch_size: 500)
    start_time = Time.current
    total_deleted_entries = 0

    tasks_with_unprocessed_submissions = Task.joins(:submissions)
                                             .where(submissions: { aasm_state: 'validation_failed',
cleanup_processed: false })
                                             .distinct

    tasks_with_unprocessed_submissions.find_in_batches(batch_size: task_batch_size) do |tasks_batch|
      tasks_batch.each do |task|
        active_id = task.active_submission&.id
        latest_id = task.latest_submission&.id

        failed_submissions = task.submissions
                                 .where(aasm_state: 'validation_failed', cleanup_processed: false)
                                 .where.not(id: active_id)
                                 .where.not(id: latest_id)

        next if failed_submissions.empty?

        deleted_for_task = 0

        failed_submissions.find_each do |submission|
          begin
            break if Time.current - start_time >= max_run_time

            Submission.transaction do
              submission.lock!

              if dry_run
                entries_count = submission.entries.count
                staging_entries_count = submission.staging_entries.count
                Rollbar.info("Dry run: would delete #{entries_count + staging_entries_count} entries for Submission ID #{submission.id}.")
              else
                deleted_entries = 0
                deleted_staging_entries = 0

                submission.entries.in_batches(of: entries_batch_size) do |entries_batch|
                  deleted_entries += entries_batch.delete_all
                end

                submission.staging_entries.in_batches(of: entries_batch_size) do |staging_entries_batch|
                  deleted_staging_entries += staging_entries_batch.delete_all
                end

                submission.update!(cleanup_processed: true)

                Rollbar.info("Task ID #{task.id}: Processed Submission ID #{submission.id}, deleted #{deleted_entries + deleted_staging_entries} entries.")
              end
            end
          rescue StandardError => e
            Rollbar.error(e, "Error processing Submission ID #{submission.id} for Task ID #{task.id}: #{e.message}")
          end
        end
      end

      break if Time.current - start_time >= max_run_time

      sleep 1 # To avoid overwhelming the database
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
