require 'rails_helper'

RSpec.describe DataWarehouseExport do
  describe 'on creation' do
    context 'with no previous exports' do
      it "sets the new export's range_from to a date before the project started" do
        first_export = DataWarehouseExport.create!

        expect(first_export.range_from).to eql DataWarehouseExport::EARLIEST_RANGE_FROM
      end
    end

    context 'with previous exports' do
      let!(:previous_export) { DataWarehouseExport.create!(range_to: '2018-12-25 12:34:56') }

      it "sets the new export's range_from to the range_to of the most recent export" do
        new_export = DataWarehouseExport.create!

        expect(new_export.range_from).to eql previous_export.range_to
      end
    end

    it "sets the new export's range_to to the current time" do
      freeze_time do
        new_export = DataWarehouseExport.create!
        expect(new_export.range_to).to eql Time.zone.now
      end
    end
  end

  describe '#run' do
    let(:framework) { create(:framework, short_name: 'RM3786') }
    let!(:submission) { create(:completed_submission, framework: framework) }
    let!(:task) { submission.task }
    let(:export) { DataWarehouseExport.create! }

    before do
      FileUtils.rm Dir.glob('/tmp/*2018-01-01.csv')
      export.run
    end

    around do |example|
      travel_to Date.new(2018, 1, 1) do
        example.run
      end
    end

    it 'generates the tasks export' do
      export_lines = File.readlines('/tmp/tasks_2018-01-01.csv')

      expect(export_lines.size).to eq 2
      expect(export_lines[0]).to match Export::Tasks::HEADER.join(',')
      expect(export_lines[1]).to match task.id
    end

    it 'generates the submissions export' do
      export_lines = File.readlines('/tmp/submissions_2018-01-01.csv')

      expect(export_lines.size).to eq 2
      expect(export_lines[0]).to match Export::Submissions::HEADER.join(',')
      expect(export_lines[1]).to match submission.id
    end

    it 'generates the invoices export' do
      export_lines = File.readlines('/tmp/invoices_2018-01-01.csv')

      expect(export_lines.size).to eq 3
      expect(export_lines[0]).to match Export::Invoices::HEADER.join(',')
      expect(export_lines[1..3]).to all(match submission.id)
    end

    it 'generates the contracts export' do
      export_lines = File.readlines('/tmp/contracts_2018-01-01.csv')

      expect(export_lines.size).to eq 2
      expect(export_lines[0]).to match Export::Contracts::HEADER.join(',')
      expect(export_lines[1..2]).to all(match submission.id)
    end
  end
end
