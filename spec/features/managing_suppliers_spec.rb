require 'rails_helper'
RSpec.feature 'Managing suppliers' do
  before do
    FactoryBot.create(:supplier, name: 'Supplier 1', coda_reference: 'C012345')
    sign_in_as_admin
  end

  scenario 'editing a supplier successfully' do
    visit admin_suppliers_path
    click_on 'Supplier 1'
    click_on 'Edit supplier'
    fill_in 'Name', with: 'Edited Supplier'
    click_button 'Update supplier'

    expect(page).to have_content('Edited Supplier')
    expect(page).to have_content('Supplier updated successfully')
  end

  scenario 'editing a supplier unsuccessfully' do
    visit admin_suppliers_path
    click_on 'Supplier 1'
    click_on 'Edit supplier'
    fill_in 'Name', with: ''
    click_button 'Update supplier'

    expect(page).to have_content('Enter a supplier name')
  end
end
