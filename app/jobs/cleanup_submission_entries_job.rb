class CleanupSubmissionEntriesJob < ApplicationJob
  ENTRIES_BATCH_SIZE = 1000

  def perform(dry_run: false, max_run_time: 5.hours, task_batch_sixe: 100)
    start_time = Time.current
    total_deleted_entries = 0

    tasks_with_unprocessed_submissions = Task.joins(:submissions)
                                             .where(submissions: { aasm_state: 'validation_failed', cleanup_processed: false })
                                             .distinct

    tasks_with_unprocessed_submissions.find_in_batches(batch_size: task_batch_sixe) do |tasks_batch|
      tasks_batch.each do |task|
        active_id = task.active_submission&.id

        failed_submissions = task.submissions
                                 .where(aasm_state: 'validation_failed', cleanup_processed: false)
                                 .where.not(id: active_id)

        next if failed_submissions.empty?

        deleted_for_task = 0

        failed_submissions.find_each do |submission|
          begin
            submission.entries.in_batches(of: ENTRIES_BATCH_SIZE) do |entries_batch|
              if dry_run
                Rollbar.info("Dry run: would delete #{entries_batch.count} entries for Submission ID #{submission.id}.")
              else
                deleted_count = entries_batch.delete_all
                deleted_for_task += deleted_count
                total_deleted_entries += deleted_count
                # rubocop:disable Layout/LineLength
                Rollbar.info("Task ID #{task.id}: Processed #{failed_submissions.count} failed submissions, deleted #{deleted_for_task} entries.")
                # rubocop:enable Layout/LineLength
              end
            end

            submission.update(cleanup_processed: true) unless dry_run
          rescue => e
            Rollbar.error(e, "Error processing Submission ID #{submission.id} for Task ID #{task.id}: #{e.message}")
          end

          break if Time.current - start_time >= max_run_time
        end
      end

      break if Time.current - start_time >= max_run_time
      sleep 1 # To avoid overwhelming the database
    end
  end
end
