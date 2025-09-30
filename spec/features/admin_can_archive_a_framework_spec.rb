require 'rails_helper'

RSpec.feature 'Admin can archive a framework' do
  let!(:framework) do
    create(:framework, aasm_state: aasm_state, short_name: 'RM999',
      name: 'Framework to be published', definition_source: definition_source)
  end
  let(:definition_source) do
    <<~FDL
      Framework RM999 {
        Name 'Framework to be published'
        ManagementCharge 0.5% of 'Supplier Price'
        Lots {
          '1' -> 'Lot 1'
          '2' -> 'Second Lot'
        }
         InvoiceFields {
          InvoiceValue from 'Supplier Price'
        }
      }
    FDL
  end

  before do
    sign_in_as_admin
  end

  context 'there is an existing published framework' do
    let(:aasm_state) { 'published' }

    scenario 'everything is fine' do
      visit admin_framework_path(framework)
      click_link('Archive agreement')
      expect(page).to have_content('Are you sure you want to archive RM999 Framework to be published?')
      click_button('Confirm')
      expect(page).to have_content('Framework archived successfully')
    end
  end

  context 'there is an existing unpublished framework' do
    let(:aasm_state) { 'new' }

    scenario 'no link exists to archive' do
      visit admin_framework_path(framework)
      expect(page).to_not have_content('Archive agreement')
    end
  end

  context 'there is an existing archived framework' do
    let(:aasm_state) { 'archived' }

    scenario 'no link exists to archive' do
      visit admin_framework_path(framework)
      expect(page).to_not have_content('Archive agreement')
      expect(page).to have_content('Unarchive agreement')
      click_link('Unarchive agreement')
      expect(page).to have_content('Are you sure you want to unarchive RM999 Framework to be published?')
      click_button('Confirm')
      expect(page).to have_content('Framework unarchived successfully')
    end
  end
end