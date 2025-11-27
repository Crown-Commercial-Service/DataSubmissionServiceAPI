require 'rails_helper'

RSpec.feature 'Admin users can' do
  context 'when there is a supplier with tasks' do
    before do
      stub_govuk_bank_holidays_request
      supplier = FactoryBot.create(:supplier, name: 'First Supplier')
      framework1 = FactoryBot.create(:framework, name: 'Framework 1')
      FactoryBot.create(:framework, name: 'Framework 2')
      FactoryBot.create(:agreement, framework: framework1, supplier: supplier)
      FactoryBot.create(:task, supplier: supplier, framework: framework1, period_month: 4, period_year: 2019)
      sign_in_as_admin
    end

    scenario 'add another task' do
      travel_to Date.new(2019, 6, 15) do
        visit admin_suppliers_path
        click_on 'First Supplier'
        click_on 'Add a missing task'
        select 'May', from: 'Period month'
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
        select 'April', from: 'Period month'
        select '2019', from: 'Period year'
        select 'Framework 1', from: 'Framework'
        click_button 'Create task'
        expect(page).to have_content 'This task already exists'
      end
    end

    scenario 'when task is in the future' do
      travel_to Date.new(2019, 6, 15) do
        visit admin_suppliers_path
        click_on 'First Supplier'
        click_on 'Add a missing task'
        select 'July', from: 'Period month'
        select '2019', from: 'Period year'
        select 'Framework 1', from: 'Framework'
        click_button 'Create task'
        expect(page).to have_content 'Task cannot be in the future'
      end
    end
  end

  context 'when the supplier has frameworks in different states' do
    let!(:supplier) { FactoryBot.create(:supplier, name: 'Second Supplier') }
    let!(:published_framework) { FactoryBot.create(:framework, name: 'Published Framework', aasm_state: 'published') }
    let!(:new_framework) { FactoryBot.create(:framework, name: 'New Framework', aasm_state: 'new') }
    let!(:archived_framework) { FactoryBot.create(:framework, name: 'Archived Framework', aasm_state: 'archived') }

    before do
      stub_govuk_bank_holidays_request

      FactoryBot.create(:agreement, framework: published_framework, supplier: supplier)
      FactoryBot.create(:agreement, framework: new_framework, supplier: supplier)
      FactoryBot.create(:agreement, framework: archived_framework, supplier: supplier)

      sign_in_as_admin
    end

    scenario 'frameworks are filtered to only show active ones' do
      visit new_admin_supplier_task_path(supplier)

      expect(page).to have_select('Framework', options: [published_framework.full_name, new_framework.full_name])
      expect(page).not_to have_select('Framework', options: [archived_framework.full_name])
    end
  end

  context 'when the supplier has only archived frameworks' do
    before do
      stub_govuk_bank_holidays_request
      supplier = FactoryBot.create(:supplier, name: 'Archived Only Supplier')
      archived_framework = FactoryBot.create(:framework, name: 'Archived Framework', aasm_state: 'archived')
      FactoryBot.create(:agreement, framework: archived_framework, supplier: supplier)
      sign_in_as_admin
    end

    scenario 'does not show add missing task link' do
      visit admin_suppliers_path
      click_on 'Archived Only Supplier'
      expect(page).not_to have_link 'Add a missing task'
    end
  end
end
