FactoryBot.define do
  factory :task do
    status 'unstarted'

    supplier
    framework
  end
end
