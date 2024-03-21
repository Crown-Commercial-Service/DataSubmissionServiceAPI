require 'rails_helper'

RSpec.feature 'Admin users can' do
  let!(:user) { FactoryBot.create(:user, name: 'User One', email: 'email_one@ccs.co.uk') }
  let!(:supplier) { FactoryBot.create(:supplier, name: 'First Supplier') }
  let!(:task) { FactoryBot.create(:task, supplier: supplier) }

  before do
    FactoryBot.create(:membership, user: user, supplier: supplier)
    FactoryBot.create(
      :completed_submission,
      supplier: supplier,
      task: task,
      created_by: user
    )
    sign_in_as_admin
  end

  scenario 'view the submission details for a supplier`s task' do
    visit admin_suppliers_path
    click_link 'First Supplier'
    click_link 'View'

    expect(page).to have_content("#{task.framework.short_name} #{task.framework.name} for January 2018")
    expect(page).to have_content('Reported by email_one@ccs.co.uk')
    expect(page).to have_content('Filename not-really-an.xls')
  end
end