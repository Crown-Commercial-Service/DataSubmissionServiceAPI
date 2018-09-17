require 'rails_helper'

RSpec.describe Export::Submissions::Extract do
  describe '.all_relevant' do
    subject(:all_relevant) { Export::Submissions::Extract.all_relevant }

    context 'there are some relevant and some non-relevant submissions' do
      let(:relevant_submission1)  { create :no_business_submission } # Complete by definition
      let(:relevant_submission2)  { create :submission, aasm_state: 'validation_failed' }
      let(:irrelevant_submission) { create :submission, aasm_state: 'pending' }

      it 'returns the relevant submissions only' do
        expect(all_relevant).to match_array([relevant_submission1, relevant_submission2])
      end
    end

    context 'there are no-business submissions and submissions with business' do
      let(:no_business_submission) { create :no_business_submission } # Complete by definition
      let(:file_submission) do
        create :submission_with_validated_entries,
               aasm_state: 'completed'
      end

      subject(:extract_no_business_submission) { all_relevant.find { |sub| sub.id == no_business_submission.id } }
      subject(:extract_file_submission)        { all_relevant.find { |sub| sub.id == file_submission.id } }

      before { expect(all_relevant).to match_array([no_business_submission, file_submission]) }

      describe '#_order_entry_count as a projection on the Submission model' do
        it 'is 0 on the no-business and 1 on the file' do
          expect(extract_no_business_submission._order_entry_count).to be_zero
          expect(extract_file_submission._order_entry_count).to eql(1)
        end
      end

      describe '#_invoice_entry_count as a projection on the Submission model' do
        it 'is 0 on the no-business and 2 on the file' do
          expect(extract_no_business_submission._invoice_entry_count).to be_zero
          expect(extract_file_submission._invoice_entry_count).to eql(2)
        end
      end
    end
  end
end
