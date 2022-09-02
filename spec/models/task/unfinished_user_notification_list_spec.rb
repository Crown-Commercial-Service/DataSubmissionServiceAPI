require 'rails_helper'
require 'stringio'

RSpec.describe Task::UnfinishedUserNotificationList do
  subject(:generator) { Task::UnfinishedUserNotificationList.new(output: output) }

  describe '#generate' do
    let(:output) { StringIO.new }
    let(:notify_client) { spy('notify_client') }

    before { stub_govuk_bank_holidays_request }

    context 'there are incomplete submissions for the month in question' do
      let(:year)  { 2019 }
      let(:month) { 1 }

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

        task_a = create :task, supplier: supplier_a, framework: framework3
        task_b = create :task, supplier: supplier_b, framework: framework3

        create :submission_with_invalid_entries, supplier: supplier_a, task: task_a, created_by: alice
        create :submission_with_validated_entries, supplier: supplier_b, task: task_b, created_by: bob

        allow(Notifications::Client).to receive(:new).and_return notify_client

        generator.generate
        generator.notify
      end

      subject(:lines) { output.string.split("\n") }

      it 'calls Notify for all users with unfinished tasks' do
        expect(notify_client).to have_received(:send_email).exactly(3).times
      end

      it 'has a header row that lists relevant aasm states' do
        expect(lines.first).to eql(
          'email address,task_period,person_name,supplier_name,task_name,submission_date,validation_failed' \
          ',ingest_failed,in_review'
        )
      end

      it 'ignores inactive agreements' do
        expect(output.string).not_to include('Inactive Supplier')
      end

      it 'ignores inactive users' do
        expect(output.string).not_to include('Frank Inactive')
      end

      it 'does not include suppliers with no incomplete submissions' do
        expect(output.string).not_to include('Charley Goodsupplier')
      end
    end
  end
end
