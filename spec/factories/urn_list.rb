FactoryBot.define do
  factory :urn_list do
    transient do
      filename 'customers.xlsx'
    end

    after(:create) do |urn_list, evaluator|
      urn_list.excel_file.attach(
        io: File.open("spec/fixtures/#{evaluator.filename}"),
        filename: evaluator.filename
      )
    end
  end
end
