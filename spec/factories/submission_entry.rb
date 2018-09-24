FactoryBot.define do
  factory :submission_entry do
    transient do
      row 1
      column 'Column'
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
      transient { error_message 'Required value missing' }

      aasm_state :errored
      validation_errors { [{ 'message' => error_message, 'location' => { 'row' => row, 'column' => column } }] }
    end
  end
end
