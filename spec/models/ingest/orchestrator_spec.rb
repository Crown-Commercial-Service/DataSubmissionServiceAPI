require 'rails_helper'

RSpec.describe Ingest::Orchestrator do
  around do |example|
    ClimateControl.modify AWS_S3_BUCKET: 'fake', AWS_S3_REGION: 'zz-north-1' do
      example.run
    end
  end

  let(:framework) do
    create(:framework, :with_fdl, short_name: 'RM1557.10') do |framework|
      framework.lots.create(number: 1)
      framework.lots.create(number: 2)
    end
  end
  let(:supplier) { create(:supplier) }
  let(:submission) { create(:submission, framework: framework, supplier: supplier) }
  let(:file) { create(:submission_file, :with_attachment, submission: submission, filename: filename) }
  let!(:agreement) { create(:agreement, framework: framework, supplier: supplier) }

  before { stub_s3_get_object(filename) }

  describe '#perform' do
    context 'with a valid submission' do
      let(:filename) { 'rm1557-10-test.xls' }

      it 'runs the entire ingest, validation and management charge calculation process' do
        create(:customer, urn: 2526618)

        framework.lots.each do |lot|
          create(:agreement_framework_lot, agreement: agreement, framework_lot: lot)
        end

        orchestrator = Ingest::Orchestrator.new(file)
        orchestrator.perform

        expect(SubmissionManagementChargeCalculationJob).to have_been_enqueued.with(submission,
                                                                                    framework.definition_source)
      end
    end

    context 'with an OtherFields submission (Briefs Received)' do
      let(:filename) { 'RM3774_example_return.xls' }
      let(:framework) do
        create(:framework, :with_fdl, short_name: 'RM3774') do |framework|
          framework.lots.create(number: 1)
        end
      end

      before do
        [10018919, 10025944, 10010913, 10014115, 10007349, 10038497, 10023079].each do |urn|
          create(:customer, urn: urn)
        end

        framework.lots.each do |lot|
          create(:agreement_framework_lot, agreement: agreement, framework_lot: lot)
        end

        orchestrator = Ingest::Orchestrator.new(file)
        orchestrator.perform
      end

      it 'has our "other" rows plus some invoices and orders' do
        aggregate_failures do
          expect(submission.entries.where(entry_type: 'invoice').count).to eql(1)
          expect(submission.entries.where(entry_type: 'order').count).to eql(3)
          expect(submission.entries.where(entry_type: 'other').count).to eql(5)

          expect(file.rows).to eql(1 + 3 + 5)
        end
      end

      context 'without the Orders' do
        let(:framework) do
          create(:framework, :with_fdl, short_name: 'RM3774.2') do |framework|
            framework.lots.create(number: 1)
          end
        end

        it 'does not have any orders because the framework does not ask for them' do
          aggregate_failures do
            expect(submission.entries.where(entry_type: 'invoice').count).to eql(1)
            expect(submission.entries.where(entry_type: 'other').count).to eql(5)

            expect(submission.entries.where(entry_type: 'order').count).to be_zero

            expect(file.rows).to eql(1 + 5)
          end
        end
      end
    end

    context 'with an invalid submission' do
      let(:filename) { 'rm1557-10-test.xls' }

      it 'runs the entire ingest and validation process, but skips management charge calculation' do
        orchestrator = Ingest::Orchestrator.new(file)
        orchestrator.perform

        expect(SubmissionManagementChargeCalculationJob).to_not have_been_enqueued
        expect(submission).to be_validation_failed
      end
    end
  end
end
