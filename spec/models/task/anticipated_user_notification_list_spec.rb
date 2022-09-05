require 'rails_helper'
require 'stringio'

RSpec.describe Task::AnticipatedUserNotificationList do
  subject(:list) { Task::AnticipatedUserNotificationList.new(year: year, month: month, output: output) }

  describe '#generate' do
    let(:notify_client) { spy('notify_client') }

    before { stub_govuk_bank_holidays_request }

    context 'there are suppliers with users and framework agreements' do
      let(:year)  { 2019 }
      let(:month) { 1 }

      let(:alice) { FactoryBot.create(:user, name: 'Alice Example', email: 'alice@example.com') }
      let(:bob) { FactoryBot.create(:user, name: 'Bob Example', email: 'bob@example.com') }
      let(:frank) { FactoryBot.create(:user, :inactive, name: 'Frank Inactive', email: 'frank.inactive@example.com') }

      before do
        supplier_a = FactoryBot.create(:supplier, name: 'Supplier A')
        supplier_b = FactoryBot.create(:supplier, name: 'Supplier B')
        supplier_c = FactoryBot.create(:supplier, name: 'Inactive Supplier')

        FactoryBot.create(:membership, user: alice, supplier: supplier_a)
        FactoryBot.create(:membership, user: bob, supplier: supplier_b)
        FactoryBot.create(:membership, user: frank, supplier: supplier_a)
        FactoryBot.create(:membership, user: alice, supplier: supplier_c)

        framework1 = FactoryBot.create(:framework, short_name: 'RM001', name: 'Framework 1')
        framework2 = FactoryBot.create(:framework, short_name: 'RM002', name: 'Framework 2')

        supplier_a.agreements.create!(framework: framework1)
        supplier_b.agreements.create!(framework: framework1)
        supplier_b.agreements.create!(framework: framework2)
        supplier_c.agreements.create!(framework: framework1, active: false)

        allow(Notifications::Client).to receive(:new).and_return notify_client

        list.notify
      end

      it 'calls Notify for all users with upcoming tasks' do
        expect(notify_client).to have_received(:send_email).exactly(2).times

        expect(notify_client).to have_received(:send_email).with(
          email_address: 'alice@example.com',
          template_id: 'c67cd90d-e0d9-4d6e-bc4d-68ef5e20d2e4',
          personalisation: {
            person_name: 'Alice Example',
            supplier_name: 'Supplier A',
            framework: ['RM001 - Framework 1', nil],
            reporting_month: 'January 2019',
            due_date: '7 February 2019'
          }
        ).once
      end
    end
  end
end
