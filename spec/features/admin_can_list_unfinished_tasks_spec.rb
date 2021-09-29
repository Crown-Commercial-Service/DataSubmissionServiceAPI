require 'rails_helper'

RSpec.feature 'Admin can list unfinished tasks' do
  before do
    sign_in_as_admin

    user = FactoryBot.create(:user, email: 'test@example.com')
    supplier = FactoryBot.create(:supplier, name: 'Test Supplier Ltd')
    aasm_states = %i[completed validation_failed ingest_failed in_review]

    aasm_states.each do |state|
      task = FactoryBot.create(:task, supplier: supplier)
      FactoryBot.create(:submission, task: task, created_by: user, supplier: supplier, aasm_state: state) do |submission|
        FactoryBot.create(:submission_file, :with_attachment, submission: submission, filename: 'test.xlsx')
      end
    end
  end

  scenario 'admin user views unfinished tasks' do
    visit admin_root_path
    click_link 'Unfinished Tasks'

    expect(page).to have_text('Validation Failed')
    expect(page).to have_text('Ingest Failed')
    expect(page).to have_text('In Review')
    expect(page).not_to have_text('Completed')
  end

  scenario "allows a task's submission files to be downloaded" do
    visit admin_root_path
    click_link 'Unfinished Tasks'

    click_link('Download', match: :first)

    pp "page.response_headers::::::"
    pp page.response_headers
    expect(page.response_headers['Content-Disposition']).to match(/^attachment/)
    expect(page.response_headers['Content-Disposition']).to match(/FM1011 Test Supplier Ltd %28January 2019%29\.xlsx/)
    expect(page.body).to include File.open(Rails.root.join('spec', 'fixtures', 'test.xlsx'), 'r:ASCII-8BIT', &:read)
  end
end
