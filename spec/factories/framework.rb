FactoryBot.define do
  factory :framework do
    sequence(:short_name) { |n| "FM#{n + 1000}" }
    sequence(:name) { |n| "G Cloud #{n}" }
    revenue_category_wid 'd19d3c5849dc01117ee5b3b96d141f5f'

    transient do
      lot_count 0
    end

    after(:create) do |framework, evaluator|
      create_list(:framework_lot, evaluator.lot_count, framework: framework)
    end
  end
end
