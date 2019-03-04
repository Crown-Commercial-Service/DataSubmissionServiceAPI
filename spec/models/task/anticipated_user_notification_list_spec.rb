require 'rails_helper'
require 'stringio'

RSpec.describe Task::AnticipatedUserNotificationList do
  subject(:list) { Task::AnticipatedUserNotificationList.new(year: year, month: month, output: output) }

  describe '#generate' do
    let(:output) { StringIO.new }

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

        framework1 = FactoryBot.create(:framework, short_name: 'RM0001')
        framework2 = FactoryBot.create(:framework, short_name: 'RM0002')

        supplier_a.agreements.create!(framework: framework1)
        supplier_b.agreements.create!(framework: framework1)
        supplier_b.agreements.create!(framework: framework2, active: false)
        supplier_c.agreements.create!(framework: framework1, active: false)

        list.generate
      end

      subject(:lines) { output.string.split("\n") }

      it 'has a header row that lists all the frameworks' do
        expect(lines.first).to eql('email address,due_date,person_name,supplier_name,reporting_month,RM0001,RM0002')
      end

      it 'has a line for each user including the frameworks their supplier is active on' do
        expect(lines).to include('alice@example.com,7 February 2019,Alice Example,Supplier A,January 2019,yes,no')
        expect(lines).to include('bob@example.com,7 February 2019,Bob Example,Supplier B,January 2019,yes,no')
      end

      it 'ignores inactive agreements' do
        expect(output.string).not_to include('Inactive Supplier')
      end

      it 'ignores inactive users' do
        expect(output.string).not_to include('Frank Inactive')
      end
    end
  end
end
