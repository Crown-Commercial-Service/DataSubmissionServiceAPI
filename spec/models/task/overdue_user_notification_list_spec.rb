require 'rails_helper'
require 'stringio'

RSpec.describe Task::OverdueUserNotificationList do
  subject(:generator) do
    Task::OverdueUserNotificationList.new(year: year, month: month, template_id: template_id, output: output)
  end

  describe '#generate' do
    let(:notify_client) { spy('notify_client') }

    before { stub_govuk_bank_holidays_request }

    context 'there are incomplete submissions for the month in question' do
      let(:year)  { 2019 }
      let(:month) { 1 }
      let(:template_id) { '65691304-e659-40d3-93a3-e7d254a02d45' }

      let(:alice)      { create :user, name: 'Alice Example', email: 'alice@example.com' }
      let(:bob)        { create :user, name: 'Bob Example', email: 'bob@example.com' }
      let(:charley)    { create :user, name: 'Charley Goodsupplier', email: 'charley.goodsupplier@example.com' }
      let(:frank)      { create(:user, :inactive, name: 'Frank Inactive', email: 'frank.inactive@example.com') }

      before do
        framework1 = create :framework, short_name: 'RM0001', name: 'Framework 1'
        framework2 = create :framework, short_name: 'RM0002', name: 'Framework 2'
        framework3 = create :framework, short_name: 'COMPLETE0001'
        create :framework, short_name: 'NOTPUBLISHED0001', published: false

        supplier_a = create(:supplier, name: 'Supplier A')
        supplier_b = create(:supplier, name: 'Supplier B')
        supplier_c = create(:supplier, name: 'Supplier C')

        create :membership, user: alice, supplier: supplier_a
        create :membership, user: alice, supplier: supplier_b
        create :membership, user: bob, supplier: supplier_b
        create :membership, user: frank, supplier: supplier_b
        create :membership, user: charley, supplier: supplier_c

        create :task, supplier: supplier_a, framework: framework1, period_month: 1
        create :task, supplier: supplier_a, framework: framework2, period_month: 1
        create :task, supplier: supplier_b, framework: framework1, period_month: 1

        create :task, :completed, supplier: supplier_a, framework: framework3
        create :task, :completed, supplier: supplier_c, framework: framework1

        allow(Notifications::Client).to receive(:new).and_return notify_client

        generator.notify
      end

      it 'calls Notify for all users with overdue tasks' do
        expect(notify_client).to have_received(:send_email).exactly(3).times

        expect(notify_client).to have_received(:send_email).with(
          email_address: 'alice@example.com',
          template_id: template_id,
          personalisation: {
            person_name: alice.name,
            supplier_name: 'Supplier B',
            framework: ['RM0001 - Framework 1', nil],
            reporting_month: 'January 2019',
            due_date: '7 February 2019'
          }
        ).once
      end
    end
  end
end
