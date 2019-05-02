FactoryBot.define do
  factory :framework do
    sequence(:short_name) { |n| "FM#{n + 1000}" }
    sequence(:name) { |n| "G Cloud #{n}" }

    published true

    transient do
      lot_count 0
    end

    trait :with_attachment do
      after(:create) do |framework|
        framework.template_file.attach(
          io: File.open('spec/fixtures/template.xls'),
          filename: 'template.xls'
        )
      end
    end

    after(:create) do |framework, evaluator|
      create_list(:framework_lot, evaluator.lot_count, framework: framework)
    end
  end
end
