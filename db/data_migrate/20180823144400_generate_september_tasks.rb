agreements = Agreement.all

puts 'Generating tasks...'

agreements.each do |agreement|
  next if Task.exists?(
    framework: agreement.framework,
    supplier: agreement.supplier,
    period_month: 8,
    period_year: 2018
  )

  task = Task.new
  task.framework = agreement.framework
  task.supplier = agreement.supplier
  task.due_on = '2018-09-07'
  task.period_month = 8
  task.period_year = 2018
  task.description = "Report MI for August 2018 for #{agreement.framework.name} (#{agreement.framework.short_name})"
  task.save!
end
