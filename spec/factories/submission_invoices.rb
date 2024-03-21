FactoryBot.define do
  factory :submission_invoice do
    sequence(:workday_reference) { |n| "WORKDAY_REFERENCE##{n}" }
    reversal { false }
    submission
  end
end
