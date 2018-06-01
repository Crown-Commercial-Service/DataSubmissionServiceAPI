require 'rails_helper'

RSpec.describe Agreement do
  it { is_expected.to validate_presence_of(:framework_id) }
  it { is_expected.to validate_presence_of(:supplier_id) }
end
