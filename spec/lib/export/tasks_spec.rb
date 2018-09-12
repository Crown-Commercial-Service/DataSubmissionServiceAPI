require 'rails_helper'
require 'export/tasks'
require 'stringio'

RSpec.describe Export::Tasks do
  context 'given valid tasks and an in-memory output' do
    let(:first_task)       { create(:task, status: :unstarted, period_year: 2018, period_month: 8) }
    let(:tasks)            { [first_task, create(:task)] }

    let(:output)           { StringIO.new }
    subject(:output_lines) { output.string.split("\n") }

    before do
      Export::Tasks.new(tasks, output).run
    end

    it 'writes a header to that output' do
      expect(output_lines.first).to eql(
        <<~HEADER.chomp
          TaskID,Month,SupplierID,FrameworkID,Status,TaskType,StartedDate,CompletedDate
        HEADER
      )
    end

    it 'writes each task to that output' do
      expect(output_lines.length).to eql(3)
      expect(output_lines[1]).to eql(
        <<~LINE.chomp
          #{first_task.id},201808,#{first_task.supplier.id},#{first_task.framework.id},unstarted,1,,
        LINE
      )
    end
  end
end
