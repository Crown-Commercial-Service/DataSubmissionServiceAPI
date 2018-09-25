module Export
  class Invoices
    module Extract
      def self.all_relevant
        SubmissionEntry.invoices
                       .select('submission_entries.*, frameworks.short_name AS _framework_short_name')
                       .joins(submission: :framework)
                       .merge(Submission.completed)
                       .order(:created_at)
      end
    end
  end
end

