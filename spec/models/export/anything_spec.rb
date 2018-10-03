require 'rails_helper'

RSpec.describe Export::Anything do
  let!(:thing_to_export)  { create(:task) }
  let(:relation)          { Task.all }

  subject(:exporter) { Export::Anything.new(relation, output) }

  before do
    allow(STDERR).to receive(:puts)
    allow(STDOUT).to receive(:puts)

    exporter.run
  end

  context 'no output is given / defaulting to file' do
    let(:output) { nil }

    let(:expected_filename) { '/tmp/tasks_2018-12-25.csv' }

    around(:example) do |example|
      travel_to(Date.new(2018, 12, 25)) { example.run }
    end

    after { File.delete(expected_filename) if expected_filename }

    it 'tells us that it’s streaming tasks to /tmp' do
      expect(STDERR).to have_received(:puts).with("Exporting tasks to #{expected_filename}")
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

      let(:expected_filename) { '/tmp/contracts_2018-12-25.csv' }

      it 'tells us that it’s streaming contracts to /tmp' do
        expect(STDERR).to have_received(:puts).with("Exporting contracts to #{expected_filename}")
      end
    end

    context 'there is nothing to export' do
      let(:relation) { Submission.all }
      let(:expected_filename) { nil }

      it 'tells us' do
        expect(STDERR).to have_received(:puts).with('No submissions to export')
      end
    end
  end

  context 'output is given' do
    context 'and it is some rubbish' do
      let(:output) { 'flurp' }

      it 'tells us how to use it' do
        expect(STDERR).to have_received(:puts).with(
          "'flurp' output type not understood. I can output to tmp, stdout"
        )
      end
    end

    context 'it is :stdout' do
      let(:output) { 'stdout' }

      it 'exports to STDOUT' do
        expect(STDOUT).to have_received(:puts).with("#{Export::Tasks::HEADER.join(',')}\n")
      end
    end
  end
end
