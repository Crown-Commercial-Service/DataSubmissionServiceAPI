require 'rails_helper'

RSpec.feature 'Admin can list unfinished tasks' do
  before do
    sign_in_as_admin

    user = FactoryBot.create(:user, email: 'test@example.com')
    supplier = FactoryBot.create(:supplier)
    aasm_states = %i[completed validation_failed ingest_failed in_review]

    aasm_states.each do |state|
      task = FactoryBot.create(:task, supplier: supplier)
      FactoryBot.create(:submission, task: task, created_by: user, supplier: supplier, aasm_state: state)
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
end
