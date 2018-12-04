require 'rails_helper'

RSpec.feature 'Adding a user' do
  before do
    stub_auth0_token_request
    stub_auth0_create_user_request

    sign_in_as_admin
  end
  scenario 'successfully' do
    click_on 'Users'
    click_on 'Add a new user'
    fill_in 'Name', with: 'New User'
    fill_in 'Email address', with: 'new@example.com'
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
end
