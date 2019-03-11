require 'rails_helper'

RSpec.describe Task do
  it { is_expected.to validate_presence_of(:status) }

  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:supplier) }

  it { is_expected.to have_many(:submissions) }

  it "defaults to an 'unstarted' state" do
    expect(Task.new.status).to eq 'unstarted'
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
      submission_time = Time.zone.local(2018, 1, 10, 12, 13, 14)

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
end
