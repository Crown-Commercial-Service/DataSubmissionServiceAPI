require 'rails_helper'
RSpec.feature 'Managing user memberships' do
  scenario 'adding a user to a supplier' do
    sign_in_as_admin
    user = FactoryBot.create(:user)
    user.suppliers << FactoryBot.create(:supplier, name: 'Supplier 1')
    FactoryBot.create(:supplier, name: 'Supplier 2')
    visit admin_user_path(user)
    click_on 'Link to a supplier'
    expect(page).to_not have_content('Supplier 1')
    expect(page).to have_content('Supplier 2')
    click_on 'Link user'
    expect(page).to have_content('Supplier 1')
    expect(page).to have_content('Supplier 2')
  end
  scenario 'removing a user from a supplier' do
    sign_in_as_admin
    user = FactoryBot.create(:user)
    user.suppliers << FactoryBot.create(:supplier, name: 'Supplier 1')
    visit admin_user_path(user)
    expect(page).to have_content('Supplier 1')
    click_on 'Unlink'
    click_on 'Unlink user'
    expect(page).to_not have_content('Supplier 1')
  end
end
