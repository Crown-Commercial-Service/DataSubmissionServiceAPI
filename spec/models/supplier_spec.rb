require 'rails_helper'

RSpec.describe Supplier do
  it { is_expected.to have_many(:submissions) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to have_many(:agreements) }
  it { is_expected.to have_many(:frameworks).through(:agreements) }
  it { is_expected.to have_many(:memberships) }
end
