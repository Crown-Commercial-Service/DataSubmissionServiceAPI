namespace :submissions do
  desc 'Delete old submission_entries for replaced validation_failed submissions'
  task cleanup_old_failed_entries: :environment do
    task_batch_size = 100
    entries_batch_size = 1000

    total_deleted_entries = 0

    Task.find_in_batches(batch_size: task_batch_size) do |tasks|
      tasks.each do |task|
        # Find failed submissions that are not the latest or completed submission for this task
        failed_submissions = task.submissions
                                 .where(aasm_state: 'validation_failed')
                                 .where.not(id: task.active_submission.select(:id))

        next if failed_submissions.empty?

        failed_submissions.find_each do |submission|
          submission.entries.in_batches(of: entries_batch_size) do |entries_batch|
            deleted_count = entries_batch.delete_all
            total_deleted_entries += deleted_count
          end
        end

        puts "Task ID: #{task.id}: processed #{failed_submissions.count} failed submissions"
      end

      sleep 1 # To avoid overwhelming the database
    end

    puts "Cleanup complete. Total deleted submission_entries: #{total_deleted_entries}"
  end
end
