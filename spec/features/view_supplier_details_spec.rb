require 'rails_helper'

RSpec.feature 'Viewing a supplier' do
  let!(:supplier) { FactoryBot.create(:supplier, name: 'Test Supplier Ltd') }
  let!(:framework) { FactoryBot.create(:framework, name: 'Test Framework', short_name: 'RM0000') }
  let!(:agreement) { FactoryBot.create(:agreement, supplier: supplier, framework: framework) }

  before { sign_in_as_admin }

  scenario 'lists frameworks the supplier has an agreement for' do
    visit admin_supplier_path(supplier)
    expect(page).to have_content 'Test Supplier Ltd'
    expect(page).to have_content 'RM0000 Test Framework'
  end

  scenario 'lists the supplier’s tasks' do
    FactoryBot.create(:task, period_month: 12, period_year: 2018, supplier: supplier, framework: framework)

    visit admin_supplier_path(supplier)
    expect(page).to have_content 'December 2018'
    expect(page).to have_content 'Unstarted'
  end

  scenario 'includes the details of a task’s submissions' do
    task = FactoryBot.create(:task, period_month: 12, period_year: 2018, supplier: supplier, framework: framework)
    submission = FactoryBot.create(
      :submission_with_validated_entries, supplier: supplier, framework: framework, task: task
    )
    download_url = rails_blob_url(submission.files.first.file)

    visit admin_supplier_path(supplier)
    expect(page).to have_content 'Pending'
    expect(page).to have_link 'Download submission file', href: download_url
  end
end
