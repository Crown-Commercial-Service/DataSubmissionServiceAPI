module Export
  class Submissions
    module Extract
      RELEVANT_STATUSES = %w[completed validation_failed].freeze

      def self.all_relevant
        Submission.where(aasm_state: RELEVANT_STATUSES)
      end
    end
  end
end
