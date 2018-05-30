require 'rails_helper'

RSpec.describe FrameworkLot do
  it { is_expected.to belong_to(:framework) }

  describe 'validations' do
    subject do
      framework = Framework.create!(short_name: 'cboard8')
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
end
