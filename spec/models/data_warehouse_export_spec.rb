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
    let(:s3_export_upload) { spy('s3_upload') }

    after do
      FileUtils.rm Dir.glob('/tmp/*20180101_000000.csv')
    end

    around do |example|
      travel_to Date.new(2018, 1, 1) do
        ClimateControl.modify AWS_S3_EXPORT_BUCKET: 'test-bucket' do
          example.run
        end
      end
    end

    it 'generates the export files' do
      DataWarehouseExport.generate!
      expect(File).to exist('/tmp/tasks_20180101_000000.csv')
      expect(File).to exist('/tmp/submissions_20180101_000000.csv')
      expect(File).to exist('/tmp/invoices_20180101_000000.csv')
      expect(File).to exist('/tmp/contracts_20180101_000000.csv')
    end

    it 'uploads the generated files to S3' do
      allow(Export::S3Upload).to receive(:new).and_return(s3_export_upload)
      expected_file_paths = [
        '/tmp/tasks_20180101_000000.csv',
        '/tmp/submissions_20180101_000000.csv',
        '/tmp/invoices_20180101_000000.csv',
        '/tmp/contracts_20180101_000000.csv'
      ]

      DataWarehouseExport.generate!

      expect(Export::S3Upload).to have_received(:new).with files_matching_paths(expected_file_paths)
      expect(s3_export_upload).to have_received(:perform)
    end

    it 'returns a persisted DataWarehouseExport instance with the expected range' do
      export = DataWarehouseExport.generate!
      expect(export).to be_persisted
      expect(export.range_from).to eq DataWarehouseExport::EARLIEST_RANGE_FROM
      expect(export.range_to).to eq Date.new(2018, 1, 1)
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

    after do
      FileUtils.rm Dir.glob('/tmp/*20180101_000000.csv')
    end

    it 'generates the tasks export' do
      export_lines = File.readlines('/tmp/tasks_20180101_000000.csv')

      expect(export_lines.size).to eq 2
      expect(export_lines[0]).to match Export::Tasks::HEADER.join(',')
      expect(export_lines[1]).to match task.id
    end

    it 'generates the submissions export' do
      export_lines = File.readlines('/tmp/submissions_20180101_000000.csv')

      expect(export_lines.size).to eq 2
      expect(export_lines[0]).to match Export::Submissions::HEADER.join(',')
      expect(export_lines[1]).to match submission.id
    end

    it 'generates the invoices export' do
      export_lines = File.readlines('/tmp/invoices_20180101_000000.csv')

      expect(export_lines.size).to eq 3
      expect(export_lines[0]).to match Export::Invoices::HEADER.join(',')
      expect(export_lines[1..3]).to all(match submission.id)
    end

    it 'generates the contracts export' do
      export_lines = File.readlines('/tmp/contracts_20180101_000000.csv')

      expect(export_lines.size).to eq 2
      expect(export_lines[0]).to match Export::Contracts::HEADER.join(',')
      expect(export_lines[1..2]).to all(match submission.id)
    end

    it 'returns handles to the generated files' do
      expected_file_paths = [
        '/tmp/tasks_20180101_000000.csv',
        '/tmp/submissions_20180101_000000.csv',
        '/tmp/invoices_20180101_000000.csv',
        '/tmp/contracts_20180101_000000.csv'
      ]

      expect(generated_files).to all(be_a File)
      expect(generated_files).to be_files_matching_paths(expected_file_paths)
    end

    context 'when only a subset of models have actually changed' do
      let!(:submission) { create(:no_business_submission, framework: framework) }

      it 'only returns file handles for the exports that have been generated' do
        expected_file_paths = [
          '/tmp/tasks_20180101_000000.csv',
          '/tmp/submissions_20180101_000000.csv'
        ]

        expect(generated_files).to all(be_a File)
        expect(generated_files).to be_files_matching_paths(expected_file_paths)
      end
    end
  end
end
