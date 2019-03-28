require 'progress_bar'
require 'string_utils'

puts 'Fixing submission entries...'

affected_submission_ids = SubmissionEntry
                          .validated
                          .distinct
                          .select(:submission_id)
                          .joins(:submission)
                          .where(
                            "(LENGTH(data->>'Customer Invoice Date') IN (6,7,8) " \
                            "OR LENGTH(data->>'Customer Invoice/Credit Note Date') IN (6,7,8))"
                          )
                          .where.not(submissions: { aasm_state: 'validation_failed' })
                          .pluck(:submission_id)

bar = ProgressBar.new(affected_submission_ids.count)

affected_submission_ids.each do |submission_id|
  submission_entries = SubmissionEntry
                       .where(submission_id: submission_id)

  target_fields = submission_entries.flat_map do |entry|
    entry.data.keys.select { |k| k.match?(/Date/) }
  end.compact.uniq

  dates_in_submission = submission_entries.flat_map do |entry|
    entry.data.select { |k, v| k.match?(/Date/) && v.size > 5 && v.size < 9 }.values
  end.compact.uniq

  # Detect date format
  first_component_maybe_day = dates_in_submission.any? { |date| date.split('/')[0].to_i > 12 }
  second_component_maybe_day = dates_in_submission.any? { |date| date.split('/')[1].to_i > 12 }

  input_format = if (first_component_maybe_day && second_component_maybe_day) ||
                    (!first_component_maybe_day && !second_component_maybe_day)
                   :unknown
                 elsif first_component_maybe_day
                   '%d/%m/%y'
                 else
                   '%m/%d/%y'
                 end

  if input_format == :unknown
    Rails.logger.info "Could not determine correct date format for submission ##{submission_id}"
    bar.increment!
    next
  end

  # Update data hash
  SubmissionEntry.transaction do
    submission_entries.find_each do |entry|
      target_fields.each do |field|
        next if entry.data[field].nil?
        next if entry.data[field].to_s.size == 10

        entry.data[field] = Date.strptime(entry.data[field].to_s, input_format).strftime('%d/%m/%Y')
      rescue ArgumentError
        Rails.logger.warn "Unexpected date format found in entry ##{entry.id}. Rolling back ##{submission_id}"
        raise ActiveRecord::Rollback
      end

      # rubocop:disable Rails/SkipsModelValidations
      entry.update_column(:data, entry.data)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  bar.increment!
end
