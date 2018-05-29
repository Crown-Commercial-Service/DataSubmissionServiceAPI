require 'rails_helper'

RSpec.describe Framework do
  it { is_expected.to have_many(:lots) }

  describe 'validations' do
    subject { Framework.create(short_name: 'test') }
    it { is_expected.to validate_presence_of(:short_name) }
    it { is_expected.to validate_uniqueness_of(:short_name) }
  end
end
