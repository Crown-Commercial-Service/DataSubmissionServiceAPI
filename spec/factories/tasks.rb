FactoryBot.define do
  # To be a safe default and to avoid specs which become time bombs,
  # tasks are created with fixed dates, which makes them late.
  #
  # Use +create :task, :current+ if you wish to create a task
  # within the current window and will make your spec match this.
  #
  # https://github.com/dxw/DataSubmissionServiceAPI/pull/290
  factory :task do
    status { 'unstarted' }

    period_month { 1 }
    period_year  { 2018 }
    due_on       { Date.strptime('2018-02-28').beginning_of_month + 7.days }

    supplier
    association :framework, :with_attachment

    trait :current do
      period_month { Time.zone.today.last_month.month }
      period_year  { Time.zone.today.last_month.year }
      due_on       { Time.zone.today.beginning_of_month + 7.days }
    end

    trait :completed do
      status { 'completed' }
    end
  end
end
