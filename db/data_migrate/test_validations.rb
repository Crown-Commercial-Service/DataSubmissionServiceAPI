f = File.new('/tmp/report.csv', 'w')
f.write "framework,entry_id,state,data,old_errors,new_errors\n"

Framework.all.find_each do |framework|
  print framework.short_name.to_s

  framework_definition = framework.definition
  entries = SubmissionEntry
            .joins(submission: :framework)
            .merge(Submission.where(created_at: (1.month.ago..0.months.ago)))
            .merge(Framework.where(id: framework.id))
            .limit(250)

  entries.find_each do |entry|
    entry_data_definition = framework_definition.for_entry_type(entry.entry_type)
    entry_data = entry_data_definition.new(entry)
    entry_data.validate

    print '.'

    unless entry.aasm_state == 'validated' && entry_data.valid?
      data = entry_data.attributes.select { |k, _v| entry_data.errors.key?(k) }.map { |k, v| "#{k} => #{v}" }.join("\n")
      old_errs = entry.validation_errors.to_a.map { |error| error.fetch('message', '') }.compact.join("\n")
      new_errs = entry_data.errors.full_messages.join("\n")

      f.write "#{framework.short_name},#{entry.id},#{entry.aasm_state},\"#{data}\",\"#{old_errs}\",\"#{new_errs}\"\n"
    end
  rescue NameError => e
    print e.message
  end

  puts
end

f.close
