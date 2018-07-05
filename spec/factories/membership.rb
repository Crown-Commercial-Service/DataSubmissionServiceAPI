FactoryBot.define do
  factory :membership do
    user_id { SecureRandom.uuid }
    supplier
  end
end
