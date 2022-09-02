require 'rails_helper'

RSpec.describe NotifyTasksOverdueJob do
  describe '#perform' do
    let(:tasks_overdue_list_double) { double(notify: 'true') }

    before do
      stub_govuk_bank_holidays_request

      allow(Task::OverdueUserNotificationList).to receive(:new)
        .and_return(tasks_overdue_list_double)
    end

    it 'calls OverdueUserNotificationList' do
      travel_to Date.new(2019, 1, 9) do
        NotifyTasksOverdueJob.perform_now

        expect(tasks_overdue_list_double).to have_received(:notify)
      end
    end
  end
end
