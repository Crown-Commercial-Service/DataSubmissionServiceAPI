require 'rails_helper'

RSpec.describe Task do
  it { is_expected.to validate_presence_of(:status) }
end
