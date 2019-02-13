require 'rails_helper'

RSpec.feature 'Reactivating a user' do
  let(:user) { FactoryBot.create(:user, :inactive) }

  before do
    stub_auth0_token_request
    sign_in_as_admin
  end

  scenario 'successfully' do
    stub_auth0_create_user_request(user.email)

    click_on 'Users'
    click_on user.name
    click_on 'Reactivate user'
    click_on 'Reactivate user'

    expect(page).to_not have_content('Inactive user')
  end

  scenario 'unsuccessfully with Auth0 error' do
    stub_auth0_create_user_request_failure(user.email)

    click_on 'Users'
    click_on user.name
    click_on 'Reactivate user'
    click_on 'Reactivate user'

    expect(page).to have_content('There was an error adding the user to Auth0.')
  end
end
