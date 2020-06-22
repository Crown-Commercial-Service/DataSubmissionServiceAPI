require 'rails_helper'

RSpec.feature 'Admin can bulk remove suppliers from lots' do
  let!(:supplier) do
    supplier = create(:supplier,
                      name: 'Aardvark (UK) Ltd',
                      coda_reference: 'C099999',
                      salesforce_id: '001b000003FAKEFAKE')

    agreement = supplier.agreements.create!(framework: fm1234)

    agreement.agreement_framework_lots.create!(framework_lot: lot_1)
    agreement.agreement_framework_lots.create!(framework_lot: lot_2a)

    supplier
  end

  let(:fm1234) do
    create(:framework, short_name: 'FM1234')
  end

  let(:lot_1) do
    create(:framework_lot, number: '1', framework: fm1234)
  end

  let(:lot_2a) do
    create(:framework_lot, number: '2a', framework: fm1234)
  end

  before do
    sign_in_as_admin
  end

  context 'with a valid CSV' do
    scenario 'off-boards suppliers from specified framework lots' do
      visit admin_suppliers_path
      click_link 'Remove suppliers from lots'

      expect(page).to have_text 'Remove suppliers from lots'

      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'suppliers-to-offboard-from-framework-lots.csv')
      click_button 'Upload'

      expect(page).to have_text 'Successfully off-boarded suppliers'

      aardvark = Supplier.find_by(name: 'Aardvark (UK) Ltd')
      aardvark_fm1234_lots = aardvark.agreements.find_by(framework: fm1234).framework_lots.pluck(:number)

      expect(aardvark.coda_reference).to eql 'C099999'
      expect(aardvark.salesforce_id).to eql '001b000003FAKEFAKE'
      expect(aardvark_fm1234_lots).to match_array %w[1]
    end
  end

  context 'with a CSV which references an unpublished framework' do
    before { fm1234.update(published: false) }

    scenario 'displays an error' do
      visit new_admin_supplier_bulk_lot_removal_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'suppliers-to-offboard-from-framework-lots.csv')
      click_button 'Upload'

      expect(page).to have_text 'Couldn\'t find Framework'
    end
  end

  context 'with a CSV with missing columns' do
    scenario 'displays an error, showing which columns are missing' do
      visit new_admin_supplier_bulk_lot_removal_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'suppliers_with_missing_columns.csv')
      click_button 'Upload'

      expect(page).to have_text 'Missing headers in CSV file: framework_short_name'
    end
  end

  context 'with a non-CSV file' do
    scenario 'displays an error' do
      visit new_admin_supplier_bulk_lot_removal_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'not-really-an.xls')
      click_button 'Upload'

      expect(page).to have_text 'Uploaded file is not a CSV file'
    end
  end

  context 'without attaching a file' do
    scenario 'displays an error' do
      visit new_admin_supplier_bulk_lot_removal_path

      click_button 'Upload'

      expect(page).to have_text 'Please choose a file to upload'
    end
  end
end
