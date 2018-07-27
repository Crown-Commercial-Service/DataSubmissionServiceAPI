require 'rails_helper'

RSpec.describe SubmissionCompletion do
  describe '#perform' do
    let(:complete_submission) { SubmissionCompletion.new(submission) }

    context 'given an "in review" submission' do
      context 'with validated entries' do
        let(:submission) { FactoryBot.create(:submission_with_validated_entries, aasm_state: 'in_review') }

        it 'transitions the submission to completed' do
          complete_submission.perform!

          expect(submission).to be_completed
        end
      end

      context 'with some invalid entries' do
        let(:submission) { FactoryBot.create(:submission_with_invalid_entries) }

        it 'leaves the submission in the "in_review" state' do
          expect { complete_submission.perform! }.not_to change { submission.aasm_state }
        end
      end
    end

    context 'given a "processing" submission' do
      let(:submission) { FactoryBot.create(:submission_with_unprocessed_entries, aasm_state: :processing) }

      it 'leaves the submission in its current state' do
        expect { complete_submission.perform! }.not_to change { submission.aasm_state }
      end
    end
  end
end
