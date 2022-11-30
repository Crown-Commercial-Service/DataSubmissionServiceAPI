require 'rails_helper'

RSpec.feature 'Admin users can' do
  before do
    user = FactoryBot.create(:user, name: 'User One', email: 'email_one@ccs.co.uk')
    supplier = FactoryBot.create(:supplier, name: 'First Supplier')
    FactoryBot.create(:membership, user: user, supplier: supplier)
    task = FactoryBot.create(:task, supplier: supplier)
    FactoryBot.create(
      :submission_with_invalid_entries,
      supplier: supplier,
      task: task,
      created_by: user
    )
    sign_in_as_admin
  end

  scenario 'view the submission errors for a supplier`s task' do
    visit admin_suppliers_path
    click_link 'First Supplier'
    click_link 'View'

    expect(page).to have_content('Required value missing')
  end
end
