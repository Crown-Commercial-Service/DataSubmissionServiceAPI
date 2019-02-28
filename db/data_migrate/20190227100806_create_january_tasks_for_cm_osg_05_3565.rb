framework = Framework.find_by(short_name: 'CM/OSG/05/3565')
period_month = 1
period_year = 2019
due_date = Date.new(2019, 2, 7)

puts 'Creating tasks January tasks for CM/OSG/05/3565'

agreements = Agreement.active.includes(:supplier).where(framework: framework)

agreements.find_each do |agreement|
  supplier = agreement.supplier

  puts "\tCreating for supplier #{supplier.name}"
  Task.create!(
    framework: framework,
    supplier: supplier,
    period_month: period_month,
    period_year: period_year,
    due_on: due_date
  )
end
