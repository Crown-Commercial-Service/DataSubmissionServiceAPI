FactoryBot.define do
  factory :supplier do
    sequence(:name) { |n| "Supplier ##{n} Ltd" }
    sequence(:salesforce_id) { |n| "SALESFORCE-ID-#{n}" }
  end
end
