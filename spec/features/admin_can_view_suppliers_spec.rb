require 'rails_helper'

RSpec.feature 'Admin users can' do
  before do
    FactoryBot.create(:supplier, name: 'First Supplier')
    FactoryBot.create_list(:supplier, 24)
    FactoryBot.create(:supplier, name: 'Last Supplier')
    sign_in_as_admin
  end

  scenario 'view a paged list of suppliers' do
    visit admin_suppliers_path
    expect(page).to have_content 'First Supplier'
    expect(page).to have_content 'Next ›'
  end

  scenario 'view a second supplier list page' do
    visit admin_suppliers_path
    click_on 'Next ›'
    expect(page).to have_content 'Last Supplier'
  end

  scenario 'view a supplier' do
    visit admin_suppliers_path
    click_on 'First Supplier'
    expect(page).to have_content 'First Supplier'
  end
end
