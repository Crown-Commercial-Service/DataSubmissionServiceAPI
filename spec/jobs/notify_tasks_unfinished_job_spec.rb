require 'rails_helper'

RSpec.describe NotifyTasksUnfinishedJob do
  describe '#perform' do
    let(:tasks_unfinished_list_double) { double(notify: 'true') }

    before do
      stub_govuk_bank_holidays_request

      allow(Task::UnfinishedUserNotificationList).to receive(:new)
        .and_return(tasks_unfinished_list_double)
    end

    it 'calls OverdueUserNotificationList on the fourth working day' do
      travel_to Date.new(2019, 1, 7) do
        NotifyTasksUnfinishedJob.perform_now

        expect(tasks_unfinished_list_double).to have_received(:notify)
      end
    end

    it 'calls OverdueUserNotificationList on the ninth working day' do
      travel_to Date.new(2019, 1, 14) do
        NotifyTasksUnfinishedJob.perform_now

        expect(tasks_unfinished_list_double).to have_received(:notify)
      end
    end
  end
end
