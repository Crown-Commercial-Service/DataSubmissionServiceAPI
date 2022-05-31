# https://dxw.zendesk.com/agent/tickets/10151
#
# The problem:
#
# Viewing the supplier view for a supplier with many submissions and a large number of entries
# would bring the site to a crawl calculating totals on the fly. A previous PR fixed this
# by pre-calculating submissions.management_charge_total on first usage, but this is still not ideal:
#
# https://github.com/dxw/DataSubmissionServiceAPI/pull/533
#
# Backfill all of submissions.management_charge_total for completed and in_review submissions.
#
# Run on a 15 Oct 2019 morning production cut this will update 19803 records
# leaving 13154 submissions with a management_charge_total
#
# rails runner db/data_migrate/201910151438301312_backfill_submission_management_charges.rb
ActiveRecord::Base.connection.execute(
  <<~POSTGRESQL
    UPDATE submissions SET management_charge_total = charge_totals.total
    FROM (
             SELECT submission_id, SUM(management_charge) AS total
             FROM submission_entries_stages
             GROUP BY submission_id
         ) AS charge_totals
    WHERE submissions.id = charge_totals.submission_id
    AND submissions.aasm_state IN ('completed', 'in_review')
  POSTGRESQL
)
