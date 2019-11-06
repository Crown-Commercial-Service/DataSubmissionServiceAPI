require 'rails_helper'

RSpec.feature 'Uploading a template to a Framework' do
  before do
    sign_in_as_admin
  end

  context 'we have an unpublished framework' do
    let!(:framework) { create(:framework, published: false) }

    scenario 'everything is fine' do
      visit admin_frameworks_path
      click_on framework.name
      attach_file 'Choose', Rails.root.join('spec', 'fixtures', 'test.xls')
      click_button 'Upload Template'
      expect(page).to have_content('test.xls')
    end
  end

  context 'we have a published framework' do
    let!(:framework) { create(:framework, :with_attachment, published: true) }

    scenario 'everything is fine' do
      visit admin_frameworks_path
      click_on framework.name
      attach_file 'Replace file', Rails.root.join('spec', 'fixtures', 'test.xls')
      click_button 'Upload Template'
      expect(page).to have_content('test.xls')
    end
  end

  context 'when no file was provided' do
    let!(:framework) { create(:framework, published: true) }

    it 'responds with a meaningful error message' do
      visit admin_frameworks_path
      click_on framework.name
      # Omit step to provide a file to simulate the bug
      click_button 'Upload Template'
      expect(page).to have_content(I18n.t('errors.message.missing_template_file'))
    end
  end
end
