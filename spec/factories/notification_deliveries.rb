FactoryBot.define do
  factory :notification_delivery do
    association :notification_batch

    sequence(:email) { |n| "user#{n}@example.com" }
    supplier_name { "Supplier A" }
    sequence(:reference) { |n| "delivery-reference-#{n}" }
    status { "pending" }

    trait :created do
      sequence(:notify_id) { |n| "notify-id-#{n}" }
      status {'created'}
      sent_at { Time.current }
    end

    trait :delivered do 
      created
      status { 'delivered' }
      completed_at { Time.current }
    end
  end
end
