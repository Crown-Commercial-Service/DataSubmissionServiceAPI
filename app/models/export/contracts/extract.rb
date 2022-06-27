module Export
  class Contracts
    module Extract
      def self.all_relevant(date_range = nil)
        submission_scope = Submission.completed
        submission_scope = submission_scope.where(updated_at: date_range) if date_range.present?

        SubmissionEntry.orders
                       .select('submission_entries.*, frameworks.short_name AS _framework_short_name')
                       .joins(submission: :framework)
                       .merge(submission_scope)
      end
    end
  end
end
