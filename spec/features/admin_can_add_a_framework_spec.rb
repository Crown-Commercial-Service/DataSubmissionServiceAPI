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

    context 'there are no existing frameworks' do
      scenario 'everything is fine' do
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

        # And I should see my FDL
        expect(page).to have_content('Framework RM6060 {')
      end
    end

    context 'there is an existing framework with the same name' do
      let!(:existing_framework) { create :framework, short_name: 'RM6060', definition_source: valid_source }

      scenario 'it rejects the new framework' do
        # When I visit the frameworks page
        visit admin_frameworks_path
        # And I click 'new framework'
        click_link 'New Framework'

        # When I paste the valid framework with the same name
        fill_in 'Definition', with: valid_source
        # And I click "Save definition"
        click_button 'Save definition'

        # Then I should see that the framework already exists"
        expect(page).to have_text('Short name has already been taken')
        # And I should see my FDL
        expect(find_field('Definition source').value).to include('Framework RM6060 {')
      end
    end
  end

  context 'we have an invalid framework source' do
    let(:invalid_source) { 'Frameworxk RM6060 {       }' }

    scenario 'the framework source is rejected' do
      # When I visit the frameworks page
      visit admin_frameworks_path

      # And I click 'new framework'
      click_link 'New Framework'
      # Then I should see a "new framework" page
      expect(page).to have_text('New framework')

      # When I paste an ivalid framework
      fill_in 'Definition', with: invalid_source
      # And I click "Save definition"
      click_button 'Save definition'
      # Then I should see "failed to match sequence"
      expect(page).to have_text('Failed to match sequence')

      # And I should see my FDL
      expect(find_field('Definition source').value).to include('Frameworxk RM6060 {')
    end
  end
end
