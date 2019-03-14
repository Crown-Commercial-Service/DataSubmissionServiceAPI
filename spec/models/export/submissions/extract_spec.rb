require 'rails_helper'

RSpec.describe Export::Submissions::Extract do
  describe '.all_relevant' do
    subject(:all_relevant) { Export::Submissions::Extract.all_relevant }

    context 'there are some relevant and some non-relevant submissions' do
      let!(:relevant_submission1)  { create :no_business_submission } # Complete by definition
      let!(:relevant_submission2)  { create :submission, aasm_state: 'validation_failed' }
      let!(:relevant_submission3)  { create :submission, aasm_state: 'replaced' }
      let!(:irrelevant_submission) { create :submission, aasm_state: 'pending' }

      it 'returns the relevant submissions only' do
        expect(all_relevant).to match_array([relevant_submission1, relevant_submission2, relevant_submission3])
      end
    end

    context 'there are no-business submissions and submissions with business' do
      let!(:no_business_submission) { create :no_business_submission } # Complete by definition
      let!(:file_submission) do
        create :submission_with_validated_entries,
               files: [
                 create(:submission_file, :with_attachment, filename: 'not-really-an.xls')
               ],
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

      describe '#_total_order_value as a projection on the Submission model' do
        it 'is nil on the no-business and 3.0 on the file' do
          expect(extract_no_business_submission._total_order_value).to be_nil
          expect(extract_file_submission._total_order_value.to_digits).to eql('3.0')
        end
      end

      describe '#_invoice_entry_count as a projection on the Submission model' do
        it 'is 0 on the no-business and 2 on the file' do
          expect(extract_no_business_submission._invoice_entry_count).to be_zero
          expect(extract_file_submission._invoice_entry_count).to eql(2)
        end
      end

      describe '#_total_invoice_value as a projection on the Submission model' do
        it 'is nil on the no-business and 20.0 on the file' do
          expect(extract_no_business_submission._total_invoice_value).to be_nil
          expect(extract_file_submission._total_invoice_value.to_digits).to eql('20.0')
        end
      end

      describe '#_total_management_charge_value as a projection on the Submission model' do
        it 'is nil on the no-business and 20.0 on the file' do
          expect(extract_no_business_submission._total_invoice_value).to be_nil
          expect(extract_file_submission._total_management_charge_value.to_digits).to eql('0.2')
        end
      end

      describe '#_first_filename as a projection on the Submission model' do
        context 'on a file submission' do
          subject { extract_file_submission._first_filename }
          it { is_expected.to eql('not-really-an.xls') }
        end

        context 'on a no-business submission' do
          subject { extract_no_business_submission._first_filename }
          it { is_expected.to be_nil }
        end
      end

      describe '#_framework_short_name as a projection on the Submission model' do
        it 'returns the submission’s framework short_name' do
          expect(extract_file_submission._framework_short_name).to eq(file_submission.framework.short_name)
          expect(extract_no_business_submission._framework_short_name)
            .to eq(extract_no_business_submission.framework.short_name)
        end
      end
    end

    context 'with a date range provided' do
      let!(:submission) { create(:completed_submission, updated_at: 1.week.ago) }
      let(:date_range) { 4.days.ago..1.minute.from_now }

      it 'only includes submissions that were updated during the range' do
        all_relevant = Export::Submissions::Extract.all_relevant(date_range)
        expect(all_relevant).not_to match_array submission

        # rubocop:disable Rails/SkipsModelValidations
        submission.touch
        # rubocop:enable Rails/SkipsModelValidations

        all_relevant = Export::Submissions::Extract.all_relevant(date_range)
        expect(all_relevant).to match_array submission
      end
    end
  end
end
