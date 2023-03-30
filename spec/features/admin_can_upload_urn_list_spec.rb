require 'rails_helper'

RSpec.feature 'Admin can upload a URN lists' do
  let(:urn_list) do
    create(:urn_list, aasm_state: :processed)
  end

  before do
    sign_in_as_admin
    urn_list
  end

  scenario 'uploading a URN list' do
    visit admin_urn_lists_path
    click_link 'Add a new URN list'

    expect(page).to have_text 'Upload a new URN list'

    attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'customers_test.xlsx')
    click_button 'Upload URN list'

    expect(page).to have_text 'customers_test.xlsx'
    expect(page).to have_text 'pending'

    expect(UrnListImporterJob).to have_been_enqueued
  end
end
