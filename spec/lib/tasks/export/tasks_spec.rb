require 'rails_helper'

RSpec.describe 'rake export:tasks', type: :task do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  context 'no args are given' do
    let!(:first_task)  { create(:task, status: :unstarted, period_year: 2018, period_month: 8) }
    let!(:second_task) { create(:task) }

    let(:output_filename) { '/tmp/tasks_2018-12-25.csv' }
    let(:args)            { {} }
    let(:output_lines)    { File.read(output_filename).split("\n") }

    around(:example) do |example|
      travel_to(Date.new(2018, 12, 25)) { example.run }
    end

    before { task.execute(args) }
    after  { File.delete(output_filename) }

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
          #{first_task.id},2018-08,#{first_task.supplier.id},#{first_task.framework.short_name},unstarted,1,,
        LINE
      )
    end
  end
end
