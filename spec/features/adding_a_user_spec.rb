require 'rails_helper'

RSpec.feature 'Adding a user' do
  let(:email) { 'new@example.com' }

  before do
    allow(Rails.logger).to receive(:error)
    stub_auth0_token_request
    stub_auth0_create_user_request(email)

    sign_in_as_admin
  end

  scenario 'successfully' do
    click_on 'Users'
    click_on 'Add a new user'
    fill_in 'Name', with: 'New User'
    fill_in 'Email address', with: email
    click_button 'Add new user'
    expect(page).to have_content('New User')
    expect(page).to have_content('new@example.com')
  end

  scenario 'with Rails validation error' do
    FactoryBot.create(:user, email: 'new@example.com')

    click_on 'Users'
    click_on 'Add a new user'
    fill_in 'Name', with: 'New User'
    fill_in 'Email address', with: 'new@example.com'
    click_button 'Add new user'
    expect(page).to have_content('Email has already been taken')
  end

  scenario 'with Auth0 error' do
    email = 'bla@example.com'
    stub_auth0_create_user_request_failure(email)

    click_on 'Users'
    click_on 'Add a new user'
    fill_in 'Name', with: 'New User'
    fill_in 'Email address', with: 'bla@example.com'
    click_button 'Add new user'

    expect(page).to have_content('There was an error adding the user to Auth0.')
    expect(User.find_by(email: email)).to be_nil
    expect(Rails.logger).to have_received(:error)
      .with(/Error adding user bla@example.com to Auth0 during User#create/)
  end
end
