module Export
  class Submissions
    module Extract
      RELEVANT_STATUSES = %w[completed validation_failed].freeze

      def self.all_relevant
        Submission.select('submissions.*,' \
                          'COUNT(DISTINCT orders) AS _order_entry_count,' \
                          'COUNT(DISTINCT invoices) AS _invoice_entry_count')
                  .joins('LEFT JOIN submission_entries orders ON ' \
                         "(orders.submission_id = submissions.id AND orders.entry_type = 'order')")
                  .joins('LEFT JOIN submission_entries invoices ON '\
                         "(invoices.submission_id = submissions.id AND invoices.entry_type = 'invoice')")
                  .where(aasm_state: RELEVANT_STATUSES)
                  .group('submissions.id') # Postgres lazy group can use ID only
      end
    end
  end
end
