require 'rails_helper'

RSpec.describe MonthlyTasksGenerationJob do
  describe '#perform' do
    let!(:agreement) { FactoryBot.create(:agreement) }
    let!(:supplier) { agreement.supplier }
    let!(:framework) { agreement.framework }

    it 'generates tasks for the previous month’s submissions' do
      travel_to Date.new(2017, 12, 1) do
        MonthlyTasksGenerationJob.new.perform
        supplier_task = supplier.tasks.first

        expect(supplier_task.framework).to eq framework
        expect(supplier_task.period_month).to eq 11
        expect(supplier_task.period_year).to eq 2017
        expect(supplier_task.due_on).to eq Date.new(2017, 12, 7)
      end
    end

    it 'copes with crossing into a new year' do
      travel_to Date.new(2019, 1, 1) do
        MonthlyTasksGenerationJob.new.perform
        supplier_task = supplier.tasks.first

        expect(supplier_task.framework).to eq framework
        expect(supplier_task.period_month).to eq 12
        expect(supplier_task.period_year).to eq 2018
        expect(supplier_task.due_on).to eq Date.new(2019, 1, 7)
      end
    end
  end
end
