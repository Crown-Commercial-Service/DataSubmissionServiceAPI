require 'rails_helper'

RSpec.describe Task::UnfinishedUserNotifications do
  subject(:notifications) { described_class.new.to_a }

  let(:supplier) { FactoryBot.create(:supplier, name: 'Supplier A') }
  let(:user) { FactoryBot.create(:user, name: 'Alice Example', email: 'alice@example.com', suppliers: [supplier]) }

  let(:task) do
    FactoryBot.create(
      :task,
      supplier: supplier,
      period_month: 9,
      period_year: 2026,
      status: 'in_progress'
    )
  end

  let(:submission) do
    FactoryBot.create(
      :submission,
      task: task,
      supplier: supplier,
      framework: task.framework,
      aasm_state: 'ingest_failed'
    )
  end

  before do
    user
    submission
  end

  it 'debugs the unfinished notifications setup' do
    Task.incomplete
        .joins(:submissions)
        .merge(
          Submission.where(
            aasm_state: %w[
              validation_failed
              ingest_failed
              in_review
            ]
          )
        )
  end

  it 'includes an active user with an unfinished submission' do
    expect(notifications.map { |n| n[:email] }).to include('alice@example.com')
  end

  it 'provides the Notify personalisation fields' do
    personalisation = notifications.first.fetch(:personalisation)

    expect(personalisation).to include(
      task_period: 'September 2026',
      person_name: 'Alice Example',
      supplier_name: 'Supplier A',
      task_name: "#{task.framework.short_name} - #{task.framework.name} - September 2026",
      submission_date: submission.updated_at.strftime('%d/%m/%Y'),
      validation_failed: 'n',
      ingest_failed: 'y',
      in_review: 'n'
    )
  end

  %w[validation_failed ingest_failed in_review].each do |status|
    context "when the submission status is '#{status}'" do
      before do
        submission.update!(aasm_state: status)
      end

      it 'sets the correct status flags' do
        personalisation = notifications.first.fetch(:personalisation)

        %w[validation_failed ingest_failed in_review].each do |flag|
          expected_value = flag == status ? 'y' : 'n'
          expect(personalisation[flag.to_sym]).to eq(expected_value)
        end
      end
    end
  end

  context 'when the user is inactive' do
    before do
      user.update!(auth_id: nil)
    end

    it 'does not include the inactive user' do
      expect(notifications.map { |n| n[:email] }).not_to include(user.email)
    end
  end

  context 'when the task is completed' do
    before do
      task.update!(status: 'completed')
    end

    it 'does not include the user for a completed task' do
      expect(notifications).to be_empty
    end
  end

  context 'when the user has two qualifying tasks' do
    let(:second_task) do
      FactoryBot.create(
        :task,
        supplier: supplier,
        period_month: 8,
        period_year: 2026,
        status: 'in_progress'
      )
    end

    before do
      create(
        :submission,
        task: second_task,
        supplier: supplier,
        framework: second_task.framework,
        aasm_state: 'in_review'
      )
    end

    it 'creates one notification per task for the user' do
      user_notifications = notifications.select { |n| n[:email] == user.email }

      expect(user_notifications.size).to eq(2)
      expect(user_notifications.map { |n| n[:personalisation][:task_period] })
        .to contain_exactly('September 2026', 'August 2026')
    end
  end

  context 'when a task has multiple submissions' do
    let(:newer_submission) do
      FactoryBot.create(
        :submission,
        task: task,
        supplier: supplier,
        framework: task.framework,
        aasm_state: 'in_review'
      )
    end

    before do
      submission.update!(
        created_at: 2.days.ago,
        updated_at: 2.days.ago
      )

      newer_submission.update!(
        created_at: 1.day.ago,
        updated_at: 1.day.ago
      )
    end

    it 'uses the most recent submission for personalisation' do
      expect(task.reload.latest_submission.id).to eq(newer_submission.id)
      personalisation = notifications.first.fetch(:personalisation)

      expect(personalisation[:submission_date]).to eq(newer_submission.updated_at.strftime('%d/%m/%Y'))
      expect(personalisation[:validation_failed]).to eq('n')
      expect(personalisation[:ingest_failed]).to eq('n')
      expect(personalisation[:in_review]).to eq('y')
    end
  end
end
