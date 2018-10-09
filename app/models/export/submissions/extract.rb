module Export
  class Submissions
    module Extract
      RELEVANT_STATUSES = %w[completed validation_failed].freeze

      def self.all_relevant
        Submission.select(
          <<~POSTGRESQL
            submissions.*,
            orders.total_value                AS _total_order_value,
            COALESCE(orders.entry_count, 0)   AS _order_entry_count,
            invoices.total_value              AS _total_invoice_value,
            COALESCE(invoices.entry_count, 0) AS _invoice_entry_count,
            MIN(blobs.filename) :: text       AS _first_filename
          POSTGRESQL
        ).joins(
          <<~POSTGRESQL
            LEFT JOIN (SELECT
                         submission_id,
                         SUM(total_value) AS total_value,
                         COUNT(*)         AS entry_count
                       FROM submission_entries
                       WHERE entry_type = 'order'
                       GROUP BY submission_id) AS orders ON orders.submission_id = submissions.id
            LEFT JOIN (SELECT
                         submission_id,
                         SUM(total_value) AS total_value,
                         COUNT(*)         AS entry_count
                       FROM submission_entries
                       WHERE entry_type = 'invoice'
                       GROUP BY submission_id) AS invoices ON invoices.submission_id = submissions.id
            LEFT JOIN submission_files ON submission_files.submission_id = submissions.id
            LEFT JOIN active_storage_attachments att
              ON (att.record_type = 'SubmissionFile' AND att.record_id = submission_files.id)
            LEFT JOIN active_storage_blobs blobs ON blobs.id = att.blob_id
        POSTGRESQL
        ).where(
          aasm_state: RELEVANT_STATUSES
        ).group(
          'submissions.id, orders.total_value, invoices.total_value,'\
          'orders.entry_count, invoices.entry_count'
        )
      end
    end
  end
end
