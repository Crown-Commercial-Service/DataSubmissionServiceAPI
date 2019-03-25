require 'rails_helper'

RSpec.feature 'Admin users can' do
  before do
    supplier = FactoryBot.create(:supplier, name: 'First Supplier')
    task = FactoryBot.create(:task, supplier: supplier)
    FactoryBot.create(
      :submission_with_invalid_entries,
      supplier: supplier,
      task: task
    )
    sign_in_as_admin
  end

  scenario 'view a paged list of suppliers' do
    visit admin_suppliers_path
    click_link 'First Supplier'
    click_link 'View'

    expect(page).to have_content('Required value missing')
  end
end
