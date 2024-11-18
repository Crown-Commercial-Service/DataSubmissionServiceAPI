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

  scenario 'successfully' do
    visit new_admin_user_path

    expect(page).to have_content(supplier_1.name)
    expect(page).to have_content(supplier_1.salesforce_id)
    expect(page).to have_content(supplier_2.name)
    expect(page).to have_content(supplier_2.salesforce_id)

    fill_in 'Search', with: '2'
    click_button 'Search'

    expect(page).not_to have_content(supplier_1.name)
    expect(page).to have_content(supplier_2.name)

    fill_in 'Name', with: 'New User'
    fill_in 'Email address', with: email
    fill_in 'salesforce-ids', with: supplier_2.salesforce_id

    click_on 'Add new user'

    expect(page).to have_content('New User')
    expect(page).to have_content('new@example.com')
    expect(page).to have_content(supplier_2.name)
  end

  context 'when no name is provided' do
    scenario 'it fails and prompts you to provide a name' do
      click_on 'Users'
      click_on 'Add a new user'
      fill_in 'Email address', with: email
      fill_in 'salesforce-ids', with: supplier_2.salesforce_id
      click_button 'Add new user'

      expect(page).to have_content('You must provide a name.')
    end
  end

  context 'when no email provided' do
    scenario 'it fails and prompts you to provide an email address' do
      click_on 'Users'
      click_on 'Add a new user'
      fill_in 'Name', with: 'New User'
      fill_in 'salesforce-ids', with: supplier_2.salesforce_id
      click_button 'Add new user'

      expect(page).to have_content('You must provide an email address.')
    end
  end

  context 'when an existing email provided' do
    let!(:existing_user) { create :user, email: email }
    scenario 'it fails and alerts you the user already exists' do
      click_on 'Users'
      click_on 'Add a new user'
      fill_in 'Name', with: 'New User'
      fill_in 'Email address', with: email
      click_button 'Add new user'

      expect(page).to have_content('Email address already exists.')
    end
  end

  context 'when no supplier provided' do
    scenario 'it fails and prompts you to select a supplier' do
      click_on 'Users'
      click_on 'Add a new user'
      fill_in 'Name', with: 'New User'
      fill_in 'Email address', with: email
      click_button 'Add new user'

      expect(page).to have_content('You must select at least one supplier.')
    end
  end

  scenario 'with invalid Salesforce provided' do
    click_on 'Users'
    click_on 'Add a new user'
    fill_in 'Name', with: 'New User'
    fill_in 'Email address', with: 'bla@example.com'
    fill_in 'salesforce-ids', with: 'INVALIDSFID123'
    click_button 'Add new user'

    expect(page).to have_content('Failed to create user')
  end
end
