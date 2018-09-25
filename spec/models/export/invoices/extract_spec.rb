require 'rails_helper'

RSpec.describe Export::Invoices::Extract do
  describe '.all_relevant' do
    subject(:all_relevant) { Export::Invoices::Extract.all_relevant }

    context 'there are some complete and incomplete submissions, all with valid entries' do
      let!(:complete_submission) do
        create :submission_with_validated_entries, aasm_state: 'completed'
      end
      let!(:pending_submission) do
        create :submission_with_validated_entries
      end

      it 'contains only invoices from the complete submission' do
        expect(all_relevant.map(&:entry_type)).to all(eql('invoice'))
        expect(all_relevant.map(&:submission_id)).to all(eql(complete_submission.id))
      end
    end
  end
end
