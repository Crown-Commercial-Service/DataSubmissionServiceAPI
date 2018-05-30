require 'rails_helper'

RSpec.describe Supplier do
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to have_many(:agreements) }
  it { is_expected.to have_many(:frameworks).through(:agreements) }
end
