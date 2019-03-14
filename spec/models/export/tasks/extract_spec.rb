require 'rails_helper'

RSpec.describe Export::Tasks::Extract do
  describe '#all_relevant' do
    let(:all_relevant) { Export::Tasks::Extract.all_relevant(date_range) }

    context 'with no date range provided' do
      let(:date_range) { nil }

      it 'includes all tasks' do
        tasks = create_list(:task, 3)

        expect(all_relevant).to eq tasks
      end
    end

    context 'with a date range provided' do
      let!(:task) { create(:task, updated_at: 1.week.ago) }
      let(:date_range) { 4.days.ago..1.minute.from_now }

      it 'only includes tasks that were updated during the range' do
        all_relevant = Export::Tasks::Extract.all_relevant(date_range)
        expect(all_relevant).not_to match_array task

        # rubocop:disable Rails/SkipsModelValidations
        task.touch
        # rubocop:enable Rails/SkipsModelValidations

        all_relevant = Export::Tasks::Extract.all_relevant(date_range)
        expect(all_relevant).to match_array task
      end
    end
  end
end
