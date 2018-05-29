require 'rails_helper'

RSpec.describe FrameworkLot do
  it { is_expected.to belong_to(:framework) }

  describe 'validations' do
    subject do
      framework = Framework.create!(short_name: 'cboard8')
      framework.lots.create!(number: '1a')
    end

    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_uniqueness_of(:number) }
  end
end
