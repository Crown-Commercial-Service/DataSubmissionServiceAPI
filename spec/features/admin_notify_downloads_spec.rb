require 'rails_helper'

RSpec.feature 'Admin Downloads section' do
  around do |example|
    travel_to Date.new(2018, 12, 9) do
      example.run
    end
  end

  before do
    sign_in_as_admin
  end

  scenario 'admin user downloads Customer Effort Scores CSV' do
    click_on 'Downloads'

    fill_in 'dd-from', with: '15'
    fill_in 'mm-from', with: '1'
    fill_in 'yyyy-from', with: '2018'
    fill_in 'dd-to', with: '1'
    fill_in 'mm-to', with: '8'
    fill_in 'yyyy-to', with: '2018'

    click_on('Download CSV', match: :first)

    expect(page.response_headers['Content-Disposition']).to match(/^attachment/)
    expect(page.response_headers['Content-Disposition']).to match('filename="customer_effort_scores-2018-01-15-' \
      '2018-08-01.csv"')
    expect(page.body).to include 'user id,rating,comments,date'
  end

  scenario 'admin user inputs invalid dates for Customer Effort Scores CSV' do
    click_on 'Downloads'

    fill_in 'dd-from', with: ''
    fill_in 'mm-from', with: '1'
    fill_in 'yyyy-from', with: '2018'
    fill_in 'dd-to', with: '1'
    fill_in 'mm-to', with: '8'
    fill_in 'yyyy-to', with: '2018'

    click_on('Download CSV', match: :first)

    expect(page.body).to include 'Please provide valid dates'
  end

  scenario 'admin user inputs dates in incorrect order for Customer Effort Scores CSV' do
    click_on 'Downloads'

    fill_in 'dd-from', with: '1'
    fill_in 'mm-from', with: '8'
    fill_in 'yyyy-from', with: '2018'
    fill_in 'dd-to', with: '15'
    fill_in 'mm-to', with: '1'
    fill_in 'yyyy-to', with: '2018'

    click_on('Download CSV', match: :first)

    expect(page.body).to include '&#39;From&#39; date must be before &#39;To&#39; date and &#39;To&#39; date' \
    ' cannot be in the future'
  end

  scenario 'admin user inputs future "To" date for Customer Effort Scores CSV' do
    click_on 'Downloads'

    fill_in 'dd-from', with: '15'
    fill_in 'mm-from', with: '1'
    fill_in 'yyyy-from', with: '2018'
    fill_in 'dd-to', with: '12'
    fill_in 'mm-to', with: '12'
    fill_in 'yyyy-to', with: '2018'

    click_on('Download CSV', match: :first)

    expect(page.body).to include '&#39;From&#39; date must be before &#39;To&#39; date and &#39;To&#39; date' \
    ' cannot be in the future'
  end

  scenario 'admin user downloads Notify CSV' do
    click_on 'Downloads'

    within '#notify-download-late' do
      click_on 'Download CSV'

      expect(page.response_headers['Content-Disposition']).to match(/^attachment/)
      expect(page.response_headers['Content-Disposition']).to include 'late_notifications-2018-12-09.csv'
      expect(page.body).to include 'email address,due_date,person_name'
    end
  end
end
