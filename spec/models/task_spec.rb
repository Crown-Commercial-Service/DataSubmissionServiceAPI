require 'rails_helper'

RSpec.describe Task do
  it { is_expected.to validate_presence_of(:status) }

  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:supplier) }
end
