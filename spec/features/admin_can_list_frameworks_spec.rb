require 'rails_helper'

RSpec.feature 'Admin can list frameworks' do

  before do
    # Given that I am logged in as an admin
    sign_in_as_admin
  end

  scenario 'There are some frameworks' do
    # And there are some frameworks
    FactoryBot.create(:framework, name: 'Laundry Framework 1', short_name: 'RM1234')
    FactoryBot.create(:framework, name: 'Vehicle Purchase Framework 1', short_name: 'RM5678')

    # When I click the "frameworks" link from the main admin page
    visit admin_root_path
    click_link 'Frameworks'

    # Then I should see a list of frameworks
    expect(page).to have_text('Laundry Framework 1')
    expect(page).to have_text('Vehicle Purchase Framework 1')
    # And the frameworks' statuses
    expect(page).to have_text('Published', count: 2)
  end
end

