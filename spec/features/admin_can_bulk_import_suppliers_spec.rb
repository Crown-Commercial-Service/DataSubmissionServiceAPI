require 'rails_helper'

RSpec.feature 'Admin can bulk import suppliers' do
  let!(:fm1234) do
    create(:framework, short_name: 'FM1234') do |framework|
      create(:framework_lot, number: '1', framework: framework)
      create(:framework_lot, number: '2a', framework: framework)
      create(:framework_lot, number: '2b', framework: framework)
    end
  end

  let!(:fm9999) do
    create(:framework, short_name: 'FM9999iv') do |framework|
      create(:framework_lot, number: '1', framework: framework)
      create(:framework_lot, number: '2', framework: framework)
      create(:framework_lot, number: '3', framework: framework)
    end
  end

  before do
    sign_in_as_admin
  end

  context 'with a valid CSV' do
    scenario 'creates suppliers that do not exist' do
      visit new_admin_supplier_bulk_onboard_path

      expect(page).to have_text 'Bulk on-board suppliers'

      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'suppliers.csv')
      click_button 'Upload'

      expect(page).to have_text 'Successfully on-boarded suppliers'

      aardvark = Supplier.find_by(name: 'Aardvark (UK) Ltd')
      aardvark_fm1234_lots = aardvark.agreements.find_by(framework: fm1234).framework_lots.pluck(:number)
      aardvark_fm9999_lots = aardvark.agreements.find_by(framework: fm9999).framework_lots.pluck(:number)

      expect(aardvark.coda_reference).to eql 'C099999'
      expect(aardvark.salesforce_id).to eql '001b000003FAKEFAKE'
      expect(aardvark_fm1234_lots).to match_array %w[1 2b]
      expect(aardvark_fm9999_lots).to match_array %w[3]

      eyx_digital = Supplier.find_by(name: 'eyx Digital')
      eyx_digital_fm1234 = eyx_digital.agreements.find_by(framework: fm1234)
      eyx_digital_fm9999_lots = eyx_digital.agreements.find_by(framework: fm9999).framework_lots.pluck(:number)

      expect(eyx_digital.coda_reference).to eql 'C088888'
      expect(eyx_digital.salesforce_id).to eql '0010N00004FAKEFAKE'
      expect(eyx_digital_fm1234).to be_nil
      expect(eyx_digital_fm9999_lots).to match_array %w[2 3]
    end
  end

  context 'with a CSV which references an unpublished framework' do
    before { fm1234.update(published: false) }

    scenario 'displays an error' do
      visit new_admin_supplier_bulk_onboard_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'suppliers.csv')
      click_button 'Upload'

      expect(page).to have_text 'Couldn\'t find Framework'
    end
  end

  context 'with a CSV with missing columns' do
    scenario 'displays an error, showing which columns are missing' do
      visit new_admin_supplier_bulk_onboard_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'suppliers_with_missing_columns.csv')
      click_button 'Upload'

      expect(page).to have_text 'Missing headers in CSV file: framework_short_name'
    end
  end

  context 'with a CSV with missing salesforce_id' do
    scenario 'displays an error, showing which columns are missing' do
      visit new_admin_supplier_bulk_onboard_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'suppliers_with_blank_salesforce_id.csv')
      click_button 'Upload'

      expect(page).to have_text 'Validation failed: Salesforce ID cannot be blank'
    end
  end

  context 'with a non-CSV file' do
    scenario 'displays an error' do
      visit new_admin_supplier_bulk_onboard_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'not-really-an.xls')
      click_button 'Upload'

      expect(page).to have_text 'Uploaded file is not a CSV file'
    end
  end

  context 'without attaching a file' do
    scenario 'displays an error' do
      visit new_admin_supplier_bulk_onboard_path
      click_button 'Upload'

      expect(page).to have_text 'Please choose a file to upload'
    end
  end
end
