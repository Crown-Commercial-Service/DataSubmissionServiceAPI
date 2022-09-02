require 'rails_helper'

RSpec.describe NotifyTasksDueJob do
  describe '#perform' do
    let(:tasks_due_list_double) { double(notify: 'true') }

    before do
      allow(Task::AnticipatedUserNotificationList).to receive(:new)
        .and_return(tasks_due_list_double)
    end

    it 'calls AnticipatedUserNotificationList' do
      NotifyTasksDueJob.perform_now

      expect(tasks_due_list_double).to have_received(:notify)
    end
  end
end
