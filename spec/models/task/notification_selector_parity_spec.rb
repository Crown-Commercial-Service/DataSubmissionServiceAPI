require 'rails_helper'
require 'csv'
require 'stringio'

RSpec.describe 'Notification selector parity' do
  let(:month) { 9 }
  let(:year) { 2026 }

  before { stub_govuk_bank_holidays_request }

  def csv_emails(csv_text)
    CSV.parse(csv_text, headers: true).map { |row| row['email address'] }.sort
  end

  def selector_emails(selector)
    selector.map { |notification| notification[:email] }.sort
  end

  def csv_notifications(csv_text)
    CSV.parse(csv_text, headers: true).map do |row|
      {
        email: row['email address'],
        person_name: row['person_name'],
        supplier_name: row['supplier_name'],
        due_date: row['due_date'],
        reporting_month: row['reporting_month'],
        frameworks: row.fields.drop(5).compact.sort
      }
    end
  end

  def selector_notifications(selector)
    selector.map do |notification|
      personalisation = notification.fetch(:personalisation)

      {
        email: notification.fetch(:email),
        person_name: personalisation.fetch(:person_name),
        supplier_name: notification.fetch(:supplier_name),
        due_date: personalisation.fetch(:due_date),
        reporting_month: personalisation.fetch(:reporting_month),
        frameworks: Array(personalisation.fetch(:framework)).sort
      }
    end
  end

  def unfinished_csv_notifications(csv_text)
    CSV.parse(csv_text, headers: true).map do |row|
      {
        email: row['email address'],
        task_period: row['task_period'],
        person_name: row['person_name'],
        supplier_name: row['supplier_name'],
        task_name: row['task_name'],
        submission_date: row['submission_date'],
        validation_failed: row['validation_failed'],
        ingest_failed: row['ingest_failed'],
        in_review: row['in_review']
      }
    end
  end

  def unfinished_selector_notifications(selector)
    selector.map do |notification|
      personalisation = notification.fetch(:personalisation)

      {
        email: notification.fetch(:email),
        task_period: personalisation.fetch(:task_period),
        person_name: personalisation.fetch(:person_name),
        supplier_name: notification.fetch(:supplier_name),
        task_name: personalisation.fetch(:task_name),
        submission_date: personalisation.fetch(:submission_date),
        validation_failed: personalisation.fetch(:validation_failed),
        ingest_failed: personalisation.fetch(:ingest_failed),
        in_review: personalisation.fetch(:in_review),
      }
    end
  end

  context 'anticipated notifications' do
    let(:alice) { FactoryBot.create(:user, name: 'Alice Example', email: 'alice@example.com') }
    let(:bob) { FactoryBot.create(:user, name: 'Bob Example', email: 'bob@example.com') }
    let(:frank) { FactoryBot.create(:user, :inactive, name: 'Frank Inactive', email: 'frank.inactive@example.com') }

    before do
      supplier_a = FactoryBot.create(:supplier, name: 'Supplier A')
      supplier_b = FactoryBot.create(:supplier, name: 'Supplier B')
      supplier_c = FactoryBot.create(:supplier, name: 'Inactive Supplier')

      FactoryBot.create(:membership, user: alice, supplier: supplier_a)
      FactoryBot.create(:membership, user: bob, supplier: supplier_b)
      FactoryBot.create(:membership, user: frank, supplier: supplier_a)
      FactoryBot.create(:membership, user: alice, supplier: supplier_c)

      framework1 = FactoryBot.create(:framework, short_name: 'RM001', name: 'Framework 1')
      framework2 = FactoryBot.create(:framework, short_name: 'RM002', name: 'Framework 2')

      supplier_a.agreements.create!(framework: framework1)
      supplier_b.agreements.create!(framework: framework1)
      supplier_b.agreements.create!(framework: framework2)
      supplier_c.agreements.create!(framework: framework1, active: false)
    end

    it 'matches the anticipated CSV recipients' do
      output = StringIO.new

      Task::AnticipatedUserNotificationList.new(month: month, year: year, output: output).generate

      notifications = Task::UserNotificationRecipients.new(month: month, year: year, type: :anticipated)

      expected_emails = csv_emails(output.string)
      actual_emails = selector_emails(notifications)

      expect(expected_emails).to contain_exactly(
        'alice@example.com',
        'bob@example.com'
      )
      expect(actual_emails).to eq(expected_emails)
    end

    it 'matches the anticipated CSV personalisation' do
      output = StringIO.new

      Task::AnticipatedUserNotificationList.new(month: month, year: year, output: output).generate

      notifications = Task::UserNotificationRecipients.new(month: month, year: year, type: :anticipated)

      expected = csv_notifications(output.string)
      actual = selector_notifications(notifications)

      expect(actual).to match_array(expected)
    end
  end

  context 'unfinished notifications' do
    let(:supplier) { create(:supplier, name: 'Supllier A') }
    let(:framework) do
      create(:framework, short_name: 'RM001', name: 'Framework 1')
    end

    let(:alice) do
      create(:user, name: 'Alice Example', email: 'alice@example.com')
    end

    let(:task) do
      create(
        :task,
        supplier: supplier,
        framework: framework,
        period_month: 9,
        period_year: 2026,
        status: 'in_progress'
      )
    end

    let!(:submission) do
      create(
        :submission,
        task: task,
        supplier: supplier,
        framework: framework,
        aasm_state: 'ingest_failed'
      )
    end

    before do
      create(:membership, user: alice, supplier: supplier)
    end

    it 'matches the unfinished CSV recipients' do
      output = StringIO.new

      Task::UnfinishedUserNotificationList.new(output: output).generate

      notifications = Task::UnfinishedUserNotifications.new

      expected_emails = csv_emails(output.string)
      actual_emails = selector_emails(notifications)

      expect(expected_emails).to contain_exactly('alice@example.com')
      expect(actual_emails).to eq(expected_emails)
    end

    it 'matches the unfinished CSV personalisation' do
      output = StringIO.new

      Task::UnfinishedUserNotificationList.new(output: output).generate

      notifications = Task::UnfinishedUserNotifications.new

      expected = unfinished_csv_notifications(output.string)
      actual = unfinished_selector_notifications(notifications)

      expect(expected).not_to be_empty
      expect(actual).to eq(expected)
    end
  end

  context 'overdue and late notifications' do
    let(:month) { 9 }
    let(:year) { 2026 }

    let(:supplier) { create(:supplier, name: 'Supllier A') }
    let(:framework) { create(:framework, short_name: 'RM001', name: 'Framework 1') }
    let(:alice) { create(:user, name: 'Alice Example', email: 'alice@example.com') }

    let!(:task) do
      create(
        :task,
        supplier: supplier,
        framework: framework,
        period_month: month,
        period_year: year,
        status: 'in_progress'
      )
    end

    before do
      create(:membership, user: alice, supplier: supplier)
    end

    %w[overdue late].each do |notification_type|
      context "#{notification_type} notifications" do
        let(:csv_output) do
          output = StringIO.new

          Task::OverdueUserNotificationList.new(
            month: month,
            year: year,
            output: output
          ).generate

          output.string
        end

        let(:notifications) do
          Task::UserNotificationRecipients.new(
            month: month,
            year: year,
            type: :incomplete
          )
        end

        it 'matches CSV recipients' do
          expected = csv_emails(csv_output)
          actual = selector_emails(notifications)

          expect(expected).to contain_exactly('alice@example.com')
          expect(actual).to match_array(expected)
        end

        it 'matches the CSV personalisation' do
          expected = csv_notifications(csv_output)
          actual = selector_notifications(notifications)

          expect(expected).not_to be_empty
          expect(actual).to match_array(expected)
        end
      end
    end
  end
end
