require 'rails_helper'

RSpec.describe Export::Tasks::Row do
  describe '#year_and_month' do
    it 'left-pads single digit months to shortened ISO8601' do
      row = Export::Tasks::Row.new(FactoryBot.build(:task, period_year: 2018, period_month: 8), {})
      expect(row.year_and_month).to eql('2018-08')
    end
  end

  describe '#status' do
    it 'reports "correcting" as "completed"' do
      row = Export::Tasks::Row.new(FactoryBot.build(:task, status: 'correcting'), {})
      expect(row.status).to eql('completed')
    end

    it 'reports "in_progress" as the active submission\'s aasm state' do
      task = FactoryBot.build(:task, status: 'in_progress')
      FactoryBot.create(:submission_with_validated_entries, aasm_state: 'in_review', task: task)
      row = Export::Tasks::Row.new(task, {})
      expect(row.status).to eql('in_review')
    end

    (Task.aasm.states.map(&:name) - %i[correcting in_progress]).each do |state|
      it "reports \"#{state}\" as \"#{state}\"" do
        row = Export::Tasks::Row.new(FactoryBot.build(:task, status: state), {})
        expect(row.status).to eql(state.to_s)
      end
    end
  end
end
