require 'rails_helper'

RSpec.feature 'Admin users can' do
  context 'when there are suppliers' do
    before do
      FactoryBot.create(:supplier, name: 'First Supplier')
      FactoryBot.create_list(:supplier, 24)
      FactoryBot.create(:supplier, name: 'Last Supplier')
      sign_in_as_admin
    end

    scenario 'view a paged list of suppliers' do
      visit admin_suppliers_path
      expect(page).to have_content 'First Supplier'
      expect(page).to have_content 'Next ›'
    end

    scenario 'view a second supplier list page' do
      visit admin_suppliers_path
      click_on 'Next ›'
      expect(page).to have_content 'Last Supplier'
    end

    scenario 'view a supplier' do
      visit admin_suppliers_path
      click_on 'First Supplier'
      expect(page).to have_content 'First Supplier'
    end

    scenario 'find a supplier' do
      visit admin_suppliers_path
      fill_in 'Search', with: 'ast Supp'
      click_button 'Search'
      expect(page).to have_content 'Last Supplier'
    end

    scenario 'see all suppliers when an empty search term is supplied' do
      visit admin_suppliers_path
      fill_in 'Search', with: ''
      click_button 'Search'
      expect(page).to have_content 'First Supplier'
      expect(page).to have_content 'Next ›'
    end

    scenario 'see when a supplier search returns no results' do
      visit admin_suppliers_path
      fill_in 'Search', with: 'Missing Supplier'
      click_button 'Search'
      expect(page).to have_content 'No suppliers found for ‘Missing Supplier’'
    end

    scenario 'see the search term after performing the supplier search' do
      visit admin_suppliers_path
      fill_in 'Search', with: 'ast Supp'
      click_button 'Search'
      expect(page).to have_content 'Last Supplier'
      expect(page).to have_field('search', with: 'ast Supp')
    end
  end
end
