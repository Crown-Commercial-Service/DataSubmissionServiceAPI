require 'rails_helper'

RSpec.describe Export::Anything do
  let(:models)            { [double('Task'), double('Task')] }
  let(:relation)          { double 'ActiveRecord::Relation', klass: 'Task', each: models, empty?: false }
  let(:exporter_instance) { double 'Export::Tasks', run: true }

  let(:exporter_class) { Export::Tasks }

  subject(:exporter) { Export::Anything.new(relation, output) }

  before do
    allow(exporter_class).to receive(:new).and_return(exporter_instance)
    allow(STDERR).to receive(:puts)

    exporter.run
  end

  context 'no output is given' do
    let(:output) { nil }

    let(:expected_filename) { '/tmp/tasks_2018-12-25.csv' }

    around(:example) do |example|
      travel_to(Date.new(2018, 12, 25)) { example.run }
    end

    after { File.delete(expected_filename) if expected_filename }

    it 'runs an exporter that streams to a File' do
      expect(exporter_class).to have_received(:new).with(relation, kind_of(File))
      expect(exporter_instance).to have_received(:run)
    end

    it 'tells us that it’s streaming tasks to /tmp' do
      expect(STDERR).to have_received(:puts).with("Exporting tasks to #{expected_filename}")
    end

    context 'we are exporting contracts' do
      let(:exporter_class)    { Export::Contracts }
      let(:models)            { [double('Contract'), double('Contract')] }
      let(:relation)          { double 'ActiveRecord::Relation', klass: 'Contract', each: models, empty?: false }
      let(:exporter_instance) { double 'Export::Contracts', run: true }

      let(:expected_filename) { '/tmp/contracts_2018-12-25.csv' }

      it 'tells us that it’s streaming contracts to /tmp' do
        expect(STDERR).to have_received(:puts).with("Exporting contracts to #{expected_filename}")
      end
    end

    context 'there is nothing to export' do
      let(:relation) { double 'ActiveRecord::Relation', klass: 'Task', empty?: true }
      let(:expected_filename) { nil }

      it 'tells us' do
        expect(STDERR).to have_received(:puts).with('No tasks to export')
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

      it 'exports to STDOUT using a class derived from the relation' do
        expect(exporter_class).to have_received(:new).with(relation, STDOUT)
        expect(exporter_instance).to have_received(:run)
      end
    end
  end
end
