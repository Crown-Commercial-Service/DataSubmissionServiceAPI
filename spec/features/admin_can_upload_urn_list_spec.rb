require 'rails_helper'

RSpec.feature 'Admin can upload a URN list' do
  before do
    sign_in_as_admin
  end

  scenario 'everything is fine' do
    visit admin_urn_lists_path
    click_link 'Add a new URN list'

    expect(page).to have_text 'Upload an new URN list'

    attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'customers.xlsx')
    click_button 'Upload URN list'

    expect(page).to have_text 'customers.xlsx'
    expect(page).to have_text 'pending'

    expect(UrnListImporterJob).to have_been_enqueued
  end
end
