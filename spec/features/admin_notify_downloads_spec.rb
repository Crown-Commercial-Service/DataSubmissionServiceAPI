require 'rails_helper'

RSpec.feature 'Admin Notify downloads section' do
  around do |example|
    travel_to Date.new(2018, 12, 9) do
      example.run
    end
  end

  before do
    sign_in_as_admin
  end

  scenario 'admin user downloads Notify CSV' do
    click_on 'Notify downloads'

    within '#notify-download-late' do
      click_on 'Download CSV'

      expect(page.response_headers['Content-Disposition']).to match(/^attachment/)
      expect(page.response_headers['Content-Disposition']).to match(/filename="late_notifications-2018-12-09.csv"$/)
      expect(page.body).to include 'email address,due_date,person_name'
    end
  end
end
