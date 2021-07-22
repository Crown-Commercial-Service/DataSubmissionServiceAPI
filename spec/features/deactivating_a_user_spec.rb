require 'rails_helper'

RSpec.feature 'Deactivating a user' do
  let(:user) { FactoryBot.create(:user) }

  before do
    stub_auth0_token_request
    stub_auth0_delete_user_request(user)
  end

  scenario 'successfully' do
    sign_in_as_admin
    click_on 'Users'
    click_on user.name
    click_on 'Deactivate user'
    click_on 'Deactivate user'

    expect(page).to have_content('User has been deactivated')
  end
end
