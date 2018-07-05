require 'rails_helper'

RSpec.describe Membership do
  it { is_expected.to belong_to(:supplier) }

  it { is_expected.to validate_presence_of(:supplier_id) }
  it { is_expected.to validate_presence_of(:user_id) }
end
