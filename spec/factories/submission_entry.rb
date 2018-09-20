FactoryBot.define do
  factory :submission_entry do
    transient do
      row 1
      sheet_name 'Some sheet'
    end

    submission
    entry_type 'invoice'
    data { { test_key: 'some data' } }
    source { { sheet: sheet_name, row: row } }

    factory :invoice_entry do
      sheet_name 'InvoicesRaised'
    end

    factory :order_entry do
      entry_type 'order'
      sheet_name 'OrdersReceived'
    end

    trait :valid do
      aasm_state :validated
    end

    trait :errored do
      aasm_state :errored
    end
  end
end
