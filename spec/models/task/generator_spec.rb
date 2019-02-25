require 'rails_helper'

RSpec.describe Task::Generator do
  describe '#generate!' do
    before { stub_govuk_bank_holidays_request }

    context 'given some agreements' do
      let!(:agreement_1) { FactoryBot.create(:agreement) }
      let!(:agreement_2) { FactoryBot.create(:agreement) }
      let!(:inactive_agreement) { FactoryBot.create(:agreement, active: false) }
      let!(:supplier_1) { agreement_1.supplier }
      let!(:supplier_2) { agreement_2.supplier }
      let!(:framework_1) { agreement_1.framework }
      let!(:framework_2) { agreement_2.framework }

      it 'creates a new task for the specified period for active agreements, with a due date 7 days into the month' do
        expect { Task::Generator.new(month: 8, year: 2018).generate! }.to change { Task.count }.by 2

        supplier_1_task = supplier_1.tasks.first
        expect(supplier_1_task.framework).to eq framework_1
        expect(supplier_1_task.period_month).to eq 8
        expect(supplier_1_task.period_year).to eq 2018
        expect(supplier_1_task.due_on).to eq Date.new(2018, 9, 7)

        supplier_2_task = supplier_2.tasks.first
        expect(supplier_2_task.framework).to eq framework_2
        expect(supplier_2_task.period_month).to eq 8
        expect(supplier_2_task.period_year).to eq 2018
        expect(supplier_2_task.due_on).to eq Date.new(2018, 9, 7)
      end

      it 'adjusts the due date when there are bank holidays so there are always at least 5 working days' do
        Task::Generator.new(month: 12, year: 2018).generate!
        task = supplier_1.tasks.order(:created_at).last
        expect(task.due_on).to eq Date.new(2019, 1, 8)
      end

      context 'given a task already exists for the agreement and period' do
        let!(:existing_task) do
          FactoryBot.create(
            :task,
            supplier: supplier_1,
            framework: framework_1,
            period_month: 7,
            period_year: 2018,
            due_on: Date.new(2018, 8, 7)
          )
        end

        it 'does not create any duplicate tasks' do
          expect { Task::Generator.new(month: 7, year: 2018).generate! }.to change { Task.count }.by 1

          expect(supplier_1.tasks.count).to eq 1
          expect(supplier_2.tasks.count).to eq 1
        end
      end
    end
  end
end
