FactoryBot.define do
  factory :submission_entry do
    submission
    data(test_key: 'some data')

    trait :invoice do
      entry_type 'invoice'
      source(sheet: 'InvoicesRaised', row: 1)
    end

    trait :order do
      entry_type 'order'
      source(sheet: 'OrdersReceived', row: 1)
    end

    factory :validated_submission_entry do
      aasm_state :validated
    end

    factory :errored_submission_entry do
      aasm_state :errored
    end

    factory :validated_invoice_submission_entry, parent: :validated_submission_entry do
      invoice
    end

    factory :validated_order_submission_entry, parent: :validated_submission_entry do
      order
    end
  end
end
