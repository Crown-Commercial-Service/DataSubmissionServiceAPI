require 'rails_helper'

RSpec.describe Export::Submissions::Row do
  let(:row) { Export::Submissions::Row.new(submission) }

  describe '#status' do
    subject!(:status) { row.status }

    context 'the submission state is completed' do
      let(:submission) { build_stubbed :submission, aasm_state: 'completed' }
      it { is_expected.to eql('supplier_accepted') }
    end

    context 'the submission state is validation_failed' do
      let(:submission) { build_stubbed :submission, aasm_state: 'validation_failed' }
      it { is_expected.to eql('validation_failed') }
    end

    context 'the submission state is not one that should be in the output at all' do
      let(:submission) { build_stubbed :submission, aasm_state: 'in_review' }
      it { is_expected.to eql('#ERROR') }

      it 'adds the error to a hash' do
        expect(row.errors['Status']).to eql(['in_review is not mapped to Submission column Status'])
      end
    end
  end
end
