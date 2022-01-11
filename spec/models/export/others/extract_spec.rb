require 'rails_helper'

RSpec.describe Export::Others::Extract do
  describe '.all_relevant' do
    subject(:all_relevant) { Export::Others::Extract.all_relevant }

    context 'there are some complete and incomplete submissions, all with valid entries' do
      let!(:complete_submission) do
        create :submission_with_validated_entries, aasm_state: 'completed'
      end
      let!(:pending_submission) do
        create :submission_with_validated_entries
      end

      it 'contains only others from the complete submission' do
        expect(all_relevant.to_a.length).to be.positive?
        expect(all_relevant.map(&:entry_type)).to all(eql('other'))
        expect(all_relevant.map(&:submission_id)).to all(eql(complete_submission.id))
      end

      it 'projects a _framework_short_name field onto every other' do
        expect(all_relevant.map(&:_framework_short_name)).to all(eql(complete_submission.framework.short_name))
      end
    end

    context 'with a date range provided' do
      let!(:submission) do
        create(:submission, aasm_state: 'completed', updated_at: 2.days.ago) do |submission|
          submission.entries << create(:other_entry)
        end
      end
      let(:date_range) { 1.day.ago..1.minute.from_now }

      it 'only includes others whose submissions were updated during the range' do
        all_relevant = Export::Others::Extract.all_relevant(date_range)
        expect(all_relevant).not_to match_array submission.entries

        # rubocop:disable Rails/SkipsModelValidations
        submission.touch
        # rubocop:enable Rails/SkipsModelValidations

        all_relevant = Export::Others::Extract.all_relevant(date_range)
        expect(all_relevant).to match_array submission.entries
      end
    end
  end
end
