require 'rails_helper'

RSpec.describe Ingest::Orchestrator do
  let(:framework) do
    create(:framework, short_name: 'RM1557.10') do |framework|
      framework.lots.create(number: 1)
      framework.lots.create(number: 2)
    end
  end
  let(:supplier) { create(:supplier) }
  let(:submission) { create(:submission, framework: framework, supplier: supplier) }
  let(:file) { create(:submission_file, :with_attachment, submission: submission, filename: 'rm1557-10-test.xls') }
  let!(:agreement) { create(:agreement, framework: framework, supplier: supplier) }

  describe '#perform' do
    context 'with a valid submission' do
      it 'runs the entire ingest, validation and management charge calculation process' do
        create(:customer, urn: 2526618)

        framework.lots.each do |lot|
          create(:agreement_framework_lot, agreement: agreement, framework_lot: lot)
        end

        orchestrator = Ingest::Orchestrator.new(file)
        orchestrator.perform

        expect(SubmissionManagementChargeCalculationJob).to have_been_enqueued.with(submission)
      end
    end

    context 'with an invalid submission' do
      it 'runs the entire ingest and validation process, but skips management charge calculation' do
        orchestrator = Ingest::Orchestrator.new(file)
        orchestrator.perform

        expect(SubmissionManagementChargeCalculationJob).to_not have_been_enqueued
        expect(submission).to be_validation_failed
      end
    end
  end
end
