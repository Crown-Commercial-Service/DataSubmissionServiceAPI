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

  scenario 'admin user downloads a recent notification report' do
    batch = create(
      :notification_batch,
      notification_type: 'due',
      period_month: 11,
      period_year: 2018,
      started_at: 1.day.ago
    )

    create(
      :notification_delivery,
      :delivered,
      notification_batch: batch,
      email: 'user@example.com',
      supplier_name: 'Test Supplier'
    )

    click_on 'Downloads'

    within "#notification-report-#{batch.id}" do
      expect(page).to have_content 'Due'
      expect(page).to have_content 'November 2018'
      expect(page).to have_content '8 December 2018'

      click_on 'Download report'
    end

    expect(page.response_headers['Content-Disposition']).to match(/^attachment/)
    expect(page.response_headers['Content-Disposition']).to include(
      'due_notification_report_2018-12-08.csv'
    )

    expect(page.body).to include(
      'email address,supplier name,status,sent at,completed at,notify id,error'
    )

    expect(page.body).to include 'user@example.com,Test Supplier,delivered'
  end

  scenario 'admin user only sees notification reports from the last 30 days' do
    recent_batch = create(
      :notification_batch,
      notification_type: 'due',
      started_at: 29.days.ago,
      created_at: 29.days.ago
    )

    expired_batch = create(
      :notification_batch,
      notification_type: 'due',
      started_at: 31.days.ago,
      created_at: 31.days.ago
    )

    click_on 'Downloads'

    expect(page).to have_css(
      "#notification-report-#{recent_batch.id}"
    )

    expect(page).not_to have_css(
      "#notification-report-#{expired_batch.id}"
    )
  end
end
