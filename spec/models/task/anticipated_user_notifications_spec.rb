require 'rails_helper'

RSpec.describe Task::AnticipatedUserNotifications do
  subject(:notifications) { described_class.new(month: month, year: year) }

  let(:month) { 1 }
  let(:year) { 2019 }

  before do
    stub_govuk_bank_holidays_request
  end

  context 'when there are suppliers with active agreements and users' do
    let(:alice) do
      FactoryBot.create(
        :user, 
        name: 'Alice Example',
        email: 'alice@example.com'
      )
    end

    let(:bob) do
      FactoryBot.create(
        :user, 
        name: 'Bob Example',
        email: 'bob@example.com'
      )
    end

    let(:frank) do
      FactoryBot.create(
        :user, 
        :inactive,
        name: 'Frank Inactive',
        email: 'frank.inactive@example.com'
      )
    end

    before do
      supplier1 = FactoryBot.create(:supplier, name: 'Supplier 1')
      supplier2 = FactoryBot.create(:supplier, name: 'Supplier 2')
      supplier3 = FactoryBot.create(:supplier, name: 'Supplier 3')

      FactoryBot.create(:membership, user: alice, supplier: supplier1)
      FactoryBot.create(:membership, user: bob, supplier: supplier2)
      FactoryBot.create(:membership, user: frank, supplier: supplier1)
      FactoryBot.create(:membership, user: alice, supplier: supplier3)

      framework1 = FactoryBot.create(:framework, short_name: 'RM001', name: 'Framework 1')
      framework2 = FactoryBot.create(:framework, short_name: 'RM002', name: 'Framework 2')

      supplier1.agreements.create!(framework: framework1)
      supplier2.agreements.create!(framework: framework1)
      supplier2.agreements.create!(framework: framework2)
      supplier3.agreements.create!(framework: framework1, active: false)
    end

    it 'returns a notification for each active user of an active supplier' do
      expect(notifications.pluck(:email)).to contain_exactly('alice@example.com', 'bob@example.com')
    end

    it 'includes the supplier name' do
      alice_notification = notifications.find do |notification|
        notification[:email] == 'alice@example.com'
      end

      expect(alice_notification[:supplier_name]).to eq('Supplier 1')
    end

    it 'includes the expected personalisation' do
      alice_notification = notifications.find do |notification|
        notification[:email] == 'alice@example.com'
      end

      expect(alice_notification[:personalisation]).to include(
        due_date: '7 February 2019',
        person_name: 'Alice Example',
        supplier_name: 'Supplier 1',
        reporting_month: 'January 2019'
      )
    end

    it 'includes the active frameworks for each supplier' do
      bob_notification = notifications.find { |n| n[:email] == 'bob@example.com' }
      expect(bob_notification[:personalisation][:frameworks]).to eq(['RM001 - Framework 1', 'RM002 - Framework 2'])
    end

    it 'ignores inactive users' do
      expect(notifications.pluck(:email)).not_to include('frank.inactive@example.com')
    end

    it 'ignores suppliers without active frameworks' do
      expect(notifications.pluck(:supplier_name)).not_to include('Supplier 3')
    end
  end
end