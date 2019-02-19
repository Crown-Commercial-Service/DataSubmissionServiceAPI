module Export
  class Contracts
    module Extract
      def self.all_relevant
        SubmissionEntry.orders
                       .select('submission_entries.*, frameworks.short_name AS _framework_short_name')
                       .joins(submission: :framework)
                       .merge(Submission.completed)
      end
    end
  end
end
