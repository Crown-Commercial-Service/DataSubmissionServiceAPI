require 'rails_helper'
RSpec.feature 'Managing suppliers' do
  before do
    FactoryBot.create(:supplier, name: 'Supplier 1', coda_reference: 'C012345')
    FactoryBot.create(:supplier, name: 'Supplier 2')
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

  scenario 'editing a supplier with a blank CODA reference value is successful' do
    visit admin_suppliers_path
    click_on 'Supplier 2'
    click_on 'Edit supplier'
    fill_in 'Name', with: 'Supplier 2 edited'
    click_button 'Update supplier'

    expect(page).not_to have_content('must start with “C0” and have 4-5 additional numbers, for example: “C012345”')
    expect(page).to have_content('Supplier updated successfully')
  end
end
