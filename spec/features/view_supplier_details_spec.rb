require 'rails_helper'

RSpec.feature 'Viewing a supplier' do
  let!(:supplier) { FactoryBot.create(:supplier, name: 'Test Supplier Ltd') }
  let!(:framework) { FactoryBot.create(:framework, name: 'Test Framework', short_name: 'RM0000') }
  let!(:agreement) { FactoryBot.create(:agreement, supplier: supplier, framework: framework) }

  before { sign_in_as_admin }

  scenario 'shows paginated list of frameworks the supplier has an agreement for' do
    visit admin_supplier_path(supplier)
    expect(page).to have_content 'Test Supplier Ltd'
    expect(page).to have_content 'RM0000 Test Framework'
    expect(page).to have_content 'Displaying 1 framework'
  end

  scenario 'shows paginated list of the supplier’s tasks' do
    FactoryBot.create(:task, period_month: 12, period_year: 2018, supplier: supplier, framework: framework)

    visit admin_supplier_path(supplier)
    expect(page).to have_content 'December 2018'
    expect(page).to have_content 'Unstarted'
    expect(page).to have_content 'Displaying 1 task'
  end

  scenario 'includes the details of a task’s submissions' do
    task = FactoryBot.create(
      :task, period_month: 12, period_year: 2018, supplier: supplier, framework: framework, status: :in_progress
    )
    FactoryBot.create(
      :submission_with_validated_entries, supplier: supplier, framework: framework, task: task
    )

    visit admin_supplier_path(supplier)
    expect(page).to have_content 'In Review'
  end

  scenario "allows a task's submission files to be downloaded" do
    task = FactoryBot.create(
      :task, period_month: 12, period_year: 2018, supplier: supplier, framework: framework, status: :completed
    )

    FactoryBot.create(:submission, supplier: supplier, framework: framework, task: task) do |submission|
      FactoryBot.create(:submission_file, :with_attachment, submission: submission, filename: 'test.xlsx')
    end

    visit admin_supplier_path(supplier)
    click_link 'Download'

    expect(page.response_headers['Content-Disposition']).to match(/^attachment/)
    expect(page.response_headers['Content-Disposition']).to match(/RM0000 Test Supplier Ltd %28December 2018%29\.xlsx/)
    expect(page.body).to include File.open(Rails.root.join('spec', 'fixtures', 'test.xlsx'), 'r:ASCII-8BIT', &:read)
  end

  scenario 'shows paginated list of the users linked to the supplier' do
    FactoryBot.create(:user, suppliers: [supplier])

    visit admin_supplier_path(supplier)
    expect(page).to have_content 'Active?'
    expect(page).to have_content 'Displaying 1 user'
  end

  scenario 'allows users to be filtered by status' do
    FactoryBot.create(:user, name: 'Active User', suppliers: [supplier])
    FactoryBot.create(:user, name: 'Inactive User', auth_id: nil, suppliers: [supplier])

    visit admin_supplier_path(supplier)

    expect(page).to have_content 'Active User'
    expect(page).to have_content 'Inactive User'
    expect(page).to have_content 'Filter Status'

    page.check('status[]', match: :first)
    find('#status-filter-submit').click

    expect(page).to have_content 'Active User'
    expect(page).not_to have_content 'Inactive User'
  end

  scenario 'each section\'s pagination works independently' do
    period_month = 0
    12.times do
      FactoryBot.create(:task, period_month: period_month += 1, period_year: 2018, supplier: supplier,
framework: framework)
      FactoryBot.create(:user, suppliers: [supplier])
    end
    FactoryBot.create(:task, period_month: 12, period_year: 2017, supplier: supplier, framework: framework)
    FactoryBot.create(:user, suppliers: [supplier])

    visit admin_supplier_path(supplier)
    click_link('Next »', match: :first)
    expect(page).to have_content 'Displaying task 13 - 13 of 13 in total'
    expect(page).to have_content 'Displaying users 1 - 12 of 13 in total'
    expect(page).to have_content 'Displaying 1 framework'
  end
end
