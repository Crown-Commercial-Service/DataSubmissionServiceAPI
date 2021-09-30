FactoryBot.define do
  factory :submission_file do
    submission

    trait :with_attachment do
      transient do
        filename { 'not-really-an.xls' }
      end

      after(:create) do |submission_file, evaluator|
        submission_file.file.attach(
          io: File.open("spec/fixtures/#{evaluator.filename}"),
          filename: evaluator.filename
        )
      end
    end
  end
end
