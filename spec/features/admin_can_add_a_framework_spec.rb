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
          Lots { '99' -> 'Fake' }
           InvoiceFields {
            InvoiceValue from 'Supplier Price'
          }
        }
      FDL
    end

    context 'there are no existing agreements' do
      scenario 'everything is fine' do
        # And there are no existing agreements
        # When I visit the agreements page
        visit admin_frameworks_path
        # Then I should see no agreements
        expect(page).to have_text('No agreements')

        # And I click 'new agreements'
        click_link 'New Agreement'
        # Then I should see a "new agreement" page
        expect(page).to have_text('New agreement')

        # When I paste a valid agreement
        fill_in 'Definition', with: valid_source
        # And I click "Save definition"
        click_button 'Save definition'
        # Then I should see "agreement saved successfully"
        expect(page).to have_text('Definition saved successfully')

        # And I should see my FDL
        expect(page).to have_content('Framework RM6060 {')
      end
    end

    context 'there is an existing agreement with the same name' do
      let!(:existing_framework) { create :framework, short_name: 'RM6060', definition_source: valid_source }

      scenario 'it rejects the new agreement' do
        # When I visit the agreements page
        visit admin_frameworks_path
        # And I click 'new agreement'
        click_link 'New Agreement'

        # When I paste the valid agreement with the same name
        fill_in 'Definition', with: valid_source
        # And I click "Save definition"
        click_button 'Save definition'

        # Then I should see that the agreement already exists"
        expect(page).to have_text('Short name has already been taken')
        # And I should see my FDL
        expect(find_field('Definition source').value).to include('Framework RM6060 {')
      end
    end
  end

  context 'we have a syntactically valid agreement source, but it is missing InvoiceValue' do
    let(:invalid_source) do
      <<~FDL
        Framework RM6060 {
          Name 'Fake framework'
          ManagementCharge 0.5% of 'Supplier Price'
          Lots { '99' -> 'Fake' }
           InvoiceFields {
            String from 'Supplier Price'
          }
        }
      FDL
    end

    scenario 'the agreement source is rejected' do
      # When I visit the agreements page
      visit admin_frameworks_path

      # And I click 'new agreement'
      click_link 'New Agreement'
      # Then I should see a "new agreement" page
      expect(page).to have_text('New agreement')

      # When I paste an invalid agreement
      fill_in 'Definition', with: invalid_source
      # And I click "Save definition"
      click_button 'Save definition'
      # Then I should see "InvoiceFields is missing an InvoiceValue field"
      expect(page).to have_text('InvoiceFields is missing an InvoiceValue field')

      # And I should see my FDL
      expect(find_field('Definition source').value).to include('Framework RM6060 {')
    end
  end

  context 'we have an invalid agreement source' do
    let(:invalid_source) { 'Frameworxk RM6060 {       }' }

    scenario 'the agreement source is rejected' do
      # When I visit the agreements page
      visit admin_frameworks_path

      # And I click 'new agreement'
      click_link 'New Agreement'
      # Then I should see a "new agreement" page
      expect(page).to have_text('New agreement')

      # When I paste an invalid agreement
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
