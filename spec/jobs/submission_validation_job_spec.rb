require 'rails_helper'

RSpec.describe SubmissionValidationJob do
  describe '#perform' do
    it 'validates each entry and then triggers the management charge calculation' do
      framework = FactoryBot.create(:framework, short_name: 'RM1070')
      submission = FactoryBot.create(:submission, framework: framework)
      FactoryBot.create(:customer, urn: 12345678)

      calculation_job = double('SubmissionManagementChargeCalculationJob', perform_later: true)

      # rubocop:disable Metrics/LineLength
      good_data = {
        'Lot Number' => '1',
        'Customer Organisation' => 'Example Ltd',
        'Customer URN' => '12345678',
        'Customer Invoice Date' => '01/01/2018',
        'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT' => 12.34,
        'VAT Applicable?' => 'N'
      }
      # rubocop:enable Metrics/LineLength

      bad_data = {
        'Lot Number' => '1',
        'Customer Organisation' => 'Example Ltd',
        'Customer URN' => '00000000',
        'Customer Invoice Date' => '01/01/2018',
        'VAT Applicable?' => 'N'
      }

      FactoryBot.create(:invoice_entry, submission: submission, data: good_data)
      FactoryBot.create(:invoice_entry, submission: submission, data: bad_data)

      SubmissionValidationJob.new.perform(submission, calculation_job)

      expect(submission.entries.validated.count).to eql 1
      expect(submission.entries.errored.count).to eql 1
      expect(calculation_job).to have_received(:perform_later).with(submission)
    end
  end
end
