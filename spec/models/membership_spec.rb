require 'rails_helper'

RSpec.describe Membership do
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:user) }
end
