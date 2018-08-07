require 'rails_helper'

RSpec.describe Customer do
  subject { FactoryBot.create(:customer) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:urn) }
  it { is_expected.to validate_presence_of(:sector) }
  it { is_expected.to validate_uniqueness_of(:urn) }
end
