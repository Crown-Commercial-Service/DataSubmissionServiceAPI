FactoryBot.define do
  factory :task do
    status 'unstarted'
    period_month { Time.zone.today.last_month.month }
    period_year  { Time.zone.today.last_month.year }
    due_on { Time.zone.today.beginning_of_month + 7.days }

    supplier
    framework

    trait :completed do
      status 'completed'
    end
  end
end
