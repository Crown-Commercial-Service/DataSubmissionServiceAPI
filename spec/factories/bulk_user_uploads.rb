FactoryBot.define do
  factory :bulk_user_upload do
    transient do
      filename { 'users.csv' }
    end

    trait :with_attachment do
      after(:create) do |bulk_user_upload, evaluator|
        bulk_user_upload.csv_file.attach(
          io: File.open("spec/fixtures/#{evaluator.filename}"),
          filename: evaluator.filename
        )
      end
    end
  end
end
