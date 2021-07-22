require 'rails_helper'
RSpec.feature 'Managing user memberships' do
  let!(:user) { FactoryBot.create(:user, suppliers: [supplier_1]) }
  let!(:supplier_1) { FactoryBot.create(:supplier, name: 'Supplier 1') }
  let!(:supplier_2) { FactoryBot.create(:supplier, name: 'Supplier 2') }

  before { sign_in_as_admin }

  scenario 'adding a user to a supplier' do
    visit admin_user_path(user)
    click_on 'Link to a supplier'
    expect(page).to_not have_content('Supplier 1')
    expect(page).to have_content('Supplier 2')
    click_on 'Link user'

    expect(page).to have_content('Supplier 1')
    expect(page).to have_content('Supplier 2')
  end

  scenario 'removing a user from a supplier' do
    visit admin_user_path(user)
    expect(page).to have_content('Supplier 1')
    click_on 'Unlink'
    click_on 'Unlink user'

    expect(page).to_not have_content('Supplier 1')
  end

  scenario 'searching for a supplier' do
    visit admin_user_path(FactoryBot.create(:user))
    click_on 'Link to a supplier'

    expect(page).to have_content('Supplier 1')
    expect(page).to have_content('Supplier 2')

    fill_in :search, with: 'Supplier 1'
    click_on 'Search'

    expect(page).to have_content('Supplier 1')
    expect(page).not_to have_content('Supplier 2')
  end
end
