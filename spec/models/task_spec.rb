require 'rails_helper'

RSpec.describe Task do
  it { is_expected.to validate_presence_of(:status) }

  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:supplier) }

  it { is_expected.to have_many(:submissions) }

  describe '.for_user_id' do
    it 'returns tasks for all suppliers that the current user is a member of' do
      user_id = SecureRandom.uuid

      users_supplier1 = FactoryBot.create(:supplier)
      users_supplier2 = FactoryBot.create(:supplier)
      other_supplier = FactoryBot.create(:supplier)

      FactoryBot.create(:membership, supplier: users_supplier1, user_id: user_id)
      FactoryBot.create(:membership, supplier: users_supplier2, user_id: user_id)

      task1 = FactoryBot.create(:task, supplier: users_supplier1)
      task2 = FactoryBot.create(:task, supplier: users_supplier2)
      task3 = FactoryBot.create(:task, supplier: other_supplier)

      tasks = Task.for_user_id(user_id)

      expect(tasks).to include(task1)
      expect(tasks).to include(task2)
      expect(tasks).to_not include(task3)
    end
  end
end
