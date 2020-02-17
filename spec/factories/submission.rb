FactoryBot.define do
  factory :submission do
    framework
    supplier
    task

    factory :no_business_submission do
      aasm_state :completed
      association :task, status: 'completed'
    end

    transient do
      invoice_entries 0
      order_entries 0
    end

    after(:create) do |submission, evaluator|
      create_list(:invoice_entry, evaluator.invoice_entries, submission: submission)
      create_list(:order_entry, evaluator.order_entries, submission: submission)
    end

    factory :submission_with_pending_entries do
      invoice_entries 2
      order_entries 1
    end

    factory :submission_with_validated_entries do
      aasm_state :in_review
      management_charge_total 0.2
      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission, total_value: 10.00, management_charge: 0.1)
        create_list(:order_entry, 1, :valid, submission: submission, total_value: 3.00)
        create_list(:other_entry, 1, :valid, submission: submission)
        if submission.files.empty?
          create_list(:submission_file, 1, :with_attachment, submission: submission, rows: submission.entries.count)
        end
      end
    end

    factory :submission_with_validated_entries_over_5k do
      aasm_state :in_review
      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission, total_value: 3000.00, management_charge: 300000)
        create_list(:order_entry, 1, :valid, submission: submission, total_value: 3.00)
        if submission.files.empty?
          create_list(:submission_file, 1, :with_attachment, submission: submission, rows: submission.entries.count)
        end
      end
    end

    factory :completed_submission do
      aasm_state :completed
      association :task, status: 'completed'

      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission, total_value: 10.00, management_charge: 0.1)
        create_list(:order_entry, 1, :valid, submission: submission, total_value: 3.00)
        if submission.files.empty?
          create_list(:submission_file, 1, :with_attachment, submission: submission, rows: submission.entries.count)
        end
      end

      trait :with_others do
        after(:create) do |submission, _evaluator|
          create_list(:other_entry, 1, :valid, submission: submission)
        end
      end
    end

    factory :submission_with_invalid_entries do
      aasm_state :validation_failed

      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission)
        create_list(:invoice_entry, 1, :errored, submission: submission)
        if submission.files.empty?
          create_list(:submission_file, 1, :with_attachment, submission: submission, rows: submission.entries.count)
        end
      end
    end

    factory :submission_with_unprocessed_entries do
      aasm_state :processing

      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission)
        create_list(:invoice_entry, 1, submission: submission)
        if submission.files.empty?
          create_list(:submission_file, 1, :with_attachment, submission: submission, rows: submission.entries.count)
        end
      end
    end

    factory :submission_with_positive_management_charge do
      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission, management_charge: 0.1, total_value: 10)
      end
    end

    factory :submission_with_negative_management_charge do
      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission, management_charge: -0.1, total_value: -10)
      end
    end

    factory :submission_with_negative_management_charge_over_5k do
      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission, management_charge: -3000, total_value: -300000)
      end
    end

    factory :submission_with_zero_management_charge do
      after(:create) do |submission, _evaluator|
        create_list(:invoice_entry, 2, :valid, submission: submission, management_charge: 0, total_value: 0)
        create_list(:submission_file, 1, submission: submission, rows: submission.entries.count)
      end
    end
  end
end
