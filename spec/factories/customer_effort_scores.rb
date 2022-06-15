FactoryBot.define do
  factory :customer_effort_score do
    rating { 5 }
    comments { 'Perfect, no notes.' }

    user
  end
end
