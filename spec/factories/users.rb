FactoryBot.define do
  factory :user do
    sequence :auth_id do |n|
      "auth0|123456789#{n}"
    end
    name { 'User Name' }
    sequence :email do |n|
      "user#{n}@example.com"
    end

    trait :inactive do
      auth_id { nil }
    end
  end
end
