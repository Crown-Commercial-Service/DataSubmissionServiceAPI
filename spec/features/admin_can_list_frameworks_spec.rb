require 'rails_helper'

RSpec.feature 'Admin can list frameworks' do
  before do
    # Given that I am logged in as an admin
    sign_in_as_admin
  end

  scenario 'There are some published and unpublished frameworks' do
    # And there are some published frameworks
    FactoryBot.create(:framework, name: 'Laundry Framework 1', short_name: 'RM1234')
    FactoryBot.create(:framework, name: 'Vehicle Purchase Framework 1', short_name: 'RM5678')
    # And there are some unpublished frameworks
    FactoryBot.create(:framework, published: false, name: 'Vehicle Purchase Framework 2', short_name: 'RM5679')

    # When I click the "frameworks" link from the main admin page
    visit admin_root_path
    click_link 'Frameworks'

    # Then I should see a list of frameworks with their statuses
    within 'tbody > tr:nth-child(1)' do
      expect(page).to have_text('RM1234')
      expect(page).to have_text('Laundry Framework 1')
      expect(page).to have_text('Published')
    end

    within 'tbody > tr:nth-child(2)' do
      expect(page).to have_text('RM5678')
      expect(page).to have_text('Vehicle Purchase Framework 1')
      expect(page).to have_text('Published')
    end

    within 'tbody > tr:nth-child(3)' do
      expect(page).to have_text('RM5679')
      expect(page).to have_text('Vehicle Purchase Framework 2')
      expect(page).to have_text('New')
    end
  end
end
