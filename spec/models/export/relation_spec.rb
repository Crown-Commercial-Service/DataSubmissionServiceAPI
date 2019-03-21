require 'rails_helper'

RSpec.describe Export::Relation do
  let!(:thing_to_export)  { create(:task) }
  let(:relation)          { Task.all }
  let(:expected_filename) { '/tmp/tasks_20181225_153012.csv' }
  let(:logger) { Logger.new(log_output) }
  let(:log_output) { StringIO.new }

  subject(:exporter) { Export::Relation.new(relation, logger) }

  let!(:result) { exporter.run }

  around(:example) do |example|
    travel_to(Time.zone.local(2018, 12, 25, 15, 30, 12)) { example.run }
  end

  after { File.delete(expected_filename) if expected_filename }

  it 'returns a handle to the export file' do
    expect(result).to be_a(File)
    expect(result.path).to eq(expected_filename)
  end

  it 'tells us that it’s outputing tasks CSV to /tmp' do
    expect(log_output.string).to include("Exporting tasks to #{expected_filename}")
  end

  context 'we are exporting contracts' do
    let!(:thing_to_export) do
      create(
        :order_entry,
        submission: create(
          :submission, aasm_state: 'completed',
                       framework: create(:framework, short_name: 'RM3756')
        )
      )
    end

    let(:relation) do
      Export::Contracts::Extract.all_relevant
    end

    let(:expected_filename) { '/tmp/contracts_20181225_153012.csv' }

    it 'tells us that it’s streaming contracts to /tmp' do
      expect(log_output.string).to include("Exporting contracts to #{expected_filename}")
    end
  end

  context 'there is nothing to export' do
    let(:relation) { Submission.all }
    let(:expected_filename) { nil }

    it 'tells us' do
      expect(log_output.string).to include('No submissions to export')
    end
  end
end
