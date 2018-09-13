require 'rails_helper'

RSpec.describe 'rake export:tasks', type: :task do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  context 'no date is given' do
    let(:task_exporter)   { spy('Export::Tasks') }
    let(:tasks_to_export) { [double('Task'), double('Task')] }
    let(:todays_filename) { "/tmp/tasks_#{Time.zone.today}.csv" }

    after { File.delete(todays_filename) }

    before do
      allow(Task).to receive(:all).and_return(tasks_to_export)
      allow(Export::Tasks).to receive(:new).with(
        tasks_to_export, duck_type(:puts)
      ).and_return(
        task_exporter
      )

      task.execute
    end

    it 'forwards the request to Export::Tasks#run' do
      expect(task_exporter).to have_received(:run)
    end

    it 'creates that file' do
      expect(File).to exist(todays_filename)
    end

    it 'tells us what file it’s creating on STDERR' do
      expect { task.execute }.to output(
        "Exporting tasks to #{todays_filename}\n"
      ).to_stderr
    end
  end
end
