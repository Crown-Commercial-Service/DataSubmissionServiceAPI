require 'rails_helper'

RSpec.describe Export::Submissions::Extract do
  describe '.all_relevant' do
    context 'there are some relevant and some non-relevant submissions' do
      let(:relevant_submission1)  { create :no_business_submission } # Complete by definition
      let(:relevant_submission2)  { create :submission, aasm_state: 'validation_failed' }
      let(:irrelevant_submission) { create :submission, aasm_state: 'pending' }

      subject(:all_relevant) { Export::Submissions::Extract.all_relevant }

      it 'returns the relevant submissions only' do
        expect(all_relevant).to match_array([relevant_submission1, relevant_submission2])
      end
    end
  end
end
