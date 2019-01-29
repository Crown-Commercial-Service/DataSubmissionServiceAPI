require 'rails_helper'
RSpec.feature 'Viewing a supplier' do
  before do
    @supplier_with_no_framework = FactoryBot.create(:supplier, name: 'No Framework Supplier Ltd')
    @supplier = FactoryBot.create(:supplier, name: 'Test Supplier Ltd')
    @framework = FactoryBot.create(:framework, name: 'Test Framework', short_name: 'RM0000')
    @agreement = FactoryBot.create(:agreement, supplier: @supplier, framework: @framework)
    sign_in_as_admin
  end

  scenario 'lists frameworks the supplier has an agreement for' do
    visit admin_supplier_path(@supplier)
    expect(page).to have_content 'Test Supplier Ltd'
    expect(page).to have_content 'RM0000 Test Framework'
  end

  scenario 'with no framework agreements shows an empty state' do
    visit admin_supplier_path(@supplier_with_no_framework)
    expect(page).to have_content "No frameworks for #{@supplier_with_no_framework.name}"
  end
end
