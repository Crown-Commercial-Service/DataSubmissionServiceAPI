require 'rails_helper'

RSpec.feature 'Signing in' do
  scenario 'successfully as authorized admin' do
    mock_sso_with(email: 'email@example.com')
    ClimateControl.modify ADMIN_EMAILS: 'email@example.com' do
      visit '/admin'
      expect(page).to have_content 'John Smith'
    end
  end

  scenario 'as unauthorized user' do
    mock_sso_with(email: 'not@example.com')
    ClimateControl.modify ADMIN_EMAILS: 'email@example.com' do
      visit '/admin'
      expect(page).to have_content 'Not authorized'
    end
  end
end
