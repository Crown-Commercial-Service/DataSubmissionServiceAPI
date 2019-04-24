FactoryBot.define do
  factory :framework do
    sequence(:short_name) { |n| "FM#{n + 1000}" }
    sequence(:name) { |n| "G Cloud #{n}" }

    published true

    transient do
      lot_count 0
    end

    after(:create) do |framework, evaluator|
      create_list(:framework_lot, evaluator.lot_count, framework: framework)
    end
  end
end
