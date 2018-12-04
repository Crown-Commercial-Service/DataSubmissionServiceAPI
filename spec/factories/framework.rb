FactoryBot.define do
  factory :framework do
    sequence(:short_name) { |n| "FM#{n + 1000}" }
    sequence(:name) { |n| "G Cloud #{n}" }
  end
end
