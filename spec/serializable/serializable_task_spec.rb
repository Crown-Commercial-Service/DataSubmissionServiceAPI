require 'rails_helper'

RSpec.describe SerializableTask do
  context 'given a task with past submissions' do
    let(:user) { FactoryBot.create(:user) }
    let(:task) { FactoryBot.create(:task, status: :completed) }
    let(:old_submission) do
      FactoryBot.create(
        :submission_with_validated_entries,
        submitted_by: user,
        aasm_state: 'replaced',
        task: task
      )
    end

    it 'exposes past_submissions' do
      task.submissions << old_submission
      serialized_task = SerializableTask.new(object: task, include_past_submissions: true)

      expect(serialized_task.as_jsonapi[:attributes][:past_submissions][0][:id]).to include(old_submission.id)
    end
  end
end
