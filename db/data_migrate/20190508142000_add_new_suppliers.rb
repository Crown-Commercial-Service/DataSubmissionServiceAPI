ActiveRecord::Base.transaction do
  # Suppliers
  post_office_ltd = Supplier.create!(name: 'Post Office Ltd', salesforce_id: 'a0o0N00000G8B5HQAV')
  platform_sh_ltd = Supplier.find('0b7c8e1f-b1a8-43f8-8c00-83d11cc9e7a1')

  # Frameworks
  gcloud9 = Framework.find_by(short_name: 'RM1557ix')
  gcloud10 = Framework.find_by(short_name: 'RM1557.10')

  # Assign suppliers to frameworks
  post_office_ltd.agreements.create!(framework: gcloud10)
  platform_sh_ltd.agreements.create!(framework: gcloud9)

  # Framework lots
  gcloud9_lot1 = FrameworkLot.find_by(framework: gcloud9, number: '1')
  gcloud10_lot2 = FrameworkLot.find_by(framework: gcloud10, number: '2')

  # Assign suppliers to framework lots
  post_office_ltd.agreement_for_framework(gcloud10).agreement_framework_lots.create!(framework_lot: gcloud10_lot2)
  platform_sh_ltd.agreement_for_framework(gcloud9).agreement_framework_lots.create!(framework_lot: gcloud9_lot1)

  # March tasks
  Task.create!(due_on: '2019-04-07', period_month: 3, period_year: 2019, framework: gcloud10, supplier: post_office_ltd)
  Task.create!(due_on: '2019-04-07', period_month: 3, period_year: 2019, framework: gcloud9, supplier: platform_sh_ltd)

  # April tasks
  Task.create!(due_on: '2019-05-07', period_month: 4, period_year: 2019, framework: gcloud10, supplier: post_office_ltd)
  Task.create!(due_on: '2019-05-07', period_month: 4, period_year: 2019, framework: gcloud9, supplier: platform_sh_ltd)
end
