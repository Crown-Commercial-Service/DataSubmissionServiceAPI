FactoryBot.define do
  factory :notification do
    notification_message { 'Wear sunscreen' }
    published { false }
    published_at { Time.zone.now }
    unpublished_at { nil }
    user { 'testy.mctestface@example.com' }
  end
end
