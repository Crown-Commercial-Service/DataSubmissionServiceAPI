require 'rails_helper'

RSpec.feature 'Admin users can' do
  context 'when there is a supplier with tasks' do
    before do
      stub_govuk_bank_holidays_request
      supplier = FactoryBot.create(:supplier, name: 'First Supplier')
      framework1 = FactoryBot.create(:framework, name: 'Framework 1')
      FactoryBot.create(:framework, name: 'Framework 2')
      FactoryBot.create(:agreement, framework: framework1, supplier: supplier)
      FactoryBot.create(:task, supplier: supplier, framework: framework1, period_month: 5, period_year: 2019)
      sign_in_as_admin
    end

    scenario 'add another task' do
      travel_to Date.new(2019, 6, 15) do
        visit admin_suppliers_path
        click_on 'First Supplier'
        click_on 'Add a missing task'
        select '6', from: 'Period month'
        select '2019', from: 'Period year'
        select 'Framework 1', from: 'Framework'
        click_button 'Create task'
        expect(page).to have_content 'Task added successfully'
      end
    end

    scenario 'when task already exists' do
      travel_to Date.new(2019, 6, 15) do
        visit admin_suppliers_path
        click_on 'First Supplier'
        click_on 'Add a missing task'
        select '5', from: 'Period month'
        select '2019', from: 'Period year'
        select 'Framework 1', from: 'Framework'
        click_button 'Create task'
        expect(page).to have_content 'This task already exists'
      end
    end
  end
end
