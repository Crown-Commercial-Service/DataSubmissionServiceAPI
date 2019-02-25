require 'rails_helper'

RSpec.describe 'Managing supplier frameworks' do
  let!(:supplier) { FactoryBot.create(:supplier, name: 'Supplier Ltd') }
  let!(:framework) { FactoryBot.create(:framework, short_name: 'RM-ABC') }
  let!(:agreement) { FactoryBot.create(:agreement, supplier: supplier, framework: framework) }

  before { sign_in_as_admin }

  scenario 'a supplier can be deactivated from a framework' do
    click_on 'Suppliers'
    click_on supplier.name

    within "#framework-#{framework.id}" do
      click_on 'Deactivate'
    end

    click_on 'Deactivate Supplier Ltd from RM-ABC'

    expect(page).to have_content('Deactivated from RM-ABC')

    within "#framework-#{framework.id}" do
      expect(page).to have_content('Inactive')
    end
  end
end
