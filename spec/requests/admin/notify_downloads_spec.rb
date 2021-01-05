require 'rails_helper'

RSpec.describe 'Admin Notify Downloads', type: :request do
  include SingleSignOnHelpers

  before do
    stub_govuk_bank_holidays_request
    mock_sso_with(email: 'admin@example.com')
    get '/auth/google_oauth2/callback'
  end

  describe '#index' do
    it 'lists the available Notify downloads' do
      get admin_notify_downloads_path

      expect(response).to be_successful
      expect(response.body).to include('Notify downloads')
      expect(response.body).to include('Management information is overdue')
      expect(response.body).to include(admin_notify_download_path(:overdue))
      expect(response.body).to include('Management information is late')
      expect(response.body).to include(admin_notify_download_path(:late))
      expect(response.body).to include('Management information submission is unfinished')
      expect(response.body).to include(admin_notify_download_path(:unfinished))
    end
  end

  describe '#show when there are incomplete tasks' do
    let(:reporting_period) { Date.new(2019, 2, 1) }
    let(:due_date) { reporting_period + 1.month + 7.days }
    let(:after_due_date) { due_date + 1.day }

    around do |example|
      travel_to after_due_date do
        example.run
      end
    end

    before do
      user = FactoryBot.create(:user, name: 'User A')
      supplier = FactoryBot.create(:supplier, name: 'Supplier A')

      FactoryBot.create :membership, user: user, supplier: supplier
      FactoryBot.create(
        :task,
        supplier: supplier,
        period_month: reporting_period.month,
        period_year: reporting_period.year,
        due_on: due_date
      )
    end

    context 'when requesting the "overdue" notifications' do
      it 'returns a "overdue" notifications CSV file, with today’s date in the filename' do
        get admin_notify_download_path(:overdue)

        expect(response).to be_successful
        expect(response.header['Content-Type']).to include 'text/csv'
        expect(response.header['Content-Disposition'])
          .to eq 'attachment; filename="overdue_notifications-2019-03-09.csv"'
        expect(response.body).to include 'email address,due_date,person_name'
        expect(response.body).to include 'User A'
      end
    end

    context 'when requesting the "late" notifications' do
      it 'returns a "late" notifications CSV file, with today’s date in the filename' do
        get admin_notify_download_path(:late)

        expect(response).to be_successful
        expect(response.header['Content-Type']).to include 'text/csv'
        expect(response.header['Content-Disposition']).to eq 'attachment; filename="late_notifications-2019-03-09.csv"'
        expect(response.body).to include 'email address,due_date,person_name'
        expect(response.body).to include 'User A'
      end
    end
  end

  describe '#show for :due tasks' do
    let(:current_date) { Date.new(2018, 2, 27) }
    let(:next_period) { Date.new(2018, 3, 1) }

    around do |example|
      travel_to current_date do
        example.run
      end
    end

    before do
      user = FactoryBot.create(:user, name: 'User A')
      supplier = FactoryBot.create(:supplier, name: 'Supplier A')
      framework = FactoryBot.create(:framework, short_name: 'RX123')
      FactoryBot.create :membership, user: user, supplier: supplier
      supplier.agreements.create!(framework: framework)
    end

    it 'returns the "due" notifications CSV file, with today’s date in the filename' do
      get admin_notify_download_path(:due)

      expect(response).to be_successful
      expect(response.header['Content-Type']).to include 'text/csv'
      expect(response.header['Content-Disposition']).to eq 'attachment; filename="due_notifications-2018-02-27.csv"'
      expect(response.body).to include 'email address,due_date,person_name'
      expect(response.body).to include 'User A'
      expect(response.body).to include ',February 2018,'
      expect(response.body).to include ',7 March 2018,'
    end
  end

  describe '#show when there are unfinished submissions' do
    let(:reporting_period_a) { Date.new(2019, 2, 1) }
    let(:reporting_period_b) { Date.new(2019, 3, 1) }
    let(:due_date_a) { reporting_period_a + 1.month + 7.days }
    let(:due_date_b) { reporting_period_b + 1.month + 7.days }
    let(:download_date) { due_date_b + 1.day }

    around do |example|
      travel_to download_date do
        example.run
      end
    end

    before do
      user = FactoryBot.create(:user, name: 'User A')
      supplier = FactoryBot.create(:supplier, name: 'Supplier A')

      FactoryBot.create :membership, user: user, supplier: supplier
      task_a = FactoryBot.create(
        :task,
        supplier: supplier,
        period_month: reporting_period_a.month,
        period_year: reporting_period_a.year,
        due_on: due_date_a
      )
      task_b = FactoryBot.create(
        :task,
        supplier: supplier,
        period_month: reporting_period_b.month,
        period_year: reporting_period_b.year,
        due_on: due_date_b
      )
      FactoryBot.create(:submission_with_invalid_entries, supplier: supplier, task: task_a)
      FactoryBot.create(:submission_with_validated_entries, supplier: supplier, task: task_b)
    end

    it 'returns an "unfinished" notifications CSV file, with today’s date in the filename' do
      get admin_notify_download_path(:unfinished)

      expect(response).to be_successful
      expect(response.header['Content-Type']).to include 'text/csv'
      expect(response.header['Content-Disposition'])
        .to eq 'attachment; filename="unfinished_notifications-2019-04-09.csv"'
      expect(response.body).to include 'email address,person_name,supplier_name,task_name,validation_failed,ingest_failed,in_review'
      expect(response.body).to include 'February 2019,y,n,n'
      expect(response.body).to include 'March 2019,n,n,y'
    end
  end

  describe '#show for a non-existent download' do
    it 'returns a 404' do
      get admin_notify_download_path(:random)
      expect(response).to be_not_found
    end
  end
end
