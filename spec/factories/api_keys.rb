FactoryBot.define do
  factory :api_key do
    key { SecureRandom.hex(20) }
    description { "Test API key" }
  end
end
