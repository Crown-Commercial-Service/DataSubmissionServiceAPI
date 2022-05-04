# Sets the submission_entries#customer_urn attribute for all validated entries
# based on the value in the data hash.
#
# Execute with:
#
#   rails runner db/data_migrate/20181018085548_backfill_submission_entry_customer_urn.rb
#
ActiveRecord::Base.connection.execute(
  <<~POSTGRESQL
    UPDATE submission_entries_stages
    SET customer_urn = (data ->> 'Customer URN')::int
    WHERE submission_entries_stages.aasm_state = 'validated';
  POSTGRESQL
)
