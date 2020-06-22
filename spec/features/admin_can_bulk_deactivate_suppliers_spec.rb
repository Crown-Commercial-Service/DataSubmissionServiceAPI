require 'rails_helper'

RSpec.feature 'Admin can bulk deactivate suppliers' do
  let!(:supplier) do
    supplier = create(:supplier,
                      name: 'Aardvark (UK) Ltd',
                      coda_reference: 'C099999',
                      salesforce_id: '001b000003FAKEFAKE')

    supplier.agreements.create!(framework: fm1234)
    supplier.agreements.create!(framework: fm5678)

    supplier
  end

  let(:fm1234) do
    create(:framework, short_name: 'FM1234')
  end

  let(:fm5678) do
    create(:framework, short_name: 'FM5678')
  end

  before do
    sign_in_as_admin
  end

  context 'with a valid CSV' do
    scenario 'deactivates suppliers on specified frameworks' do
      visit admin_suppliers_path
      click_link 'Deactivate suppliers'

      expect(page).to have_text 'Deactivate suppliers'

      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'suppliers-to-offboard-from-frameworks.csv')
      click_button 'Upload'

      expect(page).to have_text 'Successfully deactivated suppliers'

      deactivated_agreement = supplier.agreements.find_by(framework_id: fm1234.id)
      active_agreement = supplier.agreements.find_by(framework_id: fm5678.id)
      expect(deactivated_agreement.active).to eql false
      expect(active_agreement.active).to eql true
    end
  end

  context 'with a CSV which references an unpublished framework' do
    before { fm1234.update(published: false) }

    scenario 'displays an error' do
      visit admin_suppliers_path
      click_link 'Deactivate suppliers'

      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'suppliers-to-offboard-from-frameworks.csv')
      click_button 'Upload'

      expect(page).to have_text 'Couldn\'t find Framework'
    end
  end

  context 'with a CSV with missing columns' do
    scenario 'displays an error, showing which columns are missing' do
      visit new_admin_supplier_bulk_deactivate_path

      attach_file 'Choose', Rails.root.join(
        'spec', 'fixtures', 'suppliers-to-offboard-from-frameworks-missing-columns.csv'
      )
      click_button 'Upload'

      expect(page).to have_text 'Missing headers in CSV file: framework_short_name'
    end
  end

  context 'with a non-CSV file' do
    scenario 'displays an error' do
      visit new_admin_supplier_bulk_deactivate_path

      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'not-really-an.xls')
      click_button 'Upload'

      expect(page).to have_text 'Uploaded file is not a CSV file'
    end
  end

  context 'without attaching a file' do
    scenario 'displays an error' do
      visit new_admin_supplier_bulk_deactivate_path

      click_button 'Upload'

      expect(page).to have_text 'Please choose a file to upload'
    end
  end
end
