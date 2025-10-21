require 'rails_helper'

RSpec.feature 'Admin can edit a framework' do
  let(:framework) do
    create(:framework, aasm_state: aasm_state, short_name: 'RM999',
      name: 'Framework to be changed', definition_source: existing_source)
  end

  let(:existing_source) do
    <<~FDL
      Framework RM999 {
        Name 'Framework to be changed'
        ManagementCharge 0.5% of 'Supplier Price'
        Lots { '99' -> 'Fake' }
         InvoiceFields {
          InvoiceValue from 'Supplier Price'
        }
      }
    FDL
  end

  before do
    # Given that I am logged in as an admin
    sign_in_as_admin
    # And there is an existing framework
    framework
  end

  context 'we have valid framework source' do
    let(:edited_source) do
      <<~FDL
        Framework RM999 {
          Name 'Vehicle Leasing'
          ManagementCharge 0.5% of 'Supplier Price'
          Lots { '99' -> 'Fake' }
           InvoiceFields {
            InvoiceValue from 'Supplier Price'
          }
        }
      FDL
    end

    shared_examples 'successful edit' do
      scenario 'everything is fine' do
        # When I visit the frameworks page
        visit admin_frameworks_path
        # Then I should see a list of frameworks
        expect(page).to have_content('Framework to be changed')
        # When I click on the existing framework
        click_link('RM999')
        # Then I should see the framework
        expect(page).to have_content('Framework RM999 {')
        # When I click on Edit definition
        click_link('Edit definition')
        # Then I should see an edit page for the framework definition
        expect(page).to have_content('Edit agreement definition')
        # When I change the framework definition
        fill_in 'Definition source', with: edited_source
        # And I click "Save definition"
        click_button('Save definition')
        # Then I should see "framework saved successfully"
        expect(page).to have_content('Framework saved successfully')
        # And I should see the framework
        expect(page).to have_content('Vehicle Leasing')
      end
    end

    context 'there is an existing unpublished framework' do
      let(:aasm_state) { 'new' }

      include_examples 'successful edit'
    end

    context 'there is an existing published framework' do
      let(:aasm_state) { 'published' }

      include_examples 'successful edit'
    end
  end

  context 'we have invalid framework source' do
    let(:incorrectly_edited_source) do
      <<~FDL
        Framewoxk RM999 {
          Name 'Vehicle Leasing'
          Lots { '99' -> 'Fake' }

           InvoiceFields {
            InvoiceValue from 'Supplier Price'
          }
        }
      FDL
    end

    context 'there is an existing unpublished framework' do
      let(:aasm_state) { 'new' }

      scenario 'the existing framework is not updated' do
        # When I visit the frameworks page
        visit admin_frameworks_path
        # Then I should see a list of frameworks
        expect(page).to have_content('Framework to be changed')
        # When I click on the existing framework
        click_link('RM999')
        # And I click on Edit definition
        click_link('Edit definition')
        # When I change the framework definition
        fill_in 'Definition source', with: incorrectly_edited_source
        # And I click "Save definition"
        click_button('Save definition')
        # Then I should not see "framework saved successfully"
        expect(page).not_to have_content('Framework saved successfully')
        # And I should see the error message
        expect(page).to have_content('Failed to match sequence')
        # And I should see the unedited original framework
        expect(page).to have_content('Framework to be changed')
      end
    end
  end
end
