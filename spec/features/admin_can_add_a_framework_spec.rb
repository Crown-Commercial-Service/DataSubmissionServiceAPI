require 'rails_helper'

RSpec.feature 'Admin can add a framework' do
  before do
    # Given that I am logged in as an admin
    sign_in_as_admin
  end

  context 'we have a valid framework source' do
    let(:valid_source) do
      <<~FDL
        Framework RM6060 {
          Name 'Fake framework'
          ManagementCharge 0.5% of 'Supplier Price'
           InvoiceFields {
            InvoiceValue from 'Supplier Price'
          }
        }
      FDL
    end

    scenario 'there are no existing frameworks' do
      # And there are no existing frameworks
      # When I visit the frameworks page
      visit admin_frameworks_path
      # Then I should see no frameworks
      expect(page).to have_text('No frameworks')

      # And I click 'new framework'
      click_link 'New Framework'
      # Then I should see a "new framework" page
      expect(page).to have_text('New framework')

      # When I paste a valid framework
      fill_in 'Definition', with: valid_source
      # And I click "Save definition"
      click_button 'Save definition'
      # Then I should see "framework saved successfully"
      expect(page).to have_text('Definition saved successfully')

      save_and_open_page
      # And I should see my FDL
      expect(page).to have_content('Framework RM6060 {')
    end
  end
end
