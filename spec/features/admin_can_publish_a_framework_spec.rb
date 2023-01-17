require 'rails_helper'

RSpec.feature 'Admin can edit a framework' do
  let!(:framework) do
    create(:framework, published: published, short_name: 'RM999',
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

  context 'there is an existing unpublished framework' do
    let(:published) { false }

    scenario 'everything is fine' do
      visit admin_framework_path(framework)
      click_button('Publish agreement')
      expect(page).to have_content('Framework published successfully')
      expect(framework.lots.count).to eq(2)
    end
  end

  context 'there is an existing published framework' do
    let(:published) { true }

    scenario 'no link exists to publish' do
      visit admin_framework_path(framework)
      expect(page).to_not have_content('Publish')
    end
  end
end
