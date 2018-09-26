require 'rails_helper'

RSpec.describe Export::Anything do
  let(:tasks)          { [double('Task'), double('Task')] }
  let(:tasks_relation) { double 'ActiveRecord::Relation', klass: 'Task', each: tasks }
  let(:export_tasks)   { double 'Export::Tasks', run: true }

  subject(:exporter) { Export::Anything.new(tasks_relation, output) }

  before do
    allow(Export::Tasks).to receive(:new).and_return(export_tasks)
    allow(STDERR).to receive(:puts)

    exporter.run
  end

  context 'no output is given' do
    let(:output) { nil }

    let(:expected_filename) { '/tmp/tasks_2018-12-25.csv' }

    around(:example) do |example|
      travel_to(Date.new(2018, 12, 25)) { example.run }
    end

    after { File.delete(expected_filename) }

    it 'runs an exporter that streams to a File' do
      expect(Export::Tasks).to have_received(:new).with(tasks_relation, kind_of(File))
      expect(export_tasks).to have_received(:run)
    end

    it 'tells us that it’s streaming to /tmp' do
      expect(STDERR).to have_received(:puts).with("Exporting tasks to #{expected_filename}")
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
        expect(Export::Tasks).to have_received(:new).with(tasks_relation, STDOUT)
        expect(export_tasks).to have_received(:run)
      end
    end
  end
end
