require 'rails_helper'

RSpec.feature 'Admin can list frameworks' do
  before do
    # Given that I am logged in as an admin
    sign_in_as_admin

    # And there are some published frameworks
    FactoryBot.create(:framework, name: 'Laundry Framework 1', short_name: 'RM1234')
    FactoryBot.create(:framework, name: 'Vehicle Purchase Framework 1', short_name: 'RM5678')
    # And there is a new/unpublished frameworks
    FactoryBot.create(:framework, aasm_state: 'new', name: 'Vehicle Purchase Framework 2', short_name: 'RM5679')
    # And there is an archived frameworks
    FactoryBot.create(:framework, aasm_state: 'archived', name: 'Archived framework', short_name: 'RM5789')
  end

  scenario 'There are some new and published but not archived agreements' do
    # When I click the "Agreements" link from the main admin page
    visit admin_root_path
    click_link 'Agreements'

    # Then I should see a list of agreements with their statuses
    within 'tbody > tr:nth-child(1)' do
      expect(page).to have_text('RM1234')
      expect(page).to have_text('Laundry Framework 1')
      expect(page).to have_text('published')
    end

    within 'tbody > tr:nth-child(2)' do
      expect(page).to have_text('RM5678')
      expect(page).to have_text('Vehicle Purchase Framework 1')
      expect(page).to have_text('published')
    end

    within 'tbody > tr:nth-child(3)' do
      expect(page).to have_text('RM5679')
      expect(page).to have_text('Vehicle Purchase Framework 2')
      expect(page).to have_text('new')
    end

    expect(page).not_to have_text('RM5789')
    expect(page).not_to have_text('Vehicle Purchase Framework 3')
  end

  scenario 'agreements can be filtered by status' do
    visit admin_root_path
    click_link 'Agreements'

    page.uncheck('framework_status_published')
    find('#framework-status-filter-submit').click

    expect(page).to have_text('RM5679')
    expect(page).to have_text('Vehicle Purchase Framework 2')
    expect(page).not_to have_text('RM5678')
    expect(page).not_to have_text('Vehicle Purchase Framework 1')

    page.check('framework_status_archived')
    find('#framework-status-filter-submit').click

    expect(page).to have_text('RM5789')
    expect(page).to have_text('Archived framework')
  end
end
