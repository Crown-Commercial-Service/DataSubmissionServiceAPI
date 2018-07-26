FactoryBot.define do
  factory :submission_entry do
    submission
    submission_file
    data(test_key: 'some data')
    source(sheet: 'InvoicesReceived', row: 1)
  end
end
