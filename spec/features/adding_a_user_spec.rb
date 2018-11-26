require 'rails_helper'

RSpec.feature 'Finding a user' do
  scenario 'successfully' do
    sign_in_as_admin
    stub_request(:post, 'https://testdomain/oauth/token')
      .to_return(status: 200, body: '{"access_token":"TOKEN"}')
    stub_request(:post, 'https://testdomain/api/v2/users')
      .to_return(status: 200, body: '{"user_id":"auth0|TEST"}')
    visit admin_users_path
    click_on 'Add a new user'
    fill_in 'Name', with: 'New User'
    fill_in 'Email address', with: 'new@example.com'
    click_button 'Add new user'
    expect(page).to have_content('New User')
    expect(page).to have_content('new@example.com')
  end

  scenario 'with Rails validation error' do
    FactoryBot.create(:user, email: 'new@example.com')
    sign_in_as_admin
    stub_request(:post, 'https://testdomain/oauth/token')
      .to_return(status: 200, body: '{"access_token":"TOKEN"}')
    stub_request(:post, 'https://testdomain/api/v2/users')
      .to_return(status: 200, body: '{"user_id":"auth0|TEST"}')
    visit admin_users_path
    click_on 'Add a new user'
    fill_in 'Name', with: 'New User'
    fill_in 'Email address', with: 'new@example.com'
    click_button 'Add new user'
    expect(page).to have_content('Email has already been taken')
  end
end
