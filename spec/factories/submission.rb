FactoryBot.define do
  factory :submission do
    framework
    supplier
    task

    factory :no_business_submission do
      aasm_state :completed
      association :task, status: 'completed'
    end

    factory :submission_with_pending_entries do
      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, submission: submission)
        create_list(:order_entry, 1, submission: submission)
      end
    end

    factory :submission_with_validated_entries do
      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission)
        create_list(:order_entry, 1, :valid, submission: submission)
      end
    end

    factory :submission_with_invalid_entries do
      aasm_state :validation_failed

      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission)
        create_list(:invoice_entry, 1, :errored, submission: submission)
      end
    end

    factory :submission_with_unprocessed_entries do
      aasm_state :processing

      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission)
        create_list(:invoice_entry, 1, submission: submission)
      end
    end
  end
end
