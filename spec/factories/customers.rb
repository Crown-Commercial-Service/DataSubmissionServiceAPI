FactoryBot.define do
  factory :customer do
    name 'Department for Silly Hats'
    sequence(:urn)
    postcode 'W1 7ZX'
    sector Customer.sectors[:central_government]
  end

  trait :central_government do
    sector Customer.sectors[:central_government]
  end

  trait :wider_public_sector do
    sector Customer.sectors[:wider_public_sector]
  end
end
