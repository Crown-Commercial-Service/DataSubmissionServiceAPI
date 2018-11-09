require 'progress_bar'

Framework.all.find_each do |framework|
  puts framework.short_name

  total_value_field = framework.definition::Invoice.total_value_field

  entries = SubmissionEntry
            .validated
            .invoices
            .where(
              "submission_entries.total_value <> \
               TRANSLATE(submission_entries.data->>'#{total_value_field}', '$£ ,', '')::decimal"
            )
            .joins(submission: :framework)
            .merge(Framework.where(short_name: framework.short_name))

  bar = ProgressBar.new(entries.count)

  entries.find_each do |entry|
    total_value = BigDecimal(entry.data[total_value_field].tr('$£, ', ''))
    management_charge = framework.definition.management_charge(total_value)

    entry.update!(total_value: total_value, management_charge: management_charge)
    bar.increment!
  end
end
