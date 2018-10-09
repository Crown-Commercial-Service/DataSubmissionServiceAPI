# Execute with:
#
#   rails runner db/data_migrate/20181009114237_backfill_submission_entry_total_value.rb
#
# This is a fixed query to fill in submission_entries.total_value for Sep/Oct frameworks.
# The COALESCE list is the list of total value fields (mostly with casing variations)
# taken from data/framework_miso_fields.csv on 2018-10-09 using
#
# [2] pry(main)> require 'csv'; csv  = CSV.read(Framework::MisoFields::FILENAME, headers: true)
# => #<CSV::Table mode:col_or_row row_count:439>
# [3] pry(main)> csv.select \
#   {|r| %w(InvoiceValue ContractValue).include?(r['ExportsTo'])}.map {|r| r['DisplayName']}.uniq
#
# We *could* have this query autogenerate from existing Framework::Definitions, but it's my last day
# and I still need to retrofit the values this query provides to the Submissions export.
#
# If you see a SubmissionEntry.backfill_total_value symbol anywhere else, use that instead,
# as it'll deal with non-Sep/Oct frameworks should you need to. If you don't then this is
# a one-off query with a shelf life. The ingest will be filling in these values once
# https://trello.com/c/BWrGjzFd/483-the-ingest-process-sets-the-total-value-attribute-based-on-the-framework
# is done, so this query will then be unnecessary.
ActiveRecord::Base.connection.execute(
  <<~POSTGRESQL
    UPDATE submission_entries
    SET total_value =
      translate(
        COALESCE(
            data ->> 'Total Cost (ex VAT)',
            data ->> 'Total Charges (ex VAT)',
            data ->> 'Total Spend',
            data ->> 'Invoice Line Total Value ex VAT',
            data ->> 'Invoice Line Total Value ex VAT and Expenses',
            data ->> 'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT',
            data ->> 'Total Charge (Ex VAT)',
            data ->> 'Customer Order/Contract Value',
            data ->> 'Total Charge (ex VAT)',
            data ->> 'Total Cost (Ex VAT)',
            data ->> 'Total Cost (ex VAT)',
            /*
             The below lines were filling in errored rows; I'm not sure they should, which is why they're commented
             out, but by all means comment them back in if you want these values in the submissions report.
             I haven't looked into whether or not they failed *because* value was missing – if that was the
             reason then it's probably more correct to have the values.
            */
    --         data ->> 'Total Charge (ex VAT)',   /* casing variation, not in the miso fields, Vehicle Telematics RM3754 */
    --         data ->> ' Total Charge (Ex VAT) ', /* Typo'd version of the miso fields for RM3710, ~9K errored rows; */
    --         data ->> ' Total Cost (ex VAT) ',   /* Not in the miso fields; General Legal Advice RM3786, ~300 errored rows  */
            (CASE data ->> 'Expected Total Order Value'
              -- Cope with known bad values, fill in the rest
              WHEN 'TBC' THEN NULL
              WHEN 'unknown' THEN NULL
              WHEN 'Estimate of charges not used' THEN NULL
              ELSE data ->> 'Expected Total Order Value'
            END)
        ), '£ ,', ''
      ) :: decimal;
POSTGRESQL
)
