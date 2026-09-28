FactoryBot.define do
  factory :notification_batch do
    notification_type { "due" }
    period_month { Time.zone.today.month }
    period_year { Time.zone.today.year }
    template_id { "template-id" }
    status { "submitted" }
    started_at { Time.current }
  end
end
