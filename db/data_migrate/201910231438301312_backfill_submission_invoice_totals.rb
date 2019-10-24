# The problem:
#
# Viewing the supplier view for a supplier with many submissions and a large number of entries
# would bring the site to a crawl calculating totals on the fly. We will calculate invoice_total
# at ingest time, but we need to backfill existing values.
#
# Backfill all of submissions.invoice_total for completed and in_review submissions.
#
# Run on a 15 Oct 2019 morning production cut this would UPDATE 12676 submissions
#
# rails runner db/data_migrate/201910231438301312_backfill_submission_invoice_totals.rb
ActiveRecord::Base.connection.execute(
  <<~POSTGRESQL
    UPDATE submissions
    SET invoice_total = invoice_totals.total
    FROM (
             SELECT s.id AS submission_id, SUM(se.total_value) as total
             FROM submissions s
               INNER JOIN submission_entries se on s.id = se.submission_id AND se.entry_type = 'invoice'
             GROUP BY s.id
             HAVING SUM(se.total_value) IS NOT NULL
         ) AS invoice_totals
    WHERE submissions.id = invoice_totals.submission_id
  POSTGRESQL
)
