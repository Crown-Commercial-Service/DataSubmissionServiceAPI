require 'rails_helper'

RSpec.feature 'Adding a user' do
  let(:email) { 'new@example.com' }
  let!(:supplier_1) { FactoryBot.create(:supplier, name: 'Supplier 1') }
  let!(:supplier_2) { FactoryBot.create(:supplier, name: 'Supplier 2') }

  before do
    allow(Rails.logger).to receive(:error)
    stub_auth0_token_request

    stub_auth0_get_users_request(email: email)
    stub_auth0_create_user_request(email)

    sign_in_as_admin
  end

  context 'successfully' do
    scenario 'from scratch' do
      click_on 'Users'
      click_on 'Add a new user'

      fill_in 'Name', with: 'New User'
      fill_in 'Email address', with: email

      click_button 'Select suppliers'

      expect(page).to have_content(supplier_1.name)
      expect(page).to have_content(supplier_1.salesforce_id)
      expect(page).to have_content(supplier_2.name)
      expect(page).to have_content(supplier_2.salesforce_id)

      fill_in 'Search', with: '2'
      click_button 'Search'

      expect(page).not_to have_content(supplier_1.name)
      expect(page).to have_content(supplier_2.name)

      check "supplier_#{supplier_2.salesforce_id}"

      click_button 'Confirm'

      expect(page).to have_content('New User')
      expect(page).to have_content('new@example.com')
      expect(page).to have_content(supplier_2.name)

      click_button 'Create user'

      expect(page).to have_content('User created successfully with linked suppliers.')
    end

    scenario 'from a supplier' do
      visit admin_supplier_path(supplier_1)

      click_on 'Add a new user'

      fill_in 'Name', with: 'New User'
      fill_in 'Email address', with: email

      click_button 'Confirm'

      expect(page).to have_content('New User')
      expect(page).to have_content(email)
      expect(page).to have_content(supplier_1.name)
      click_button 'Create user'
      expect(page).to have_content('User created successfully with linked suppliers.') 
    end
  end

  context 'when no name is provided' do
    scenario 'it fails and prompts you to provide a name' do
      visit new_admin_user_path

      fill_in 'Email address', with: email
      click_button 'Select suppliers'

      expect(page).to have_content('You must provide a name.')
    end
  end

  context 'when no email provided' do
    scenario 'it fails and prompts you to provide an email address' do
      visit new_admin_user_path

      fill_in 'Name', with: 'New User'
      click_button 'Select suppliers'

      expect(page).to have_content('You must provide an email address.')
    end
  end

  context 'when an existing email provided' do
    let!(:existing_user) { create :user, email: email }
    scenario 'it fails and alerts you the user already exists' do
      visit new_admin_user_path

      fill_in 'Name', with: 'New User'
      fill_in 'Email address', with: email
      click_button 'Select suppliers'

      expect(page).to have_content('Email address has already been taken.')
    end
  end

  context 'when no supplier provided' do
    scenario 'it fails and prompts you to select a supplier' do
      visit new_admin_user_path

      fill_in 'Name', with: 'New User'
      fill_in 'Email address', with: email
      click_button 'Select suppliers'
      click_button 'Confirm'

      expect(page).to have_content('You must select at least one supplier.')
    end
  end
end
