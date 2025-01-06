FactoryBot.define do
  factory :release_note do
    header { 'Test' }
    body { 'Testy McTestface strikes again!' }
    published { false }
  end
end
