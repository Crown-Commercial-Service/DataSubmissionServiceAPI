FactoryBot.define do
  factory :submission_entry do
    submission
    submission_file
    data(test_key: 'some data')
    source(sheet: 'InvoicesReceived', row: 1)

    factory :validated_submission_entry do
      aasm_state :validated
    end

    factory :errored_submission_entry do
      aasm_state :errored
    end
  end
end
