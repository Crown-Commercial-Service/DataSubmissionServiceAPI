module Export
  class Submissions
    module Extract
      RELEVANT_STATUSES = %w[completed validation_failed replaced].freeze

      def self.all_relevant(date_range = nil)
        filters = { aasm_state: RELEVANT_STATUSES }
        filters = filters.merge(updated_at: date_range) if date_range.present?

        Submission.select(
          <<~POSTGRESQL
            submissions.*,
            submissions.invoice_total         AS _invoice_total,
            frameworks.short_name             AS _framework_short_name,
            orders.total_value                AS _total_order_value,
            COALESCE(orders.entry_count, 0)   AS _order_entry_count,
            MIN(blobs.filename) :: text       AS _first_filename
          POSTGRESQL
        ).joins(
          <<~POSTGRESQL
            LEFT JOIN frameworks ON frameworks.id = submissions.framework_id
            LEFT JOIN (SELECT
                         submission_id,
                         SUM(total_value) AS total_value,
                         COUNT(*)         AS entry_count
                       FROM submission_entries_stages
                       WHERE entry_type = 'order'
                       GROUP BY submission_id) AS orders ON orders.submission_id = submissions.id
            LEFT JOIN submission_files ON submission_files.submission_id = submissions.id
            LEFT JOIN active_storage_attachments att
              ON (att.record_type = 'SubmissionFile' AND att.record_id = submission_files.id)
            LEFT JOIN active_storage_blobs blobs ON blobs.id = att.blob_id
        POSTGRESQL
        ).where(
          filters
        ).group(
          'submissions.id, frameworks.short_name, orders.total_value ,'\
          'orders.entry_count'
        )
      end
    end
  end
end
