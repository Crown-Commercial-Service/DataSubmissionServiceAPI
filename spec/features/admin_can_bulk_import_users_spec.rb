require 'rails_helper'

RSpec.feature 'Admin can bulk import users' do
  before do
    sign_in_as_admin
  end

  scenario 'everything is fine' do
    visit new_admin_user_bulk_import_path

    expect(page).to have_text 'Bulk import users'

    attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'users.csv')

    click_button 'Upload'

    expect(page).to have_text 'users.csv'
    expect(page).to have_text 'pending'

    expect(UserImportJob).to have_been_enqueued
  end

  context 'with a non-CSV file' do
    scenario 'displays an error' do
      visit new_admin_user_bulk_import_path
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'not-really-an.xls')
      click_button 'Upload'

      expect(page).to have_text 'Uploaded file is not a CSV file'
    end
  end

  context 'without attaching a file' do
    scenario 'displays an error' do
      visit new_admin_user_bulk_import_path
      click_button 'Upload'

      expect(page).to have_text 'Please choose a file to upload'
    end
  end
end
