require 'rails_helper'

RSpec.feature 'Signing in' do
  scenario 'successfully as authorised admin' do
    mock_sso_with(email: 'email@example.com')
    ClimateControl.modify ADMIN_EMAILS: 'email@example.com' do
      visit '/admin'
      click_on 'Start now'
      expect(page).to have_content 'Sign out'
    end
  end

  scenario 'as unauthorised user' do
    mock_sso_with(email: 'not@example.com')
    ClimateControl.modify ADMIN_EMAILS: 'email@example.com' do
      visit '/admin'
      click_on 'Start now'
      expect(page).to have_content 'account does not have access'
    end
  end
end
