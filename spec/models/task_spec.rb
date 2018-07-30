require 'rails_helper'

RSpec.describe Task do
  it { is_expected.to validate_presence_of(:status) }

  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:supplier) }

  it { is_expected.to have_many(:submissions) }

  it "defaults to an 'unstarted' state" do
    expect(Task.new.status).to eq 'unstarted'
  end

  describe '.for_user_id' do
    it 'returns tasks for all suppliers that the current user is a member of' do
      user_id = SecureRandom.uuid

      users_supplier1 = FactoryBot.create(:supplier)
      users_supplier2 = FactoryBot.create(:supplier)
      other_supplier = FactoryBot.create(:supplier)

      FactoryBot.create(:membership, supplier: users_supplier1, user_id: user_id)
      FactoryBot.create(:membership, supplier: users_supplier2, user_id: user_id)

      task1 = FactoryBot.create(:task, supplier: users_supplier1)
      task2 = FactoryBot.create(:task, supplier: users_supplier2)
      task3 = FactoryBot.create(:task, supplier: other_supplier)

      tasks = Task.for_user_id(user_id)

      expect(tasks).to include(task1)
      expect(tasks).to include(task2)
      expect(tasks).to_not include(task3)
    end
  end

  describe '#latest_submission' do
    let(:task) { FactoryBot.create(:task) }

    it 'returns the most recent submission' do
      _old_submission = FactoryBot.create(:submission, task: task)

      travel 1.day do
        latest_submission = FactoryBot.create(:submission, task: task)

        expect(task.latest_submission).to eq latest_submission
      end
    end
  end

  describe '#file_no_business!' do
    let(:task) { FactoryBot.create(:task) }

    it 'creates an empty completed submission' do
      expect { task.file_no_business! }.to change { task.submissions.count }.by 1

      submission = task.latest_submission

      expect(submission).to be_completed
      expect(submission.entries).to be_empty
    end

    it 'transitions the task to "completed"' do
      task.file_no_business!
      expect(task.reload).to be_completed
    end
  end
end
