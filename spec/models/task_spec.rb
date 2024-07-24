require 'rails_helper'

RSpec.describe Task do
  it { is_expected.to validate_presence_of(:status) }

  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:supplier) }

  it { is_expected.to have_many(:submissions) }

  it "defaults to an 'unstarted' state" do
    expect(Task.new.status).to eq 'unstarted'
  end

  describe '.within_date_range' do
    it 'returns tasks within a given date range' do
      task1 = create(:task, period_year: 2023, period_month: 5)
      task2 = create(:task, period_year: 2023, period_month: 6)
      task3 = create(:task, period_year: 2023, period_month: 7)

      date_range = [Date.new(2023, 5, 1), Date.new(2023, 6, 1)]

      tasks = Task.within_date_range(date_range)
      expect(tasks).to include(task1, task2)
      expect(tasks).not_to include(task3)
    end
  end

  describe '#active_submission' do
    let(:task) { FactoryBot.create(:task) }
    let(:task2) { FactoryBot.create(:task) }
    let!(:unrelated_submission) { FactoryBot.create(:submission, task: task2, aasm_state: 'completed') }

    context 'there is no completed submission' do
      let!(:old_submission) { FactoryBot.create(:submission, task: task, created_at: 2.days.ago) }
      let!(:new_submission) { FactoryBot.create(:submission, task: task, created_at: 1.day.ago) }

      it 'returns the most recent submission' do
        expect(task.active_submission).to eq(new_submission)
      end
    end

    context 'there is a completed submission that is not the most recent' do
      let!(:old_submission) { FactoryBot.create(:submission, task: task, created_at: 3.days.ago) }
      let!(:completed_submission) do
        FactoryBot.create(:submission, task: task, created_at: 2.days.ago, aasm_state: 'completed')
      end
      let!(:new_submission) { FactoryBot.create(:submission, task: task, created_at: 1.day.ago) }

      it 'returns the completed submission' do
        expect(task.active_submission).to eq(completed_submission)
      end
    end

    it 'can be preloaded as part of another association query' do
      expect(Task.where(id: task.id, period_year: task.period_year).includes(:active_submission)).to eq [task]
    end
  end

  describe '#file_no_business!' do
    let(:task) { FactoryBot.create(:task) }
    let(:user) { FactoryBot.create(:user) }

    it 'creates an empty completed submission' do
      expect { task.file_no_business!(user) }.to change { task.submissions.count }.by 1

      submission = task.active_submission

      expect(submission).to be_completed
      expect(submission.entries).to be_empty
    end

    it 'transitions the task to "completed"' do
      task.file_no_business!(user)
      expect(task.reload).to be_completed
    end

    it 'records the user who created the submission' do
      task.file_no_business!(user)
      submission = task.active_submission

      expect(submission.created_by).to eq(user)
    end

    it 'records the user who completed the submission' do
      task.file_no_business!(user)
      submission = task.active_submission

      expect(submission.submitted_by).to eq(user)
    end

    it 'records the submission time' do
      submission_time = Time.zone.local(2018, 2, 10, 12, 13, 14)

      travel_to(submission_time) do
        task.file_no_business!(user)
        submission = task.active_submission

        expect(submission.submitted_at).to eq(submission_time)
      end
    end
  end

  describe '#period_date' do
    it 'returns a date for the task’s period' do
      task = Task.new(period_year: 2020, period_month: 5)
      expect(task.period_date).to eq Date.new(2020, 5, 1)
    end
  end

  describe '#incomplete?' do
    let(:known_incomplete_states) { %i[unstarted in_progress] }
    let(:all_states) { Task.aasm.states.map(&:name) }

    it 'returns true for the known "incomplete" states' do
      all_states.each do |state|
        if known_incomplete_states.include?(state)
          expect(Task.new(status: state)).to be_incomplete
        else
          expect(Task.new(status: state)).not_to be_incomplete
        end
      end
    end
  end

  describe '#cancel_correction!' do
    context 'For a task that is `correcting`' do
      let(:task) { FactoryBot.create(:task, status: :correcting) }
      it 'calls destroy_incomplete_correction_submissions and updates status to completed' do
        expect(task).to receive(:destroy_incomplete_correction_submissions)
        task.cancel_correction!
        expect(task.status).to eq('completed')
      end
    end
    context 'For a task that is `completed`' do
      let(:task) { FactoryBot.create(:task, status: :completed) }
      it 'raises error, does not call destroy_incomplete_correction_submissions and retains status' do
        expect(task).to_not receive(:destroy_incomplete_correction_submissions)
        expect { task.cancel_correction! }.to raise_error(AASM::InvalidTransition)
        expect(task.status).to eq('completed')
      end
    end
  end

  describe '#destroy_incomplete_correction_submissions' do
    let(:task) { FactoryBot.create(:task, status: :correcting) }
    let!(:oldest_submission_invalid) do
      FactoryBot.create(:submission,
                        task: task,
                        created_at: 6.days.ago,
                        aasm_state: 'validation_failed')
    end
    let!(:oldest_submission_completed) do
      FactoryBot.create(:submission,
                        task: task,
                        created_at: 5.days.ago,
                        aasm_state: 'replaced')
    end
    let!(:old_submission_invalid) do
      FactoryBot.create(:submission,
                        task: task,
                        created_at: 4.days.ago,
                        aasm_state: 'validation_failed')
    end
    let!(:old_submission_completed) do
      FactoryBot.create(:completed_submission,
                        task: task,
                        created_at: 3.days.ago,
                        aasm_state: 'completed')
    end
    let!(:correction_submission_invalid) do
      FactoryBot.create(:submission_with_invalid_entries,
                        task: task,
                        created_at: 2.days.ago)
    end
    let!(:correction_submission_in_review) do
      FactoryBot.create(:submission_with_validated_entries,
                        task: task,
                        created_at: 1.day.ago,
                        aasm_state: 'in_review')
    end

    it 'destroys all submissions created after the active submission' do
      task.destroy_incomplete_correction_submissions
      task.reload
      expect(Submission.exists?(oldest_submission_invalid.id)).to be true
      expect(Submission.exists?(oldest_submission_completed.id)).to be true
      expect(Submission.exists?(old_submission_invalid.id)).to be true
      expect(Submission.exists?(old_submission_completed.id)).to be true
      expect(Submission.exists?(correction_submission_invalid.id)).to be false
      expect(Submission.exists?(correction_submission_in_review.id)).to be false
    end
  end

  describe '#set_due_on' do
    it 'sets a default due on date from month and date if not set yet' do
      stub_govuk_bank_holidays_request
      task = FactoryBot.create(:task, due_on: nil, period_month: 1, period_year: 2019)
      expect(task.due_on).to eq(Date.new(2019, 2, 7))
    end

    it "doesn't overwrite a set due_on" do
      task = FactoryBot.create(:task, due_on: Date.new(2019, 3, 9), period_month: 1, period_year: 2019)
      expect(task.due_on).to eq(Date.new(2019, 3, 9))
    end
  end
end
