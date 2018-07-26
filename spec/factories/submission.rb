FactoryBot.define do
  factory :submission do
    framework
    supplier
    task

    factory :submission_with_pending_entries do
      after(:create) do |submission, _evaluator|
        create_list(:submission_entry, 3, submission: submission)
      end
    end

    factory :submission_with_validated_entries do
      after(:create) do |submission, _evaluator|
        create_list(:validated_submission_entry, 3, submission: submission)
      end
    end

    factory :submission_with_invalid_entries do
      aasm_state :in_review

      after(:create) do |submission, _evaluator|
        create_list(:validated_submission_entry, 2, submission: submission)
        create_list(:errored_submission_entry, 1, submission: submission)
      end
    end
  end
end
