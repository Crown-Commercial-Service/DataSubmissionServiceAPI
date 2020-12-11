require 'rails_helper'

RSpec.describe FrameworkLot do
  it { is_expected.to belong_to(:framework) }

  describe 'validations' do
    subject do
      framework = FactoryBot.create(:framework, short_name: 'cboard8')
      framework.lots.create!(number: '1a')
    end

    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_uniqueness_of(:number).scoped_to(:framework_id) }

    it 'can have two frameworks with the same lot number' do
      first_framework = FactoryBot.create(:framework, short_name: 'cboard8')
      second_framework = FactoryBot.create(:framework, short_name: 'cake2018')

      first_framework.lots.create!(number: '2')

      expect { second_framework.lots.create!(number: '2') }.not_to raise_error
    end
  end

  describe '#has_active_agreement?' do
    it 'returns true if there are active agreements on the given lot' do
      framework = FactoryBot.create(:framework, short_name: 'cboard8')
      framework_lot = FactoryBot.create(:framework_lot, framework: framework, number: '1a')
      agreement = FactoryBot.create(:agreement, active: true)
      create(:agreement_framework_lot, framework_lot: framework_lot, agreement: agreement)
      
      expect(framework_lot.active_agreement?).to be true
    end

    it 'returns false if there are no active agreements' do
      framework = FactoryBot.create(:framework, short_name: 'cboard8')
      framework_lot = FactoryBot.create(:framework_lot, framework: framework, number: '1a')

      expect(framework_lot.active_agreement?).to be false
    end
  end
end
