require 'rails_helper'
require 'stringio'

RSpec.describe Task::AnticipatedUserNotificationList do
  subject(:list) { Task::AnticipatedUserNotificationList.new(year: year, month: month, output: output) }

  describe '#generate' do
    let(:output) { StringIO.new }

    context 'there are suppliers with users and framework agreements' do
      let(:year)  { 2019 }
      let(:month) { 1 }

      let(:alice)      { FactoryBot.create(:user, name: 'Alice Example', email: 'alice@example.com') }
      let(:bob)        { FactoryBot.create(:user, name: 'Bob Example', email: 'bob@example.com') }

      before do
        supplier_a = FactoryBot.create(:supplier, name: 'Supplier A')
        supplier_b = FactoryBot.create(:supplier, name: 'Supplier B')

        FactoryBot.create(:membership, user: alice, supplier: supplier_a)
        FactoryBot.create(:membership, user: bob, supplier: supplier_b)

        framework1 = FactoryBot.create(:framework, short_name: 'RM0001')

        supplier_a.agreements.create!(framework: framework1)
        supplier_b.agreements.create!(framework: framework1)

        list.generate
      end

      subject(:lines) { output.string.split("\n") }

      it 'has a header row' do
        expect(lines.first).to eql('email address,due_date,person_name,supplier_name,reporting_month')
      end

      it 'has a line for each user' do
        expect(lines).to include('alice@example.com,DUE_DATE?,Alice Example,Supplier A,January 2019')
        expect(lines).to include('bob@example.com,DUE_DATE?,Bob Example,Supplier B,January 2019')
      end
    end
  end
end
