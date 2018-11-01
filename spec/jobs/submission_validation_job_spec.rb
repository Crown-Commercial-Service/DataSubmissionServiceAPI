require 'rails_helper'

RSpec.describe SubmissionValidationJob do
  describe '#perform' do
    # rubocop:disable Metrics/LineLength
    let(:total_value_field) { 'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT' }
    # rubocop:enable Metrics/LineLength
    let(:framework) { FactoryBot.create(:framework, short_name: 'RM1070') }
    let(:submission) { FactoryBot.create(:submission, framework: framework) }
    let!(:customer) { FactoryBot.create(:customer, urn: 12345678) }
    let(:good_data) do
      {
        'Lot Number' => '1',
        'Customer Organisation' => 'Example Ltd',
        'Customer URN' => '12345678',
        'Customer Invoice Date' => '01/01/2018',
        total_value_field => 12.34,
        'VAT Applicable?' => 'N'
      }
    end
    let(:bad_data) do
      {
        'Lot Number' => '1',
        'Customer Organisation' => 'Example Ltd',
        'Customer URN' => '12345678',
        'Customer Invoice Date' => '01/01/2018',
        'VAT Applicable?' => 'N'
      }
    end

    context 'with all valid rows' do
      it 'updates validation status of each entry and triggers the management charge calculation' do
        FactoryBot.create(:invoice_entry, submission: submission, data: good_data)
        good_row = FactoryBot.create(:invoice_entry, submission: submission, data: good_data)

        expect { SubmissionValidationJob.new.perform(submission) }.not_to change { submission.aasm_state }

        expect(submission.entries.validated.count).to eql 2
        expect(submission.entries.errored.count).to eql 0
        expect(SubmissionManagementChargeCalculationJob).to have_been_enqueued
        expect(good_row.validation_errors).to eq(nil)
      end
    end
    context 'with an invalid row' do
      it 'updates validation status of each entry and marks the submission as failed' do
        FactoryBot.create(:invoice_entry, submission: submission, data: good_data)
        bad_row = FactoryBot.create(:invoice_entry, submission: submission, data: bad_data)

        SubmissionValidationJob.new.perform(submission)

        expect(submission.entries.validated.count).to eql 1
        expect(submission.entries.errored.count).to eql 1
        expect(submission).to be_validation_failed
        bad_row.reload
        expect(bad_row.validation_errors).to eq(
          [
            {
              'message' => 'is not a number',
              'location' => {
                'row' => bad_row.source['row'],
                'column' => total_value_field,
              },
            }
          ]
        )
        expect(SubmissionManagementChargeCalculationJob).not_to have_been_enqueued
      end
    end
  end
end
