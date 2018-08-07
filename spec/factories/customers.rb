FactoryBot.define do
  factory :customer do
    name 'Department for Silly Hats'
    sequence(:urn)
    postcode 'W1 7ZX'
    sector Customer.sectors[:central_government]
  end
end
