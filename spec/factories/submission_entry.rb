FactoryBot.define do
  factory :submission_entry do
    submission
    submission_file
    data {}
    source {}
  end
end
