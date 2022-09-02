require 'rails_helper'

RSpec.describe 'Admin Downloads', type: :request do
  include SingleSignOnHelpers

  before do
    stub_govuk_bank_holidays_request
    mock_sso_with(email: 'admin@example.com')
    get '/auth/google_oauth2/callback'
  end

  describe '#index' do
    it 'lists the available downloads' do
      get admin_downloads_path

      expect(response).to be_successful
      expect(response.body).to include('Downloads')
      expect(response.body).to include('Customer effort score download')
      expect(response.body).to include(new_admin_download_path)
      expect(response.body).to include('Notify downloads')
      expect(response.body).to include('Management information submission is unfinished')
      expect(response.body).to include(admin_download_path(:unfinished))
    end
  end

  describe '#new' do
    before do
      FactoryBot.create(:customer_effort_score)
    end

    context 'when valid dates provided' do
      let(:day_to) { Time.zone.now.strftime('%d') }
      let(:month_to) { Time.zone.now.strftime('%m') }
      let(:year_to) { Time.zone.now.year.to_s }
      let(:params) do
        {
          'dd_from' => '15',
          'mm_from' => '10',
          'yyyy_from' => '2021',
          'dd_to' => day_to,
          'mm_to' => month_to,
          'yyyy_to' => year_to
        }
      end

      it 'downloads a customer effort score CSV with dates in the filename' do
        get new_admin_download_path, params: params

        expect(response).to be_successful
        expect(response.header['Content-Type']).to eq 'text/csv'
        expect(response.header['Content-Disposition'])
          .to include "attachment; filename=\"customer_effort_scores-2021-10-15-#{year_to}-#{month_to}-#{day_to}.csv"
        expect(response.body).to include 'user id,rating,comments,date'
        expect(response.body).to include 'Perfect, no notes.'
      end
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
      FactoryBot.create(:submission_with_invalid_entries, supplier: supplier, task: task_a, created_by: user)
      FactoryBot.create(:submission_with_validated_entries, supplier: supplier, task: task_b, created_by: user)
    end

    it 'returns an "unfinished" notifications CSV file, with today’s date in the filename' do
      get admin_download_path(:unfinished)

      expect(response).to be_successful
      expect(response.header['Content-Type']).to include 'text/csv'
      expect(response.header['Content-Disposition'])
        .to eq 'attachment; filename="unfinished_notifications-2019-04-09.csv"'
      expect(response.body)
        .to include 'email address,task_period,person_name,supplier_name,task_name'
      expect(response.body)
        .to include 'validation_failed,ingest_failed,in_review'
      expect(response.body).to include 'February 2019,09/04/2019,y,n,n'
      expect(response.body).to include 'March 2019,09/04/2019,n,n,y'
    end
  end

  describe '#show for a non-existent download' do
    it 'returns a 404' do
      get admin_download_path(:random)
      expect(response).to be_not_found
    end
  end
end
