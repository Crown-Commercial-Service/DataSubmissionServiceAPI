require 'rails_helper'

RSpec.describe FrameworkLot do
  it { is_expected.to belong_to(:framework) }
end
