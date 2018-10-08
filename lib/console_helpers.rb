# Helper methods that are automatically included in the rails console to aid in
# debugging and reporting whilst we are without an administrative interface.
module ConsoleHelpers
  # Outputs some useful information on a given submission. Helpful to get an
  # overview of the state of the submission when debugging one that might be stuck.
  def inspect_submission(submission)
    Rails.logger.silence do
      submission.reload
      STDERR.puts "\n"
      STDERR.puts "URL: /tasks/#{submission.task_id}/submissions/#{submission.id}"
      STDERR.puts "Created #{submission.created_at}"
      STDERR.puts "Submission (#{submission.aasm_state}) #{submission.id}"
      STDERR.puts "Task (#{submission.task.status}) #{submission.task_id}"
      STDERR.puts "File rows: #{submission.files.first.rows}"
      STDERR.puts "Entries:   #{submission.entries.count}"
      STDERR.puts submission.entries.group(:aasm_state).count(:aasm_state)
      STDERR.puts "\n"
    end
  end
end
