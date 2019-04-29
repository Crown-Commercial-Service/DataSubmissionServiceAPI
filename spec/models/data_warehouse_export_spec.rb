require 'rails_helper'

RSpec.describe DataWarehouseExport do
  describe 'on creation' do
    context 'with no previous exports' do
      it "sets the new export's range_from to a date before the project started" do
        first_export = DataWarehouseExport.new

        expect(first_export.range_from).to eql DataWarehouseExport::EARLIEST_RANGE_FROM
      end
    end

    context 'with previous exports' do
      let!(:previous_export) { DataWarehouseExport.create!(range_to: '2018-12-25 12:34:56') }

      it "sets the new export's range_from to the range_to of the most recent export" do
        new_export = DataWarehouseExport.new

        expect(new_export.range_from).to eql previous_export.range_to
      end
    end

    context 'with previous exports but range_from is manually set' do
      let!(:previous_export) { DataWarehouseExport.create!(range_to: '2018-12-25 12:34:56') }

      it "sets the new export's range_from to the range_to of the most recent export" do
        new_export = DataWarehouseExport.new(range_from: DataWarehouseExport::EARLIEST_RANGE_FROM)

        expect(new_export.range_from).to eql DataWarehouseExport::EARLIEST_RANGE_FROM
      end
    end

    it "sets the new export's range_to to the current time" do
      freeze_time do
        new_export = DataWarehouseExport.new
        expect(new_export.range_to).to eql Time.zone.now
      end
    end
  end

  describe 'DataWarehouseExport.generate!', truncation: true do
    let(:framework) { create(:framework, short_name: 'RM3786') }
    let!(:submission) { create(:completed_submission, framework: framework) }
    let!(:task) { submission.task }
    let(:azure_export_upload) { spy('azure_upload') }

    before do
      allow(Export::AzureUpload).to receive(:new).and_return(azure_export_upload)
    end

    around do |example|
      travel_to Date.new(2018, 1, 1) do
        ClimateControl.modify AWS_S3_EXPORT_BUCKET: 'test-bucket' do
          example.run
        end
      end
    end

    it 'uploads the generated files to S3' do
      expected_file_map = {
        'tasks_20180101_000000.csv' => a_kind_of(Tempfile),
        'submissions_20180101_000000.csv' => a_kind_of(Tempfile),
        'invoices_20180101_000000.csv' => a_kind_of(Tempfile),
        'contracts_20180101_000000.csv' => a_kind_of(Tempfile)
      }

      DataWarehouseExport.generate!

      expect(Export::AzureUpload).to have_received(:new).with expected_file_map
      expect(azure_export_upload).to have_received(:perform)
    end

    context 'with no previous exports' do
      it 'returns a persisted DataWarehouseExport instance with the expected range' do
        export = DataWarehouseExport.generate!
        expect(export).to be_persisted
        expect(export.range_from).to eq DataWarehouseExport::EARLIEST_RANGE_FROM
        expect(export.range_to).to eq Date.new(2018, 1, 1)
      end
    end

    context 'with previous export' do
      let!(:previous_export) { DataWarehouseExport.create!(range_to: '2018-12-25 12:34:56') }
      it 'returns a persisted DataWarehouseExport instance with the expected range' do
        export = DataWarehouseExport.generate!
        expect(export).to be_persisted
        expect(export.range_from).to eq previous_export.range_to
        expect(export.range_to).to eq Date.new(2018, 1, 1)
      end

      context 'but reexport is set to true' do
        it 'returns a persisted DataWarehouseExport instance with the expected range' do
          export = DataWarehouseExport.generate!(reexport: true)
          expect(export).to be_persisted
          expect(export.range_from).to eq DataWarehouseExport::EARLIEST_RANGE_FROM
          expect(export.range_to).to eq Date.new(2018, 1, 1)
        end
      end
    end
  end

  describe '#generate_files', truncation: true do
    let(:framework) { create(:framework, short_name: 'RM3786') }
    let!(:submission) { create(:completed_submission, framework: framework) }
    let!(:task) { submission.task }
    let(:export) { DataWarehouseExport.create }

    subject!(:generated_files) { export.generate_files }

    around do |example|
      travel_to Date.new(2018, 1, 1) do
        example.run
      end
    end

    it 'returns a hash the generated exports, with the expected export filename as the keys' do
      expected_filenames = [
        'tasks_20180101_000000.csv',
        'submissions_20180101_000000.csv',
        'invoices_20180101_000000.csv',
        'contracts_20180101_000000.csv'
      ]

      expect(generated_files.values).to all(be_a Tempfile)
      expect(generated_files.keys).to match_array(expected_filenames)
    end

    it 'generates the tasks export' do
      export_lines = generated_files.fetch('tasks_20180101_000000.csv').read.split("\n")

      expect(export_lines.size).to eq 2
      expect(export_lines[0]).to match Export::Tasks::HEADER.join(',')
      expect(export_lines[1]).to match task.id
    end

    it 'generates the submissions export' do
      export_lines = generated_files.fetch('submissions_20180101_000000.csv').read.split("\n")

      expect(export_lines.size).to eq 2
      expect(export_lines[0]).to match Export::Submissions::HEADER.join(',')
      expect(export_lines[1]).to match submission.id
    end

    it 'generates the invoices export' do
      export_lines = generated_files.fetch('invoices_20180101_000000.csv').read.split("\n")

      expect(export_lines.size).to eq 3
      expect(export_lines[0]).to match Export::Invoices::HEADER.join(',')
      expect(export_lines[1..3]).to all(match submission.id)
    end

    it 'generates the contracts export' do
      export_lines = generated_files.fetch('contracts_20180101_000000.csv').read.split("\n")

      expect(export_lines.size).to eq 2
      expect(export_lines[0]).to match Export::Contracts::HEADER.join(',')
      expect(export_lines[1..2]).to all(match submission.id)
    end

    context 'when only a subset of models have actually changed' do
      let!(:submission) { create(:no_business_submission, framework: framework) }

      it 'only returns file handles for the exports that have been generated' do
        expected_filenames = ['tasks_20180101_000000.csv', 'submissions_20180101_000000.csv']

        expect(generated_files.keys).to match_array(expected_filenames)
        expect(generated_files.values).to all(be_a Tempfile)
        expect(generated_files.keys).to match_array(expected_filenames)
      end
    end
  end
end
