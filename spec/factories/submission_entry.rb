FactoryBot.define do
  factory :submission_entry do
    submission
    data(test_key: 'some data')

    factory :invoice_entry do
      entry_type 'invoice'
      source(sheet: 'InvoicesRaised', row: 1)
    end

    factory :order_entry do
      entry_type 'order'
      source(sheet: 'OrdersReceived', row: 1)
    end

    trait :valid do
      aasm_state :validated
    end

    trait :errored do
      aasm_state :errored
    end
  end
end
