require 'rails_helper'

RSpec.feature 'Updating a user' do
  let(:user) { FactoryBot.create(:user) }

  before do
    allow(Rails.logger).to receive(:error)
    stub_auth0_token_request
    sign_in_as_admin
  end

  scenario 'successfully' do
    stub_auth0_update_user_request(user)

    click_on 'Users'
    click_on user.name
    click_on 'Update user name'
    fill_in 'Name', with: 'Testy McTestface'
    click_button 'Update user'
    expect(page).to have_content('Testy McTestface')
  end

  scenario 'with Auth0 error' do
    stub_auth0_update_user_request_failure(user)

    click_on 'Users'
    click_on user.name
    click_on 'Update user name'
    fill_in 'Name', with: 'Testy McTestface'
    click_button 'Update user'

    expect(page).to have_content(I18n.t('errors.messages.error_updating_user_in_auth0'))
    expect(Rails.logger).to have_received(:error)
      .with(/Error updating user name for #{user.email} in Auth0 during UpdateUser/)
  end
end
