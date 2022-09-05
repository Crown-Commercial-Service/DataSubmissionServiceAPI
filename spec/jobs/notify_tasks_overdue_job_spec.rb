require 'rails_helper'

RSpec.describe NotifyTasksOverdueJob do
  describe '#perform' do
    let(:tasks_overdue_list_double) { double(notify: 'true') }

    before do
      stub_govuk_bank_holidays_request

      allow(Task::OverdueUserNotificationList).to receive(:new)
        .and_return(tasks_overdue_list_double)
    end

    it 'calls OverdueUserNotificationList on the sixth working day' do
      travel_to Date.new(2019, 1, 9) do
        NotifyTasksOverdueJob.perform_now

        expect(tasks_overdue_list_double).to have_received(:notify)
      end
    end

    it 'calls OverdueUserNotificationList on the eleventh working day' do
      travel_to Date.new(2019, 1, 16) do
        NotifyTasksOverdueJob.perform_now

        expect(tasks_overdue_list_double).to have_received(:notify)
      end
    end

    it 'does nothing on other days' do
      travel_to Date.new(2019, 1, 17) do
        NotifyTasksOverdueJob.perform_now

        expect(tasks_overdue_list_double).not_to have_received(:notify)
      end
    end
  end
end
