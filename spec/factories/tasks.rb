FactoryBot.define do
  factory :task do
    status 'unstarted'
    period_month 1
    period_year  2019
    due_on       Date.strptime('2019-02-28').beginning_of_month + 7.days

    supplier
    framework

    trait :completed do
      status 'completed'
    end
  end
end
