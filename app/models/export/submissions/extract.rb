module Export
  class Submissions
    module Extract
      RELEVANT_STATUSES = %w[completed validation_failed].freeze

      def self.all_relevant
        Submission.select('submissions.*,' \
                          'COUNT(DISTINCT orders.id) AS _order_entry_count,' \
                          'COUNT(DISTINCT invoices.id) AS _invoice_entry_count,' \
                          'MIN(blobs.filename)::text AS _first_filename')
                  .joins('LEFT JOIN submission_entries orders ON ' \
                         "(orders.submission_id = submissions.id AND orders.entry_type = 'order')")
                  .joins('LEFT JOIN submission_entries invoices ON '\
                         "(invoices.submission_id = submissions.id AND invoices.entry_type = 'invoice')")
                  .joins('LEFT JOIN submission_files ON submission_files.submission_id = submissions.id')
                  .joins('LEFT JOIN active_storage_attachments att ON ' \
                         "(att.record_type = 'SubmissionFile' AND att.record_id = submission_files.id)")
                  .joins('LEFT JOIN active_storage_blobs blobs ON blobs.id = att.blob_id')
                  .where(aasm_state: RELEVANT_STATUSES)
                  .group('submissions.id') # Postgres lazy group can use ID only
      end
    end
  end
end
